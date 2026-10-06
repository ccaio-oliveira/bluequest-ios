//
//  ConnectivityMonitor.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 01/10/26.
//

import Foundation
import Network

@MainActor
final class ConnectivityMonitor {
    static let shared = ConnectivityMonitor()
    
    private(set) var isOnline = true
    
    private let monitor = NWPathMonitor()
    
    private init() {}
    
    func start() {
        monitor.pathUpdateHandler = { @Sendable [weak self] path in
            let isOnline = path.status == .satisfied
            
            Task { @MainActor [weak self] in
                self?.update(isOnline)
            }
        }
        
        monitor.start(queue: DispatchQueue(label: "BlueQuest.connectivity"))
    }
    
    private func update(_ isOnline: Bool) {
        guard isOnline != self.isOnline else { return }
        
        self.isOnline = isOnline
        NotificationCenter.default.post(name: .connectivityDidChange, object: self)
    }
}

extension Notification.Name {
    static let connectivityDidChange = Notification.Name("BlueQuest.connectivityDidChange")
}
