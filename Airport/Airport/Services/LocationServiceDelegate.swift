//
//  LocationServiceDelegate.swift
//  Airport
//
//  Created by Christopher Webb-Orenstein on 10/15/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate: class {
    func trackingLocation(for currentLocation: CLLocation)
    func trackingLocationDidFail(with error: Error)
}
