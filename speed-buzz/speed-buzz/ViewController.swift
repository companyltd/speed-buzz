//
//  ViewController.swift
//  speed-buzz
//
//  Created by Benjamin Dimant on 6/24/18.
//  Copyright © 2018 Company Ltd. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager!
    
    var latitude = ""
    var longitude = ""

    // MARK: Properties
    
    @IBOutlet weak var currentSpeed: UILabel!
    @IBOutlet weak var speedLimit: UILabel!
    
    // MARK: JSON Decodables
    struct Response: Decodable {
        let elements: [SpeedData]
    }
    
    struct SpeedData: Decodable {
        let tags: Tags
    }
    
    struct Tags: Decodable {
        let maxspeed: String
    }
    
    // MARK: Boilerplate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initialiseLocationServices()
    }
    
    // MARK: Helpers
    
    func getSpeedLimit(withCompletion completion: @escaping (String?, Error?) -> Void) {
        // Construct URL for request
        let urlString = "https://overpass-api.de/api/interpreter?data=[out:json];way[maxspeed](around:100,\(latitude),%20\(longitude));out%20tags;"
        guard let url = URL(string: urlString) else { return }
        
        // Asynchronously make Overpass API request
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion(nil, error)
            } else if let data = data {
                do {
                    // Attempt to decode the response
                    guard let response = try? JSONDecoder().decode(Response.self, from: data) else { completion(nil, error); return }
                    if (!response.elements.isEmpty) {
                        completion(String(response.elements[0].tags.maxspeed), nil)
                    } else {
                        completion(nil, nil)
                    }
                } catch {
                    completion(nil, error)
                }
            }
        }.resume()
    }
    
    func initialiseLocationServices() {
        // Initialise location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        // Begin fetching location updates
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        latitude = String(userLocation.coordinate.latitude)
        longitude = String(userLocation.coordinate.longitude)

        currentSpeed.text = String(Int(round(userLocation.speed)))
        
        getSpeedLimit { (success, failure) in
            DispatchQueue.main.async {
                self.speedLimit.text = success!
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
}



