//
//  ViewController.swift
//  Airport
//
//  Created by Christopher Webb-Orenstein on 10/12/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MapKit
import CoreLocation

class AirportViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var dismissMapButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var sceneView: PlaneSceneView!
    
    var locationService = LocationService()
    var startingLocation: CLLocation!
    var destinationLocation: CLLocation!
    var airportPlaced: Bool = false
    var planeCanFly: Bool = false
    var mapDismissed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        runSession()
        sceneView.setupScene()
        destinationLocation = CLLocation(latitude: 40.737359, longitude: -73.979086)
        locationService.delegate = self
        sceneView.setupAirport()
        sceneView.setupPlane()
        locationService.startUpdatingLocation(locationManager: locationService.locationManager!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func runSession() {
        sceneView.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
    }
}

extension AirportViewController: ARSCNViewDelegate {
    
    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !self.airportPlaced {
            DispatchQueue.main.async {
                if let planeAnchor = anchor as? ARPlaneAnchor {
                    let planeNode = createPlaneNode(center: planeAnchor.center, extent: planeAnchor.extent)
                    node.addChildNode(planeNode)
                    self.sceneView.positionAirport(node: node)
                    self.airportPlaced = true
                }
            }
        } else {
            print("airport placed")
        }
    }
}

extension AirportViewController: MessagePresenting {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if airportPlaced && planeCanFly {
            sceneView.moveForward()
            sceneView.moveForward()
            sceneView.moveForward()
            sceneView.takeOffFrom(location: startingLocation, for: destinationLocation)
        } else if !airportPlaced {
            presentMessage(title: "Still Building Airport...", message: "Looks like we're still building the airport. Try moving your phone to speed up the process.")
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        presentMessage(title: "Error", message: error.localizedDescription)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        presentMessage(title: "Pardon The Interruption", message: "We've had some technical difficulties.")
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func dismissMapTapped(_ sender: Any) {
        mapView.isHidden = !mapDismissed
        mapDismissed = !mapDismissed
        view.layoutIfNeeded()
    }
}

extension AirportViewController: LocationServiceDelegate {
    
    func trackingLocation(for currentLocation: CLLocation) {
        startingLocation = currentLocation
        planeCanFly = true
    }
    
    func trackingLocationDidFail(with error: Error) {
        print(error.localizedDescription)
    }
}
