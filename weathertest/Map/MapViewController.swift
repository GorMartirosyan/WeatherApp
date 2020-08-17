//
//  MapViewController.swift
//  weathertest
//
//  Created by Gor on 4/26/20.
//  Copyright © 2020 user1. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet private var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(gesturePressed(_:)))
        map.addGestureRecognizer(gesture)
    }
    
    @objc private func gesturePressed(_ gesture: UITapGestureRecognizer) {
        let position = gesture.location(in: map)
        let coordinate = map.convert(position, toCoordinateFrom: map)
        showAlert(coordinate)
    }
    
    private func showAlert(_ coordinate: CLLocationCoordinate2D) {
        let alert = UIAlertController(title: "Uraaa", message: "lat: \(coordinate.latitude) lon: \(coordinate.longitude)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
