//
//  PlaneSceneView.swift
//  Airport
//
//  Created by Christopher Webb-Orenstein on 10/14/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import ARKit
import SceneKit
import CoreLocation

class PlaneSceneView: ARSCNView {
    
    var airportNode: SCNNode!
    var planeNode: SCNNode!
    var bodyNode: SCNNode!
    var engineNode: SCNNode!
    var nodes: [SCNNode] = []
    var markerOne: SCNNode!
    var markerTwo: SCNNode!
    
    func setupScene() {
        scene = SCNScene()
        airportNode = nodeWithModelName("art.scnassets/airfield.scn")
        planeNode = nodeWithModelName( "art.scnassets/spitfire4.dae")
    }
    
    func setupPlane() {
        scene.rootNode.addChildNode(planeNode)
        bodyNode = planeNode.childNode(withName: "Body", recursively: true)
        engineNode = bodyNode.childNode(withName: "Propeller", recursively: true)
        planeNode.scale = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        startEngine()
    }
    
    func startEngine() {
        let rotate = SCNAction.rotateBy(x: 0, y: 0, z: 82, duration: 0.25)
        let moveSequence = SCNAction.sequence([rotate])
        let moveLoop = SCNAction.repeatForever(moveSequence)
        self.engineNode.runAction(moveLoop, forKey: "engine")
    }
    
    func positionAirport(node: SCNNode, anchor: ARPlaneAnchor?=nil) {
        if let anchor = anchor {
            self.airportNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        }
        self.markerOne = self.airportNode.childNode(withName: "markerOne", recursively: true)
        self.markerTwo = self.airportNode.childNode(withName: "markerTwo", recursively: true)
        self.scene.rootNode.addChildNode(self.airportNode!)
        if let anchor = anchor {
            self.airportNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        }
        self.setupPlane()
        self.planeNode.position = SCNVector3(self.airportNode.position.x - 0.005, self.markerOne.position.y - 0.285, self.markerTwo.position.z + 0.5)
        self.planeNode.orientation = self.airportNode.orientation
    }
    
    func moveForward() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 4
        planeNode.localTranslate(by: SCNVector3(x: 0, y: 0, z: -1.25))
        SCNTransaction.commit()
    }
    
    func moveForwardUp() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 4
        planeNode.localTranslate(by: SCNVector3(x: 0, y: 0, z: -0.45))
        let (x, y, z, w) = self.angleConversion(x: 0.25 * Float(Double.pi), y: 0, z: 0, w: 0)
        self.planeNode.localRotate(by: SCNQuaternion(x, y, z, w))
        self.planeNode.localTranslate(by: SCNVector3(x: 0, y: 0, z: -0.55))
        SCNTransaction.commit()
    }
    
    func takeOffFrom(location: CLLocation, for destination: CLLocation, with legs: [[CLLocationCoordinate2D]]) {
        var rotated = false
        for (index, leg) in legs.enumerated() {
            if index == 0 {
                self.moveForward()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.moveForwardUp()
                }
            }
            
            for (ind, coordinate) in leg.enumerated() {
                if ind == 0 {
                    if !rotated {
                        var bearingTo = 0.0
                        for rotation in 0..<8 {
                            DispatchQueue.global().asyncAfter(deadline: .now() + 6.0) {
                                let firstLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                let bearing = location.bearingToLocationRadian(firstLocation)
                                bearingTo += bearing / 8
                                self.rotateFromBearing(bearing: bearingTo, for: location, and: firstLocation, count: rotation)
                            }
                        }
                        rotated = true
                    }
                }
            }
        }
    }
    
    func rotateFromBearing(bearing: Double, for origin: CLLocation, and destination: CLLocation, count: Int) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 5
        print(bearing)
        // bearing negative good
        let (x, y, z, w) = angleConversion(x: Float(-1 * (bearing)), y:Float(-1 * (bearing)), z: -0.5, w: 0)
        planeNode.localRotate(by: SCNQuaternion(x: x, y: y, z: z, w: w))
        SCNTransaction.commit()
        // planeNode.eulerAngles = SCNVector3Make(0, Float(-1 * (bearing)), 1)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 5
        self.planeNode.localTranslate(by: SCNVector3(x: 0, y: 0, z: -0.5))
        SCNTransaction.commit()
    }
    
    func moveFrom(origin: CLLocation, to destination: CLLocation) {
        
        SCNTransaction.begin()
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        SCNTransaction.animationDuration = 6000
        let translation = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: origin, location: destination)
        let position = SCNVector3.positionFromTransform(translation)
        self.planeNode.position = position
        SCNTransaction.commit()
    }
    
    func angleConversion(x: Float, y: Float, z: Float, w: Float) -> (Float, Float, Float, Float) {
        let c1 = cos( x / 2 )
        let c2 = cos( y / 2 )
        let c3 = cos( z / 2 )
        let s1 = sin( x / 2 )
        let s2 = sin( y / 2 )
        let s3 = sin( z / 2 )
        let xF = s1 * c2 * c3 + c1 * s2 * s3
        let yF = c1 * s2 * c3 - s1 * c2 * s3
        let zF = c1 * c2 * s3 + s1 * s2 * c3
        let wF = c1 * c2 * c3 - s1 * s2 * s3
        return (xF, yF, zF, wF)
    }
}
