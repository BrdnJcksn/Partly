//
//  daily.swift
//  Partly
//
//  Created by Bradan Jackson on 10/15/14.
//  Copyright (c) 2014 Bradan Jackson. All rights reserved.
//

import Foundation
import UIKit

struct Daily {
    
    init(dailyDictionary: NSDictionary){
        let dailyWeather = dailyDictionary["data"]
        
        //let dailyTimeIntValue = dailyWeather["time"] as Int
        //let dailyTempMinTimeInt = dailyWeather["temperatureMinTime"] as Int
        //let dailyTempMaxTimeInt = dailyWeather["temperatureMaxTime"] as Int
    }
    
    func dateStringFromUnixTime(unixTime: Int) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter.stringFromDate(weatherDate)
    }
}
