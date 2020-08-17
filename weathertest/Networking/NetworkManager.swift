//
//  NetworkManager.swift
//  weathertest
//
//  Created by Gor on 4/19/20.
//  Copyright © 2020 user1. All rights reserved.
//

import Foundation

private let apiKey = "35be6aa779b97d29025f9c6d854f50eb"
let baseUrl = "https://api.openweathermap.org/data/2.5"

class NetworkManager {
    enum Key {
        static let term = "q"
        static let id = "id"
    }
    
    static let shared = NetworkManager()
}

struct WeatherData: Codable {
    let main: String
}

struct MainData: Codable {
    let temp: Double
}

extension URLRequest {
    mutating func setUpHeaders() {
        addValue(apiKey, forHTTPHeaderField: "X-API-Key")
    }
}

extension URL {
    func addQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        var queryItems = components?.queryItems ?? []
        queryItems += queries.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
        components?.queryItems = queryItems
        return components?.url
    }
}
