//
//  AuthService.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/08/26.
//

import Foundation

struct UserDTO: Decodable {
    let id: Int
    let name: String
    let email: String
    let avatarUrl: String?
    let hasPassword: Bool
    
    func toDomain() -> User {
        User(id: id, name: name, email: email, avatarURL: avatarUrl.flatMap(URL.init(string:)), hasPassword: hasPassword)
    }
}

private struct AuthResponseDTO: Decodable {
    let user: UserDTO
    let token: String
}

private struct LoginRequest: Encodable {
    let email: String
    let password: String
}

private struct RegisterRequest: Encodable {
    let name: String
    let email: String
    let password: String
}

final class AuthService {
    static let shared = AuthService()
    
    private let client = APIClient.shared
    
    private init() {}
    
    func login(email: String, password: String) async throws -> (user: User, token: String) {
        let response: AuthResponseDTO = try await client.post("login", body: LoginRequest(email: email, password: password))
        
        return (response.user.toDomain(), response.token)
    }
    
    func register(name: String, email: String, password: String) async throws -> (user: User, token: String) {
        let response: AuthResponseDTO = try await client.post("register", body: RegisterRequest(name: name, email: email, password: password))
        
        return (response.user.toDomain(), response.token)
    }
    
    func currentUser() async throws -> User {
        let dto: UserDTO = try await client.get("me")
        return dto.toDomain()
    }
    
    func logout() async throws {
        try await client.postWithoutResponse("logout")
    }
    
    func signInWithGoogle(idToken: String, name: String?) async throws -> (user: User, token: String) {
        let response: AuthResponseDTO = try await client.post("auth/google", body: SocialAuthRequest(identityToken: idToken, name: name))
        
        return (response.user.toDomain(), response.token)
    }
    
    func requestPasswordReset(email: String) async throws {
        try await client.post("password/forgot", body: ForgotPasswordRequest(email: email))
    }
    
    func resetPassword(email: String, code: String, password: String, confirmation: String) async throws -> (user: User, token: String) {
        let response: AuthResponseDTO = try await client.post(
            "password/reset",
            body: ResetPasswordRequest(email: email, code: code, password: password, passwordConfirmation: confirmation)
        )
        
        return (response.user.toDomain(), response.token)
    }
}


private struct SocialAuthRequest: Encodable {
    let identityToken: String
    let name: String?
}

private struct ForgotPasswordRequest: Encodable {
    let email: String
}

private struct ResetPasswordRequest: Encodable {
    let email: String
    let code: String
    let password: String
    let passwordConfirmation: String
}
