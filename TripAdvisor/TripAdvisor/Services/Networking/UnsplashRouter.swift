//
//  UnsplashRouter.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 18.06.2025.
//

import Foundation


enum UnsplashRouter: Endpoint {
    case searchImages(query: String)

    var host: String {
        "api.unsplash.com"
    }

    var path: String {
        switch self {
        case .searchImages:
            return "/search/photos"
        }
    }

    var method: HttpMethod {
        return .get
    }

    var headers: [String: String] {
        guard let clientId = Secrets.get("UNSPLASH_API_KEY") else {
            print("⚠️ Client-ID not found in Secrets.plist")
            return [:]
        }
        
        return [
            "Authorization": "Client-ID \(clientId)",
            "Accept-Version": "v1"
        ]
    }

    var urlParameters: [String: Any]? {
        switch self {
        case let .searchImages(query):
            return [
                "query": query,
                "per_page": 10
            ]
        }
    }

    var body: Data? {
        return nil // GET request doesn't need a body
    }
    
    func asRequest() throws -> URLRequest {
            var components = URLComponents()
            components.scheme = "https"
            components.host = host // must be "api.unsplash.com" without "https://"
            components.path = path
            
            // Convert query params
            if let urlParameters = urlParameters {
                components.queryItems = urlParameters.map {
                    URLQueryItem(name: $0.key, value: "\($0.value)")
                }
            }
            
            // Final URL
            guard let url = components.url else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            headers.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
            request.httpBody = body
            
            return request
        }
    
    
}
