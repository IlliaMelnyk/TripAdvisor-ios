//
//  UnsplashService.swift
//  TripAdvisor
//
//  Created by Artsiom Halachkin on 18.06.2025.
//

import Foundation

final class UnsplashService {
    func searchImageURLs(query: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let router = UnsplashRouter.searchImages(query: query)

        do {
            let request = try router.asRequest()
            print("🔵 Request URL: \(request.url?.absoluteString ?? "")")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("⚠️ Unsplash request error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = NSError(domain: "InvalidResponse", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
                    print("⚠️ Unsplash invalid response: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                print("📬 Response Headers: \(httpResponse.allHeaderFields)")


                guard (200...299).contains(httpResponse.statusCode) else {
                    let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP status code: \(httpResponse.statusCode)"])
                    print("⚠️ Unsplash HTTP error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    let error = NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    print("⚠️ Unsplash no data: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                do {
                    // Log raw JSON for debugging
                    if let rawJSON = String(data: data, encoding: .utf8) {
                        print("🔍 Unsplash raw JSON: \(rawJSON.prefix(500))...")
                    }

                    // Parse JSON
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let results = json["results"] as? [[String: Any]] {
                        let urls: [String] = results.compactMap { item in
                            if let urlsDict = item["urls"] as? [String: Any],
                               let regular = urlsDict["regular"] as? String {
                                return regular
                            }
                            return nil
                        }
                        print("🔍 Unsplash parsed \(urls.count) URLs for query: \(query)")
                        completion(.success(urls))
                    } else {
                        let error = NSError(domain: "ParseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
                        print("⚠️ Unsplash parse error: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                } catch {
                    print("⚠️ Unsplash JSON parsing error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            task.resume()
        } catch {
            print("⚠️ Unsplash request creation error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}
