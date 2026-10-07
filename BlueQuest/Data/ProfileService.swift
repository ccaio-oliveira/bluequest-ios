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
}

struct ProfileStats: Decodable, Equatable {
    let challenges: Int
    let points: Int
    let wins: Int
}
