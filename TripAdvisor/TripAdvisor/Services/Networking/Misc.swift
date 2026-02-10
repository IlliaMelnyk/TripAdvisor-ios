//
//  Misc.swift
//  CityGuide
//
//  Created by Illia Melnyk on 23.04.2025.
//

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}



enum APIError: Error {
    case invalidHost
    case invalidURLComponents
    case noResponse
    case unacceptableResponseStatusCode
    case customDecodingFailed
}
