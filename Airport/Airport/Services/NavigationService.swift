//
//  NavigationService.swift
//  Airport
//
//  Created by Christopher Webb-Orenstein on 10/14/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import MapKit

struct NavigationService {
    
    func getDirections(destinationLocation: CLLocationCoordinate2D, request: MKDirectionsRequest, completion: @escaping ([MKRouteStep]) -> Void) {
        var steps: [MKRouteStep] = []
        
        let placeMark = MKPlacemark(coordinate: destinationLocation)
        
        request.destination = MKMapItem.init(placemark: placeMark)
        request.source = MKMapItem.forCurrentLocation()
        request.requestsAlternateRoutes = false
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            if error != nil {
                print("Error getting directions")
            } else {
                guard let response = response else { return }
                for route in response.routes {
                    steps.append(contentsOf: route.steps)
                }
                completion(steps)
            }
        }
    }
}
