//
//  GoogleAIStudioRouter.swift
//  TripAdvisor
//
//  Created by Illia Melnyk on 11.06.2025.
//

import Foundation

import Foundation

enum GoogleAIStudioRouter: Endpoint {
    case generateTips(prompt: String)

    var host: String {
        "https://generativelanguage.googleapis.com"
    }

    var path: String {
        switch self {
        case .generateTips:
            // Zkontroluj aktuální verzi modelu, tady příklad pro gemini-2.0-flash
            return "/v1beta/models/gemini-2.0-flash:generateContent"
        }
    }

    var method: HttpMethod {
        return .post
    }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }

    var urlParameters: [String: Any]? {
        guard let apiKey = Secrets.get("AI_API_KEY") else {
            print("⚠️ API key not found in Secrets.plist")
            return nil
        }
        return ["key": apiKey]
    }

    var body: Data? {
        switch self {
        case let .generateTips(prompt):
            let json: [String: Any] = [
                "contents": [
                    [
                        "parts": [
                            [
                                "text": prompt
                            ]
                        ]
                    ]
                ]
            ]
            return try? JSONSerialization.data(withJSONObject: json)
        }
    }
}
