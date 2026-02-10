//
//  Endpoint.swift
//  CityGuide
//
//  Created by Illia Melnyk on 23.04.2025.
//

import Foundation

import Foundation

protocol Endpoint {
    var host: String { get }
    var path: String { get }
    var method: HttpMethod { get }
    var headers: [String: String] { get }
    var urlParameters: [String: Any]? { get }
    var body: Data? { get }

    func asRequest() throws -> URLRequest
}

extension Endpoint {
    func asRequest() throws -> URLRequest {
        guard var hostUrl = URLComponents(string: host) else {
            throw NSError(domain: "InvalidHost", code: 0)
        }

        hostUrl.path = path

        // Přidání urlParameters jako queryItems (i u POST)
        if let params = urlParameters {
            hostUrl.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }

        guard let url = hostUrl.url else {
            throw NSError(domain: "InvalidURL", code: 0)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers

        if method != .get {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return request
    }
}
