//
//  Speed.swift
//  Airport
//
//  Created by Christopher Webb-Orenstein on 10/15/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import Foundation

struct Speed {
    
    // Speed = Distance ÷ Time
    
    func getSpeed(for distance: Double, and time: Double) -> Double {
        return distance / time
    }
    
    // Time = Distance ÷ Speed
    
    func getTime(for distance: Double, and speed: Double) -> Double {
        return distance / speed
    }
    
    // Distance = Speed × Time
    
    func getDistance(speed: Double, and time: Double) -> Double {
        return speed * time
    }
}
