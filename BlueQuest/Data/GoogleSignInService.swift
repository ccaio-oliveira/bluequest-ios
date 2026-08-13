//
//  GoogleSignInService.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 13/08/26.
//

import Foundation
import GoogleSignIn
import UIKit

enum GoogleSignInError: Error {
    case missingIdentityToken
    case cancelled
}

@MainActor
final class GoogleSignInService {
    static let shared = GoogleSignInService()
    
    private init() {}
    
    func signIn(presenting viewController: UIViewController) async throws -> (idToken: String, name: String?) {
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            
            guard let idToken = result.user.idToken?.tokenString else { throw GoogleSignInError.missingIdentityToken }
            
            return (idToken, result.user.profile?.name)
        } catch let error as GIDSignInError where error.code == GIDSignInError.Code.canceled {
            throw GoogleSignInError.cancelled
        }
    }
}
