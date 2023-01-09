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
    var planeGone = false
    var locationService = LocationService()
    var navigationService: NavigationService = NavigationService()
    private var annotationColor = UIColor.blue
    internal var annotations: [POIAnnotation] = []
    
    @IBOutlet weak var stackviewTopConstraint: NSLayoutConstraint!
    private var currentTripLegs: [[CLLocationCoordinate2D]] = []
    private var steps: [MKRouteStep] = []
    
    private var locations: [CLLocation] = []
    var startingLocation: CLLocation!
    
    var destinationLocation: CLLocation! {
        didSet {
            setupNavigation()
        }
    }
    
    var press: UILongPressGestureRecognizer!
    var airportPlaced: Bool = false
    var planeCanFly: Bool = false
    var mapDismissed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        runSession()
        sceneView.setupScene()
        locationService.delegate = self
        locationService.startUpdatingLocation(locationManager: locationService.locationManager!)
        press = UILongPressGestureRecognizer(target: self, action: #selector(handleMapTap(gesture:)))
        press.minimumPressDuration = 0.35
        mapView.addGestureRecognizer(press)
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusLabel.text = "Getting status"
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
        
        if !self.airportPlaced, let planeAnchor = anchor as? ARPlaneAnchor {
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeMaterial = SCNMaterial()
            planeMaterial.diffuse.contents = UIColor.clear.withAlphaComponent(0.0)
            plane.materials = [planeMaterial]
            let planeNode = SCNNode(geometry: plane)
            planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
            
            sceneView.positionAirport(node: planeNode, anchor: planeAnchor)
            node.addChildNode(planeNode)
            self.airportPlaced = true
            DispatchQueue.main.async {
                self.statusLabel.text = "Airport is placed"
            }
        }
    }
}

extension AirportViewController: MessagePresenting {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if airportPlaced && planeCanFly {
            if !planeGone {
                sceneView.takeOffFrom(location: startingLocation, for: destinationLocation, with: currentTripLegs)
                planeGone = true
                statusLabel.text = "Plane is taking off"
            }
            
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
        presentMessage(title: "Interruption Ended", message: "Interruption Ended")
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
        centerMapInInitialCoordinates()
    }
    
    func trackingLocationDidFail(with error: Error) {
        presentMessage(title: "Error", message: error.localizedDescription)
    }
}

extension AirportViewController: Mapable {
    
    @objc func handleMapTap(gesture: UIGestureRecognizer) {
        if gesture.state != UIGestureRecognizerState.began {
            return
        }
        // Get tap point on map
        let touchPoint = gesture.location(in: mapView)
        
        // Convert map tap point to coordinate
        let coord: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        destinationLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        planeCanFly = true
    }
}

extension AirportViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor.black.withAlphaComponent(0.1)
            renderer.strokeColor = annotationColor
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    private func setupNavigation() {
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .background).async {
            if self.destinationLocation != nil {
                self.navigationService.getDirections(destinationLocation: self.destinationLocation.coordinate, request: MKDirectionsRequest()) { steps in
                    for step in steps {
                        self.annotations.append(POIAnnotation(coordinate: step.getLocation().coordinate, name: "N " + step.instructions))
                    }
                    self.steps.append(contentsOf: steps)
                    group.leave()
                }
            }
            // All steps must be added before moving to next step
            group.wait()
            self.getLocationData()
        }
    }
    
    func setTripLegs() {
        for (index, step) in steps.enumerated() {
            setTripLegFromStep(step, and: index)
        }
    }
    
    func updateIntermediaryLegs() {
        for leg in currentTripLegs {
            update(intermediary: leg)
        }
    }
    
    private func getLocationData() {
        setTripLegs()
        updateIntermediaryLegs()
        DispatchQueue.main.async {
            self.centerMapInInitialCoordinates()
            self.showPointsOfInterestInMap(currentTripLegs: self.currentTripLegs)
            self.addMapAnnotations()
            self.mapView.isHidden = !self.mapDismissed
            self.mapDismissed = !self.mapDismissed
            if self.mapDismissed {
                self.stackviewTopConstraint.constant = 500
            } else {
                self.stackviewTopConstraint.constant = - 300
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    // Gets coordinates between two locations at set intervals
    private func setLeg(from previous: CLLocation, to next: CLLocation) -> [CLLocationCoordinate2D] {
        return CLLocationCoordinate2D.getIntermediaryLocations2(currentLocation: previous, destinationLocation: next)
    }
    
    // Add POI dots to map
    private func showPointsOfInterestInMap(currentTripLegs: [[CLLocationCoordinate2D]]) {
        mapView.removeAnnotations(mapView.annotations)
        for tripLeg in currentTripLegs {
            for coordinate in tripLeg {
                DispatchQueue.main.async {
                    let poi = POIAnnotation(coordinate: coordinate, name: String(describing: coordinate))
                    self.mapView.addAnnotation(poi)
                }
            }
        }
    }
    
    // Adds calculated distances to annotations and locations arrays
    private func update(intermediary locations: [CLLocationCoordinate2D]) {
        for intermediaryLocation in locations {
            annotations.append(POIAnnotation(coordinate: intermediaryLocation, name: String(describing:intermediaryLocation)))
            self.locations.append(CLLocation(latitude: intermediaryLocation.latitude, longitude: intermediaryLocation.longitude))
        }
    }
    
    // Determines whether leg is first leg or not and routes logic accordingly
    private func setTripLegFromStep(_ tripStep: MKRouteStep, and index: Int) {
        if index > 0 {
            getTripLeg(for: index, and: tripStep)
        } else {
            getInitialLeg(for: tripStep)
        }
    }
    
    // Calculates intermediary coordinates for route step that is not first
    private func getTripLeg(for index: Int, and tripStep: MKRouteStep) {
        let previousIndex = index - 1
        let previousStep = steps[previousIndex]
        let previousLocation = CLLocation(latitude: previousStep.polyline.coordinate.latitude, longitude: previousStep.polyline.coordinate.longitude)
        let nextLocation = CLLocation(latitude: tripStep.polyline.coordinate.latitude, longitude: tripStep.polyline.coordinate.longitude)
        let intermediarySteps = CLLocationCoordinate2D.getIntermediaryLocations(currentLocation: previousLocation, destinationLocation: nextLocation)
        currentTripLegs.append(intermediarySteps)
    }
    
    // Calculates intermediary coordinates for first route step
    private func getInitialLeg(for tripStep: MKRouteStep) {
        let nextLocation = CLLocation(latitude: tripStep.polyline.coordinate.latitude, longitude: tripStep.polyline.coordinate.longitude)
        let intermediaries = CLLocationCoordinate2D.getIntermediaryLocations(currentLocation: startingLocation, destinationLocation: nextLocation)
        currentTripLegs.append(intermediaries)
    }
    
    // Prefix N is just a way to grab step annotations, could definitely get refactored
    private func addMapAnnotations() {
        
        annotations.forEach { annotation in
            
            // Step annotations are green, intermediary are blue
            DispatchQueue.main.async {
                if let title = annotation.title, title.hasPrefix("N") {
                    self.annotationColor = .green
                } else {
                    self.annotationColor = .blue
                }
                self.mapView?.addAnnotation(annotation)
                self.mapView.add(MKCircle(center: annotation.coordinate, radius: 0.2))
            }
        }
    }
}
