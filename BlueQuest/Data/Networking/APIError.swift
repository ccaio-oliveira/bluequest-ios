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
    case invalidImage

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
        case .invalidImage:
            "Não foi possível preparar a foto."
        }
    }

    private static func message(for reason: String) -> String {
        switch reason {
        case "user_not_participant": "Você não participa deste desafio."
        case "occurrence_not_available": "Esta tarefa não está mais disponível."
        case "occurrence_does_not_exist": "Esta tarefa não ocorre nesta data."
        case "outside_challenge_period": "Esta data está fora do período do desafio."
        case "challenge_closed": "Este desafio já foi encerrado."
        case "start_locked": "O início não pode mudar depois que o desafio começou."
        case "start_in_past": "O início não pode ser uma data passada."
        case "end_in_past": "O término não pode ser uma data passada."
        case "cannot_remove_creator": "O cirador não pode ser removido do desafio."
        case "challenge_not_started": "O desafio ainda não começou."
        default: "Não foi possível concluir a ação."
        }
    }
}
