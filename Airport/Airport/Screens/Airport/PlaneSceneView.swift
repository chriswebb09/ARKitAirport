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
    var rearNode:SCNNode!
    var engineNode: SCNNode!
    var leftWing: SCNNode!
    var rightWing: SCNNode!
    var wheelSupport: SCNNode!
    var landingLight: SCNNode!
    var cockpit: SCNNode!
    var bodyFront: SCNNode!
    var glass: SCNNode!
    var pilot: SCNNode!
    var reflect: SCNNode!
    var nodes: [SCNNode] = []
    var markerOne: SCNNode!
    var markerTwo: SCNNode!
    
    func setupScene() {
        scene = SCNScene()
        airportNode = nodeWithModelName("art.scnassets/airfield.scn")
        setupPlane()
    }
    
    func setupPlane() {
        planeNode = nodeWithModelName( "art.scnassets/rafspitefire.scn")
        scene.rootNode.addChildNode(planeNode)
        engineNode = planeNode.childNode(withName: "engine", recursively: false)
        bodyFront = planeNode.childNode(withName: "body_front", recursively: false)
        leftWing = planeNode.childNode(withName: "left_wing", recursively: false)
        rightWing = planeNode.childNode(withName: "right_wing", recursively: false)
        cockpit = planeNode.childNode(withName: "cockpit", recursively: false)
        rearNode = planeNode.childNode(withName: "rear", recursively: false)
        pilot = planeNode.childNode(withName: "pilot", recursively: false)
        glass = planeNode.childNode(withName: "glass", recursively: false)
        landingLight = planeNode.childNode(withName: "landing_light", recursively: false)
        wheelSupport = planeNode.childNode(withName: "wheel_support", recursively: false)
        reflect = planeNode.childNode(withName: "reflect", recursively: false)
        nodes = [planeNode, engineNode, bodyFront, leftWing, rightWing, cockpit, rearNode, pilot, glass, landingLight, wheelSupport, reflect]
        startEngine()
    }
    
    func startEngine() {
        DispatchQueue.main.async {
            let rotate = SCNAction.rotateBy(x: 0, y: 0, z: 82, duration: 0.5)
            let moveSequence = SCNAction.sequence([rotate])
            let moveLoop = SCNAction.repeatForever(moveSequence)
            self.engineNode.runAction(moveLoop, forKey: "engine")
        }
    }
    
    func positionAirport(node: SCNNode) {
        DispatchQueue.main.async {
            self.airportNode.position = node.position
            self.markerOne = self.airportNode.childNode(withName: "markerOne", recursively: true)
            self.markerTwo = self.airportNode.childNode(withName: "markerTwo", recursively: true)
            self.planeNode.position = node.position
            for airplaneNode in self.nodes {
                airplaneNode.position = node.position
            }
            node.addChildNode(self.airportNode)
        }
    }
    
    func moveForward() {
        DispatchQueue.main.async {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 5
            self.planeNode.position = SCNVector3(self.planeNode.position.x, self.planeNode.position.y, self.planeNode.position.z - 6)
            SCNTransaction.commit()
        }
    }
    
    func takeOffFrom(location: CLLocation, for destination: CLLocation, with legs: [[CLLocationCoordinate2D]]) {
        engineNode.isHidden = true
        let speed = Speed()
        dump(legs)
        for (index, leg) in legs.enumerated() {
            if index == 0 {
                print(0)
                moveForward()
                moveForward()
                moveForward()
                moveForward()
                for coordinate in leg {
                    DispatchQueue.main.async {
                        SCNTransaction.begin()
                        var firstLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        let distance = location.distance(from: firstLocation)
                        let bearing = location.bearingToLocationRadian(firstLocation)
                        self.rotateFromBearing(bearing: bearing, for: location, and: firstLocation)
                        SCNTransaction.animationDuration = speed.getTime(for: distance, and: 20)
                        let translation = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: location, location: firstLocation)
                        let position = SCNVector3.positionFromTransform(translation)
                        for node in self.nodes {
                            node.position = position
                        }
                        self.planeNode.position = position
                        SCNTransaction.commit()
                    }
                }
            } else {
                for (index, coordinate) in leg.enumerated() {
                    DispatchQueue.main.async {
                        SCNTransaction.begin()
                        var firstLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        let distance = location.distance(from: firstLocation)
                        let bearing = location.bearingToLocationRadian(firstLocation)
                        self.rotateFromBearing(bearing: bearing, for: location, and: firstLocation)
                        SCNTransaction.animationDuration = speed.getTime(for: distance, and: 20)
                        let translation = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: location, location: firstLocation)
                        let position = SCNVector3.positionFromTransform(translation)
                        for node in self.nodes {
                            node.position = position
                        }
                        self.planeNode.position = position
                        SCNTransaction.commit()
                    }
                }
            }
        }
    }
    
    
    
    func rotateFromBearing(bearing: Double, for origin: CLLocation, and destination: CLLocation) {
        DispatchQueue.main.async {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1
            for node in self.nodes {
                let rotation = SCNMatrix4MakeRotation(Float(-1 * bearing), 0, 1, 0)
                node.transform = SCNMatrix4Mult(node.transform, rotation)
            }
            
            SCNTransaction.completionBlock = {
                self.moveFrom(origin: origin, to: destination)
            }
            SCNTransaction.commit()
        }
    }
    
    func moveFrom(origin: CLLocation, to destination: CLLocation) {
        let speed = Speed()
        DispatchQueue.main.async {
            SCNTransaction.begin()
            let distance = origin.distance(from: destination)
            SCNTransaction.animationDuration = speed.getTime(for: distance, and: 20)
            print(speed.getTime(for: distance, and: 20))
            let translation = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: origin, location: destination)
            let position = SCNVector3.positionFromTransform(translation)
            for node in self.nodes {
                node.position = position
            }
            self.planeNode.position = position
            SCNTransaction.commit()
        }
    }
}
