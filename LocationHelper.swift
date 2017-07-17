//
//  LocationHelper.swift
//
//  Created by Harit Kothari on 06/12/16.
//  Copyright © 2016 Simform. All rights reserved.
//

import UIKit
import CoreLocation

class LocationHelper: NSObject {
    override private init() { }
    
    static let sharedInstance : LocationHelper = {
        let instance = LocationHelper()
        return instance
    }()
    
    func distance(fromLocationPoint: CLLocationCoordinate2D, toLocationPoint: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: fromLocationPoint.latitude, longitude: fromLocationPoint.longitude)
        let toLocation = CLLocation(latitude: toLocationPoint.latitude, longitude: toLocationPoint.longitude)
        
        let distance:CLLocationDistance = fromLocation.distance(from: toLocation)
        
        var distanceInKM:Double = -1
        if distance.isFinite {
            distanceInKM = distance/1000.0
        }
        
        return distanceInKM
    }
}
