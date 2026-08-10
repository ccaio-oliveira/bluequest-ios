//
//  APIError.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/08/26.
//

import Foundation

enum APIError: LocalizedError {
    case unauthorized
    case validation(message: String, fields: [String: [String]])
    case domainRule(reason: String, state: String?)
    case server(status: Int)
    case network(Error)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            "Sua sessão expirou. Entre novamente."
        case .validation(let message, let fields):
            fields.values.first?.first ?? message
        case .domainRule(let reason, _):
            Self.message(for: reason)
        case .server:
            "O servidor não conseguiu responder. Tente de novo."
        case .network:
            "Sem conexão. Verifique sua internet."
        case .decoding:
            "Recebemos uma resposta inesperada do servidor."
        }
    }

    private static func message(for reason: String) -> String {
        switch reason {
        case "user_not_participant": "Você não participa deste desafio."
        case "occurrence_not_available": "Esta tarefa não está mais disponível."
        case "occurrence_does_not_exist": "Esta tarefa não ocorre nesta data."
        case "outside_challenge_period": "Esta data está fora do período do desafio."
        default: "Não foi possível concluir a ação."
        }
    }
}
