//
//  DetailsViewController.swift
//  weathertest
//
//  Created by Gor on 4/26/20.
//  Copyright © 2020 user1. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    var city: City?
    var dataList = [TimeData]() {
        didSet {
            dataTable.reloadData()
        }
    }
    
    @IBOutlet private var dataTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataTable.dataSource = self
        dataTable.delegate = self
        if let city = city {
            setUp(with: city)
        }
    }
    
    private func setUp(with city: City) {
        title = city.name
        NetworkManager.shared.getWeatherForecaseData(for: city) { [weak self] dataList in
            DispatchQueue.main.async {
                if let self = self, let dataList = dataList {
                    self.dataList = dataList
                }
            }
        }
    }
}

extension DetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataList[indexPath.row]
        let temp = TempConverter.toCelsiusString(data.temrature)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        let date = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(data.timeStamp)))
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(temp) \(data.weather) \(date)"
        return cell
    }
}

struct TimeData {
    let timeStamp: Int
    let weather: String
    let temrature: Double
}
