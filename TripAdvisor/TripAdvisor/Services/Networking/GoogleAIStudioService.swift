//
//  GoogleAIStudioService.swift
//  TripAdvisor
//
//  Created by Illia Melnyk on 12.06.2025.
//

import Foundation


import Foundation

final class GoogleAIStudioService {
    func generateTips(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let router = GoogleAIStudioRouter.generateTips(prompt: prompt)
        do {
            let request = try router.asRequest()

            print("🔵 Request URL: \(request.url?.absoluteString ?? "nil")")
            if let headers = request.allHTTPHeaderFields {
                print("🔵 Headers: \(headers)")
            }
            if let body = request.httpBody,
               let bodyString = String(data: body, encoding: .utf8) {
                print("🔵 Body: \(bodyString)")
            }

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("🔴 Network error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("🔵 HTTP Status Code: \(httpResponse.statusCode)")
                }

                guard let data = data else {
                    print("🔴 No data received.")
                    completion(.failure(NSError(domain: "NoData", code: 0)))
                    return
                }

                if let responseString = String(data: data, encoding: .utf8) {
                    print("🔵 Response data as string: \(responseString)")
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let candidates = json["candidates"] as? [[String: Any]],
                       let firstCandidate = candidates.first,
                       let content = firstCandidate["content"] as? [String: Any],
                       let parts = content["parts"] as? [[String: Any]],
                       let firstPart = parts.first,
                       let output = firstPart["text"] as? String {
                        completion(.success(output))
                    } else {
                        completion(.failure(NSError(domain: "ParseError", code: 0)))
                    }
                } catch {
                    print("🔴 JSON decoding error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        } catch {
            print("🔴 Request creation error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}


