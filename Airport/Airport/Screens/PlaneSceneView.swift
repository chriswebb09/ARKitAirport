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
    
    func setupAirport() {
        airportNode = nodeWithModelName("art.scnassets/airfield.scn")
    }
    
    func positionAirport(position: SCNVector3) {
        DispatchQueue.main.async {
            self.airportNode.position = position
            self.scene.rootNode.addChildNode(self.airportNode)
        }
    }
    
    func positionAirport(node: SCNNode) {
        DispatchQueue.main.async {
            self.airportNode.position = node.position
            self.markerOne = self.airportNode.childNode(withName: "markerOne", recursively: true)
            self.planeNode.position = node.position
            for airplaneNode in self.nodes {
                airplaneNode.position = node.position
            }
            node.addChildNode(self.airportNode)
        }
    }
    
    func setupScene() {
        scene = SCNScene()
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
    
    func stopEngine() {
        engineNode.runAction(SCNAction.rotateBy(x: 0, y: 0, z: -85, duration: 0.5), forKey: "engine")
        engineNode.removeAnimation(forKey: "engine")
    }
    
    func moveForward() {
        DispatchQueue.main.async {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 5
            self.planeNode.position = SCNVector3(self.planeNode.position.x, self.planeNode.position.y, self.planeNode.position.z - 6)
            SCNTransaction.commit()
        }
    }
    
    func takeOffFrom(location: CLLocation, for destination: CLLocation) {
        let bearing = location.bearingToLocationRadian(destination)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        self.planeNode.position = SCNVector3(self.planeNode.position.x, self.planeNode.position.y, self.planeNode.position.z - 0.01)
        self.planeNode.position = SCNVector3(self.planeNode.position.x, self.planeNode.position.y, self.planeNode.position.z - 0.1)
        self.planeNode.position = SCNVector3(self.planeNode.position.x, self.planeNode.position.y, self.planeNode.position.z - 0.5)
        SCNTransaction.completionBlock = {
            self.rotateFromBearing(bearing: bearing, for: location, and: destination)
        }
        SCNTransaction.commit()
    }
    
    func rotateFromBearing(bearing: Double, for origin: CLLocation, and destination: CLLocation) {
        DispatchQueue.main.async {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1
            SCNTransaction.completionBlock = {
                self.moveFrom(origin: origin, to: destination)
            }
            
            for node in self.nodes {
                let rotation = SCNMatrix4MakeRotation(Float(-1 * bearing), 0, 1, 0)
                node.transform = SCNMatrix4Mult(node.transform, rotation)
            }
            
            SCNTransaction.commit()
        }
    }
    
    func moveFrom(origin: CLLocation, to destination: CLLocation) {
        print("Distance: \(origin.distance(from: destination))")
        DispatchQueue.main.async {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 20
            let translation = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: origin, location: destination)
            let position = SCNVector3.positionFromTransform(translation)
            for node in self.nodes {
                node.position = position
            }
            SCNTransaction.commit()
        }
    }
}
