//
//  Session.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/08/26.
//

import Foundation

@MainActor
final class Session {
    static let shared = Session()
    
    private(set) var currentUser: User? {
        didSet {
            NotificationCenter.default.post(name: .sessionUserDidChange, object: self)
        }
    }
    
    var isAuthenticated: Bool {
        Keychain.get(.authToken) != nil
    }
    
    private init() {}
    
    func start(token: String, user: User) {
        Keychain.set(token, for: .authToken)
        currentUser = user
    }
    
    func update(user: User) {
        currentUser = user
    }
    
    func end() {
        Keychain.delete(.authToken)
        currentUser = nil
        ReminderScheduler.clear()
    }
    
    func expire() {
        guard isAuthenticated else { return }
        
        end()
        NotificationCenter.default.post(name: .sessionDidExpire, object: self)
    }
}

extension Notification.Name {
    static let sessionUserDidChange = Notification.Name("BlueQuest.sessionUserDidChange")
    static let sessionDidExpire = Notification.Name("BlueQuest.sessionDidExpire")
}
