//
//  CLLocationCoordinate2D+Extension.swift
//  Airport
//
//  Created by Christopher Webb-Orenstein on 10/15/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
//    public static func <(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
//        let leftLocation = CLLocation(latitude: lhs.latitude, longitude: lhs.longitude)
//        let rightLocation  CLLocation(latitude: rhs.latitude, longitude:)
//        return
//    }
//
    func bearingToLocationRadian(_ destinationLocation: CLLocationCoordinate2D) -> Double {
        
        let lat1 = latitude.toRadians()
        let lon1 = longitude.toRadians()
        let lat2 = destinationLocation.latitude.toRadians()
        let lon2 = destinationLocation.longitude.toRadians()
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        return radiansBearing
    }
    
    func calculateDirection(to coordinate: CLLocationCoordinate2D) -> Double {
        let a = sin(coordinate.longitude.toRadians() - longitude.toRadians()) * cos(coordinate.latitude.toRadians())
        let dLat = cos(latitude.toRadians()) * sin(coordinate.latitude.toRadians()) - sin(latitude.toRadians())
        let dLon = cos(coordinate.latitude.toRadians()) * cos(coordinate.longitude.toRadians() - longitude.toRadians())
        let b =  dLat * dLon
        return atan2(a, b)
    }
    
    func direction(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection {
        return self.calculateDirection(to: coordinate).toDegrees()
    }
    
    func coordinate(with bearing: Double, and distance: Double) -> CLLocationCoordinate2D {
        let distRadiansLat = distance / LocationConstants.metersPerRadianLat  // earth radius in meters latitude
        let distRadiansLong = distance / LocationConstants.metersPerRadianLon // earth radius in meters longitude
        let lat1 = self.latitude.toRadians()
        let lon1 = self.longitude.toRadians()
        let lat2 = asin(sin(lat1) * cos(distRadiansLat) + cos(lat1) * sin(distRadiansLat) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadiansLong) * cos(lat1), cos(distRadiansLong) - sin(lat1) * sin(lat2))
        return CLLocationCoordinate2D(latitude: lat2.toDegrees(), longitude: lon2.toDegrees())
    }
    
    static func getIntermediaryLocations(currentLocation: CLLocation, destinationLocation: CLLocation) -> [CLLocationCoordinate2D] {
        var distances = [CLLocationCoordinate2D]()
        let metersIntervalPerNode: Float = 10
        var distance = Float(destinationLocation.distance(from: currentLocation))
        let bearing = currentLocation.bearingToLocationRadian(destinationLocation)
        while distance > 10 {
            distance -= metersIntervalPerNode
            let newLocation = currentLocation.coordinate.coordinate(with: Double(bearing), and: Double(distance))
            if !distances.contains(newLocation) {
                distances.append(newLocation)
            }
        }
        return distances
    }
    
    static func getIntermediaryLocations2(currentLocation: CLLocation, destinationLocation: CLLocation) -> [CLLocationCoordinate2D] {
        var distances = [CLLocationCoordinate2D]()
        let metersIntervalPerNode: Float = 0.6
        var distance = Float(destinationLocation.distance(from: currentLocation))
        let bearing = currentLocation.bearingToLocationRadian(destinationLocation)
        while distance > 0.6 {
            distance -= metersIntervalPerNode
            let newLocation = currentLocation.coordinate.coordinate(with: Double(bearing), and: Double(distance))
            print(newLocation)
            if !distances.contains(newLocation) {
                distances.append(newLocation)
            }
        }
        return distances
    }
}
