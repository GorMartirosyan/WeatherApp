//
//  CityListViewController.swift
//  weathertest
//
//  Created by Gor on 4/19/20.
//  Copyright © 2020 user1. All rights reserved.
//

import UIKit

class CityListViewController: UIViewController {
    private let defaults = UserDefaults.standard
    private var cities = [CityData?]()
    private var favoriteCities = [City]() {
        didSet {
            cities = [CityData?](repeating: nil, count: favoriteCities.count)
            for (index, city) in favoriteCities.enumerated() {
                    self.getCityWeather(for: city, at: index)
            }
            citiesTable.reloadData()
        }
    }
    
    private var refreshInProgress = false
    private var refreshControl = UIRefreshControl()
    @IBOutlet private var citiesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        citiesTable.delegate = self
        citiesTable.dataSource = self
        favoriteCities = defaults.cities()
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        citiesTable.addSubview(refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if refreshInProgress {
            refreshControl.beginRefreshing()
        }
    }
    
    private func getCityWeather(for city: City, at index: Int) {
        NetworkManager.shared.getWeatherData(for: city.name) { [weak self] cityData in
            DispatchQueue.main.async {
                if let self = self, let cityData = cityData {
                    self.cities[index] = cityData
                    if let cell = self.citiesTable.cellForRow(at: IndexPath(row: index, section: 0)) as? CityCell {
                        cell.setUp(with: cityData)
                    }
                }
            }
        }
    }
    
    @IBAction private func addFavoriteCity() {
        let sVC = SearchViewController()
        sVC.delegate = self
        present(sVC, animated: true)
    }
    
    @objc private func refresh() {
        refreshInProgress = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            self.favoriteCities = self.defaults.cities()
            self.refreshControl.endRefreshing()
            self.refreshInProgress = false
        }
    }
}

extension CityListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CityCell.id, for: indexPath) as? CityCell else { return UITableViewCell() }
        if let data = cities[indexPath.row] {
            cell.setUp(with: data)
        } else {
            cell.setUp(with: favoriteCities[indexPath.row])
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dVC = DetailsViewController()
        dVC.city = favoriteCities[indexPath.row]
        navigationController?.pushViewController(dVC, animated: true)
    }
}

extension CityListViewController: SearchViewControllerDelagate {
    func citySelected() {
        favoriteCities = defaults.cities()
    }
}

class CityCell: UITableViewCell {
    static let id = "CityCell"
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var tempLabel: UILabel!
    @IBOutlet private var weatherLabel: UILabel!
    @IBOutlet private var indicator: UIActivityIndicatorView!
    
    func setUp(with data: CityData) {
        tempLabel.isHidden = false
        weatherLabel.isHidden = false
        nameLabel.text = data.name
        tempLabel.text = TempConverter.toCelsiusString(data.temrature)
        weatherLabel.text = data.weather
        indicator.stopAnimating()
        indicator.isHidden = true
    }
    
    func setUp(with city: City) {
        nameLabel.text = city.name
        tempLabel.isHidden = true
        weatherLabel.isHidden = true
        indicator.isHidden = false
        indicator.startAnimating()
    }
}

struct CityData {
    let name: String
    let weather: String
    let temrature: Double
}
