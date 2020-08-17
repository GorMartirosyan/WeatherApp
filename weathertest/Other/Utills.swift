//
//  Utills.swift
//  weathertest
//
//  Created by Gor on 4/26/20.
//  Copyright © 2020 user1. All rights reserved.
//

import Foundation

struct TempConverter {
    static func celsius(from kelvin: Double) -> Double {
        return kelvin - 273.15
    }
    
    static func toCelsiusString(_ kelvin: Double) -> String {
        return "\(Int(celsius(from: kelvin))) Cº"
    }
}

extension UserDefaults {
    enum Key {
        static let favoriteCities = "FavoriteCities"
    }
    
    func setCities(_ cities: [City], for key: String = Key.favoriteCities) {
        guard let data = try? JSONEncoder().encode(cities) else { return }
        self.set(data, forKey: key)
    }
    
    func cities(for key: String = Key.favoriteCities) -> [City] {
        var result = [City]()
        if let data = self.data(forKey: key), let decoded = try? JSONDecoder().decode([City].self, from: data) {
            result = decoded
        }
        return result
    }
}
