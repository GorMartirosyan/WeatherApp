//
//  ForecastNetworkManager.swift
//  weathertest
//
//  Created by Gor on 4/26/20.
//  Copyright © 2020 user1. All rights reserved.
//

import Foundation
import Alamofire

private let forecastUrl = baseUrl + "/forecast"

extension NetworkManager {
    private struct ForecastResponseData: Codable {
        struct ItemData: Codable {
            let weather: [WeatherData]
            let main: MainData
            let dt: Int
        }
        let list: [ItemData]
    }

    func getWeatherForecaseData(for city: City, completion: @escaping ([TimeData]?) -> Void) {
        if let url = URL(string: forecastUrl)?.addQueries([Key.id: String(city.id)]) {
            var request = URLRequest(url: url)
            request.setUpHeaders()
            AF.download(request).responseDecodable { (response: DownloadResponse<ForecastResponseData, AFError>) in
                if let data = try? response.result.get() {
                    completion(data.list.map({ item in
                        TimeData(timeStamp: item.dt, weather: item.weather[0].main, temrature: item.main.temp)
                    }))
                }
            }
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                let decoder = JSONDecoder()
//                if let data = data, let response = try? decoder.decode(ForecastResponseData.self, from: data) {
//                    completion(response.list.map({ item in
//                        TimeData(timeStamp: item.dt, weather: item.weather[0].main, temrature: item.main.temp)
//                    }))
//                    return
//                }
//                completion(nil)
//            }
//            task.resume()
        }
    }
}
