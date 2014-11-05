//
//  Current.swift
//  Partly
//
//  Created by Bradan Jackson on 9/28/14.
//  Copyright (c) 2014 Bradan Jackson. All rights reserved.
//

import Foundation
import UIKit

struct Current {
    
    var currentTime: String?
    var temperature: Int
    var temperatureMin: Int
    var temperatureMax: Int
    var humidity: Double
    var precipProbability: Double
    var summary: String
    var icon: UIImage?
    
    init(weatherDictionary: NSDictionary){
        let currentWeather = weatherDictionary["currently"] as NSDictionary
        let dailyWeather = weatherDictionary["daily"] as NSDictionary
        let dailyWeatherArray = dailyWeather["data"] as NSArray
        let dailyWeatherDictionary: NSDictionary = dailyWeatherArray[0] as NSDictionary
        println(dailyWeatherArray)
        
        
        temperature = currentWeather["temperature"] as Int
        temperatureMin = dailyWeatherDictionary["temperatureMin"] as Int
        temperatureMax = dailyWeatherDictionary["temperatureMax"] as Int
        
        
        humidity = currentWeather["humidity"] as Double
        precipProbability = currentWeather["precipProbability"] as Double
        summary = currentWeather["summary"] as String
        
        let currentTimeIntValue = currentWeather["time"] as Int
        
        let iconString = currentWeather["icon"] as String
        icon =  weatherIconFromString(iconString)
        
        currentTime = dateStringFromUnixTime(currentTimeIntValue)
    }
    
    func dateStringFromUnixTime(unixTime: Int) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter.stringFromDate(weatherDate)
    }
    
    func weatherIconFromString (stringIcon: String) -> UIImage {
        var imageName: String
        
        switch stringIcon {
        case "clear-day":
            imageName = "clear-day"
        case "clear-night":
            imageName = "clear-night"
        case "rain":
            imageName = "rain"
        case "snow":
            imageName = "snow"
        case "sleet":
            imageName = "sleet"
        case "wind":
            imageName = "wind"
        case "fog":
            imageName = "fog"
        case "cloudy":
            imageName = "cloudy"
        case "partly-cloudy-day":
            imageName = "partly-cloudy"
        case "partly-cloudy-night":
            imageName = "cloudy-night"
        default:
            imageName = "default"
        }
        
        var iconImage = UIImage(named: imageName)
        return iconImage!
    }
    
    
    
    
}
