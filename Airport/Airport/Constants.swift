//
//  Constants.swift
//  Airport
//
//  Created by Christopher Webb-Orenstein on 10/15/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import Foundation
import SceneKit

struct LocationConstants {
    static let metersPerRadianLat: Double = 6373000.0
    static let metersPerRadianLon: Double = 5602900.0
}



extension float4x4 {
    
    public func toMatrix() -> SCNMatrix4 {
        return SCNMatrix4(self)
    }
    
    public var translation4: SCNVector4 {
        get {
            return SCNVector4(columns.3.x, columns.3.y, columns.3.z, columns.3.w)
        }
    }
}
