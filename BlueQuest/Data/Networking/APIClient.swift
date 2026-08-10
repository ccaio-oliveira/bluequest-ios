//
//  APIClient.swift
//  BlueQuest
//
//  Created by Caio Lucas Oliveira Vieira on 10/08/26.
//

import Foundation

struct EmptyBody: Encodable {}

final class APIClient {
    static let shared = APIClient()

    private let baseURL = AppEnvironment.apiBaseURL
    private let session = URLSession(configuration: .default)

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)

            if let date = ISO8601DateFormatter.bqInternet.date(from: raw) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Data em formato inesperado: \(raw)"
            )
        }
        return decoder
    }()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    func get<Response: Decodable>(_ path: String, query: [String: String] = [:]) async throws -> Response {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!

        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"

        return try await send(request)
    }

    func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.httpBody = try encoder.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return try await send(request)
    }

    func postWithoutResponse(_ path: String) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"

        _ = try await perform(request)
    }

    private func send<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        let data = try await perform(request)

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        var request = request
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = Keychain.get(.authToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.server(status: -1)
        }

        switch http.statusCode {
        case 200..<300:
            return data
        case 401:
            throw APIError.unauthorized
        case 422:
            throw unprocessableError(from: data)
        default:
            throw APIError.server(status: http.statusCode)
        }
    }

    private func unprocessableError(from data: Data) -> APIError {
        struct DomainPayload: Decodable {
            let error: String
            let state: String?
        }
        struct ValidationPayload: Decodable {
            let message: String
            let errors: [String: [String]]?
        }

        if let payload = try? JSONDecoder().decode(DomainPayload.self, from: data) {
            return .domainRule(reason: payload.error, state: payload.state)
        }

        if let payload = try? JSONDecoder().decode(ValidationPayload.self, from: data) {
            return .validation(message: payload.message, fields: payload.errors ?? [:])
        }

        return .server(status: 422)
    }
}

extension ISO8601DateFormatter {
    static let bqInternet: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
