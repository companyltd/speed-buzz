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
    var timer = Timer()
    
    var latitude = ""
    var longitude = ""

    // MARK: Properties
    
    @IBOutlet weak var currentSpeed: UILabel!
    @IBOutlet weak var speedLimit: UILabel!
    
    
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
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // scheduledTimerWithTimeInterval()
        determineLocation()
    }
    
    // MARK: Helpers
    
    func scheduledTimerWithTimeInterval() {
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        // timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.getSpeedLimit), userInfo: nil, repeats: true)
    }
    
    func getSpeedLimit(withCompletion completion: @escaping (String?, Error?) -> Void) {
        let urlString = "https://overpass-api.de/api/interpreter?data=[out:json];way[maxspeed](around:100,\(latitude),%20\(longitude));out%20tags;"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion(nil, error)
            } else if let data = data {
                do {
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
    
    func determineLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        latitude = String(userLocation.coordinate.latitude)
        longitude = String(userLocation.coordinate.longitude)
        
        //        print("user latitude = \(userLocation.coordinate.latitude)")
        //        print("user longitude = \(userLocation.coordinate.longitude)")
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



