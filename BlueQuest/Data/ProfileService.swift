//
//  ProfileService.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 07/10/26.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
    private let client = APIClient.shared
    
    private init() {}
    
    func stats() async throws -> ProfileStats {
        try await client.get("me/stats")
    }
    
    func updateAccount(name: String, email: String, currentPassword: String?) async throws -> User {
        let dto: UserDTO = try await client.put("me", body: UpdateAccountRequest(name: name, email: email, currentPassword: currentPassword))
        return dto.toDomain()
    }
    
    func updatePassword(current: String?, new: String, confirmation: String) async throws -> User {
        let dto: UserDTO = try await client.put("me/password", body: UpdatePasswordRequest(currentPassword: current, password: new, passwordConfirmation: confirmation))
        return dto.toDomain()
    }
}

struct ProfileStats: Decodable, Equatable {
    let challenges: Int
    let points: Int
    let wins: Int
}

private struct UpdateAccountRequest: Encodable {
    let name: String
    let email: String
    let currentPassword: String?
}

private struct UpdatePasswordRequest: Encodable {
    let currentPassword: String?
    let password: String
    let passwordConfirmation: String
}
