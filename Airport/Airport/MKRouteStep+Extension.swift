//
//  MKRouteStep+Extension.swift
//  Airport
//
//  Created by Christopher Webb-Orenstein on 10/15/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import MapKit

// Get a CLLocation from a route step

extension MKRouteStep {
    func getLocation() -> CLLocation {
        return CLLocation(latitude: polyline.coordinate.latitude, longitude: polyline.coordinate.longitude)
    }
}
