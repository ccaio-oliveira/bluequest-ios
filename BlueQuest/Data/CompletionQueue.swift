//
//  CompletionQueue.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 06/10/26.
//

import Foundation

struct PendingCompletion: Codable, Equatable {
    let id: UUID
    let taskID: Int
    let taskName: String
    let points: Int
    let occurrenceDate: String
    let photoFile: String?
    var photoPath: String?
}

enum CompletionQueueEvent {
    case sent(PendingCompletion)
    case rejected(PendingCompletion, message: String)
}

extension Notification.Name {
    static let completionQueueDidChange = Notification.Name("BlueQuest.completionQueueDidChange")
}

@MainActor
final class CompletionQueue {
    static let shared = CompletionQueue()
    
    private(set) var items: [PendingCompletion] = []
    
    private var isFlushing = false
    private var connectivityObserver: NSObjectProtocol?
    
    private let directory: URL
    private var fileURL: URL { directory.appendingPathComponent("queue.json") }
    
    private init() {
        directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("PendingCompletions", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        if let data = try? Data(contentsOf: fileURL) {
            items = (try? JSONDecoder().decode([PendingCompletion].self, from: data)) ?? []
        }
    }
    
    func start() {
        connectivityObserver = NotificationCenter.default.addObserver(
            forName: .connectivityDidChange,
            object: nil,
            queue: .main
        ) { _ in
            Task { await CompletionQueue.shared.flush() }
        }
        
        Task { await flush() }
    }
    
    func isPending(taskID: Int, occurrenceDate: String) -> Bool {
        items.contains { $0.taskID == taskID && $0.occurrenceDate == occurrenceDate }
    }
    
    func submit(taskID: Int, taskName: String, points: Int, occurrenceDate: String, photo: Data?) throws {
        guard !isPending(taskID: taskID, occurrenceDate: occurrenceDate) else { return }
        
        let id = UUID()
        var photoFile: String?
        
        if let photo {
            let name = "\(id.uuidString).jpg"
            try photo.write(to: directory.appendingPathComponent(name), options: .atomic)
            photoFile = name
        }
        
        items.append(PendingCompletion(
            id: id,
            taskID: taskID,
            taskName: taskName,
            points: points,
            occurrenceDate: occurrenceDate,
            photoFile: photoFile,
            photoPath: nil
        ))
        
        save()
        notify()
        
        Task { await flush() }
    }
    
    func flush() async {
        guard !isFlushing, ConnectivityMonitor.shared.isOnline else { return }
        
        isFlushing = true
        defer { isFlushing = false }
        
        while let item = items.first {
            do {
                try await send(item)
                finish(item, event: .sent(item))
            } catch APIError.network, APIError.server, APIError.unauthorized {
                return
            } catch APIError.domainRule(reason: "occurrence_not_available", state: "completed") {
                finish(item, event: .sent(item))
            } catch {
                let message = (error as? APIError)?.errorDescription ?? "Não foi possível registrar a conclusão."
                finish(item, event: .rejected(item, message: message))
            }
        }
    }
    
    func clear() {
        items = []
        
        try? FileManager.default.removeItem(at: directory)
        
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        notify()
    }
    
    private func send(_ item: PendingCompletion) async throws {
        var item = item
        
        if item.photoPath == nil, let photoFile = item.photoFile {
            let photo = try Data(contentsOf: directory.appendingPathComponent(photoFile))
            item.photoPath = try await PhotoService.shared.uploadCompletionPhoto(photo)
            replace(item)
        }
        
        try await ChallengeService.shared.completeTask(
            taskID: item.taskID,
            occurrenceDate: item.occurrenceDate,
            photoPath: item.photoPath
        )
    }
    
    private func replace(_ item: PendingCompletion) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        items[index] = item
        save()
    }
    
    private func finish(_ item: PendingCompletion, event: CompletionQueueEvent) {
        items.removeAll { $0.id == item.id }
        
        if let photoFile = item.photoFile {
            try? FileManager.default.removeItem(at: directory.appendingPathComponent(photoFile))
        }
        
        save()
        notify(event)
    }
    
    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        
        try? data.write(to: fileURL, options: .atomic)
    }
    
    private func notify(_ event: CompletionQueueEvent? = nil) {
        NotificationCenter.default.post(
            name: .completionQueueDidChange,
            object: self,
            userInfo: event.map { ["event": $0] }
        )
    }
}
