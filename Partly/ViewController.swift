//
//  ViewController.swift
//  Partly
//
//  Created by Bradan Jackson on 9/28/14.
//  Copyright (c) 2014 Bradan Jackson. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //current location
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    var locationManager: CLLocationManager!
    var userLocation : String!
    var userLatitude : Double!
    var userLongitude : Double!
    var placemarks : CLPlacemark!
    var locationAsText :String!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    
    //Background Colors
    let colorGray = UIColor(red: 77/255.0, green: 75/255.0, blue: 82/255.0, alpha: 1.0)
    let colorPurple = UIColor(red: 105/255.0, green: 94/255.0, blue: 133/255.0, alpha: 1.0)
    let colorBlue = UIColor(red: 80/255.0, green: 160/255.0, blue: 200/255.0, alpha:1.0)
    let colorTeal = UIColor(red: 90/255.0, green: 187/255.0, blue: 181/255.0, alpha: 1.0)
    let colorGreen = UIColor(red: 85/255.0, green: 176/255.0, blue: 112/255.0, alpha: 1.0)
    let colorYellow = UIColor(red: 222/255.0, green: 171/255.0, blue: 66/255.0, alpha: 1.0)
    let colorOrange = UIColor(red: 239/255.0, green: 130/255.0, blue: 100/255.0, alpha: 1.0)
    let colorRed = UIColor(red: 223/255.0, green: 86/255.0, blue: 94/255.0, alpha: 1.0)
    
    //current weather
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    
    //Private API Key
    private let apiKey = "d3c3dac75108e22030391d46dce2ab8b"

    //View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.hidden = true
        initLocationManager()
    }
    
    //Location Code
    func initLocationManager() {
        seenError = false
        locationFixAchieved = false
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            if (seenError == false) {
                seenError = true
                print(error)
            }
        }
    }
    
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //ReverseGeoCoder with error handler
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                println("Reverse Geocoder Failed" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                println("Geocoder Error")
            }
            
            return
            
        })
        
        //Format User Location and Call Weather Function
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            var locationArray = locations as NSArray
            var locationObj = locationArray.lastObject as CLLocation
            var coord = locationObj.coordinate
            
            //println(coord.latitude)
            //println(coord.longitude)
            
            self.userLatitude = coord.latitude
            self.userLongitude = coord.longitude
            
            println(userLocation)
            
            getCurrentWeatherData()
            
        }
    }
    
    //Bring Up Local Name for Coordinates
    func displayLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            println(locality)
            println(administrativeArea)
            
            if locality != "" {
                locationLabel.text = locality + ", " + administrativeArea
            } else {
                locationLabel.text = administrativeArea
            }
        }
    }
    
    
    //Location Authorization
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            var shouldIAllow = false
            
            switch status {
            case CLAuthorizationStatus.Restricted:
                locationStatus = "Restricted Access to location"
            case CLAuthorizationStatus.Denied:
                locationStatus = "User denied access to location"
            case CLAuthorizationStatus.NotDetermined:
                locationStatus = "Status not determined"
            default:
                locationStatus = "Allowed to location Access"
                shouldIAllow = true
            }
            NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
            if (shouldIAllow == true) {
                NSLog("Location to Allowed")
                // Start location services
                locationManager.startUpdatingLocation()
            } else {
                NSLog("Denied access: \(locationStatus)")
            }
    }
    
    func stopThePresses() {
        //stop refresh animation
        self.refreshActivityIndicator.stopAnimating()
        self.refreshActivityIndicator.hidden = true
    }
    
    func startThePresses(){
        temperatureLabel.text = "00"
        refreshActivityIndicator.hidden = false
        refreshActivityIndicator.startAnimating()
    }
    
    //Call to API
    func getCurrentWeatherData() -> Void{
        
        userLocation = "\(userLatitude),\(userLongitude)"
        
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")
        
        let forecastURL = NSURL(string: "\(userLocation)", relativeToURL: baseURL)
        
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler: { (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
            
            
            if (error == nil){
                let dataObject = NSData(contentsOfURL: location)
                let weatherDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObject!, options: nil, error: nil) as NSDictionary
                
                
                let currentWeather = Current(weatherDictionary: weatherDictionary)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.view.hidden = false
                    
                    //set labels and background color
                    self.temperatureLabel.text = "\(currentWeather.temperature)"
                    self.minTempLabel.text = "\(currentWeather.temperatureMin)"
                    self.maxTempLabel.text = "\(currentWeather.temperatureMax)"
                    
                    let temp = currentWeather.temperature
                    
                    if (temp <= 32) {
                        self.view.backgroundColor = self.colorGray
                    } else if (temp > 32 && temp <= 45) {
                        self.view.backgroundColor = self.colorBlue
                    } else if (temp > 45 && temp <= 60) {
                        self.view.backgroundColor = self.colorTeal
                    } else if (temp > 60 && temp <= 70) {
                        self.view.backgroundColor = self.colorGreen
                    } else if (temp > 70 && temp <= 75) {
                        self.view.backgroundColor = self.colorYellow
                    } else if (temp > 75 && temp <= 85) {
                        self.view.backgroundColor = self.colorOrange
                    } else if (temp > 85) {
                        self.view.backgroundColor = self.colorRed
                    }
                    
                    self.iconView.image = currentWeather.icon!
                    
                    func percent(a: Double) -> String {
                        let decimal = a
                        let percentage = a * 100
                        let percentageIntValue = Int(percentage)
                        println(percentageIntValue)
                        let percentageForLabel: String = "\(percentageIntValue)" + "%"
                        
                        return percentageForLabel
                    }
                    
                    self.humidityLabel.text = "\(percent(currentWeather.humidity))"
                    self.precipitationLabel.text = "\(percent(currentWeather.precipProbability))"
                    self.summaryLabel.text = "\(currentWeather.summary)"
                    
                    //stop refresh animation
                    self.stopThePresses()
                })
            } else {
                let networkIssueController = UIAlertController(title: "Error", message: "Unable to load data. Connectivity Error.", preferredStyle: .Alert)
                
                let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                networkIssueController.addAction(okButton)
                
                let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                networkIssueController.addAction(cancelButton)
                
                self.presentViewController(networkIssueController, animated: true, completion: nil)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //stop refresh animation
                    self.stopThePresses()
                })
            }
        })
        downloadTask.resume()
    }
    
    @IBAction func refresh(sender: AnyObject) {
        self.startThePresses()
        initLocationManager()
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

