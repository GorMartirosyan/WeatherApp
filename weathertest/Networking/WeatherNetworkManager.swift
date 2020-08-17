//
//  WeatherNetworkManager.swift
//  weathertest
//
//  Created by Gor on 4/26/20.
//  Copyright © 2020 user1. All rights reserved.
//

import Foundation

private let weatherUrl = baseUrl + "/weather"

extension NetworkManager {
    private struct WeatherResponseData: Codable {
        let weather: [WeatherData]
        let main: MainData
        let name: String
    }

    func getWeatherData(for city: String, completion: @escaping (CityData?) -> Void) {
        if let url = URL(string: weatherUrl)?.addQueries([Key.term: city]) {
            var request = URLRequest(url: url)
            request.setUpHeaders()
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                let decoder = JSONDecoder()
                if let data = data, let response = try? decoder.decode(WeatherResponseData.self, from: data) {
                    let city = CityData(name: response.name,
                                        weather: response.weather[0].main,
                                        temrature: response.main.temp)
                    completion(city)
                    return
                }
                completion(nil)
            }
            task.resume()
        }
    }
}
