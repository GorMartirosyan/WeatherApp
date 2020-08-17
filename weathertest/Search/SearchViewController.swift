//
//  SearchViewController.swift
//  weathertest
//
//  Created by Gor on 5/3/20.
//  Copyright © 2020 user1. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelagate {
    func citySelected()
}

class SearchViewController: UIViewController {

    var delegate: SearchViewControllerDelagate?
    private let defaults = UserDefaults.standard
    private var favoriteCities = [City]() {
        didSet {
            defaults.setCities(favoriteCities)
        }
    }

    private var filteredCities = [City]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        favoriteCities = defaults.cities()
        filteredCities = favoriteCities
        CityFilter.shared.prefetchCities()
    }
    
    @IBAction private func cancelAction() {
        delegate?.citySelected()
        dismiss(animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchKey = searchBar.text, !searchKey.isEmpty {
            CityFilter.shared.filterCities(for: searchKey) { [weak self] cities in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if self.searchBar.text == searchKey {
                        self.filteredCities = cities
                    }
                }
            }
        } else {
            filteredCities = favoriteCities
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let city = filteredCities[indexPath.row]
        cell.textLabel?.text = "\(city.name), \(city.country)"
        cell.selectionStyle = .none
        cell.backgroundColor = favoriteCities.contains(city) ? #colorLiteral(red: 0.2380838096, green: 0.70333004, blue: 0.3991242349, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = filteredCities[indexPath.row]
        if let index = favoriteCities.firstIndex(of: city) {
            favoriteCities.remove(at: index)
        } else {
            favoriteCities.append(city)
        }
        tableView.reloadData()
    }
}

private let singleFilterLimit = 10_000
private class CityFilter {
    private class Loader {
        private var allCities: [City]?
        private let lock = NSLock()

        @discardableResult func getAllCities() -> [City] {
            lock.lock()
            var result = [City]()
            if let allCities = self.allCities {
                result = allCities
            } else if let url = Bundle.main.url(forResource: "city.list", withExtension: "json"),
                let data = try? Data(contentsOf: url),
                var allCities = try? JSONDecoder().decode([City].self, from: data) {
                allCities = allCities.sorted(by: <)
                self.allCities = allCities
            } else {
                print("-----------Wrong-----------")
            }
            lock.unlock()
            return result
        }
    }
    
    static let shared = CityFilter()
    private let loader = Loader()
    private var resultsDict = [String: [City]]()

    func prefetchCities() {
        DispatchQueue.global().async {
            self.loader.getAllCities()
        }
    }
    
    func filterCities(for key: String, completion: @escaping ([City]) -> Void) {
        DispatchQueue.global().async {
            let result = self.cities(for: key)
            if result.complete {
                completion(result.cities)
                return
            }
            let filtered = self.filterCities(result.cities, for: key)
            completion(filtered)
            self.resultsDict[key] = filtered
        }
    }
    
    private func filterCities(_ cities: [City], for key: String) -> [City] {
        if cities.count > singleFilterLimit {
            let slicedCities = cities.slice()
            var result = [[City]](repeating: [], count: slicedCities.count)
            let group = DispatchGroup()
            let lowerKey = key.lowercased()
            for (index, cities) in slicedCities.enumerated() {
                group.enter()
                DispatchQueue.global().async {
                    result[index] = cities.filter({ $0.name.lowercased().contains(lowerKey) })
                    group.leave()
                }
            }
            group.wait()
            return result.flatMap({ $0 })
        } else {
            let lowerKey = key.lowercased()
            let filtered = cities.filter({ $0.name.lowercased().contains(lowerKey) })
            return filtered
        }
    }
    
    private func cities(for key: String) -> (cities: [City], complete: Bool) {
        if let cities = resultsDict[key] {
            return (cities, true)
        }
        let cachedKeys = resultsDict.keys.sorted { $0.count > $1.count }
        if let subKey = cachedKeys.first(where: { key.contains($0) }),
            let cities = resultsDict[subKey] {
            return (cities, false)
        }
        return (self.loader.getAllCities(), false)
    }
}

extension Array where Element == City {
    func slice(to elementsCount: Int = singleFilterLimit) -> [[City]] {
        var copy = self
        var result = [[City]]()
        while !copy.isEmpty {
            let limit = Swift.min(elementsCount, copy.count)
            result.append(Array(copy[0..<limit]))
            copy = Array(copy.dropFirst(limit))
        }
        return result
    }
}

struct City: Codable, Comparable {
    static func < (lhs: City, rhs: City) -> Bool {
        lhs.name < rhs.name
    }
    
    let id: Int
    let name: String
    let country: String
}
