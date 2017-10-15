//
//  Helpers.swift
//  Airport
//
//  Created by Christopher Webb-Orenstein on 10/14/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import ARKit
import SceneKit

func updatePlaneNode(_ node: SCNNode, center: vector_float3, extent: vector_float3) {
    let geometry = node.geometry as! SCNPlane
    geometry.width = CGFloat(extent.x)
    geometry.height = CGFloat(extent.z)
    node.position = SCNVector3Make(center.x, 0, center.z)
}

func createPlaneNode(center: vector_float3, extent: vector_float3) -> SCNNode {
    let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = UIColor.clear.withAlphaComponent(0.0)
    plane.materials = [planeMaterial]
    let planeNode = SCNNode(geometry: plane)
    planeNode.position = SCNVector3Make(center.x, 0, center.z)
    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    return planeNode
}

func nodeWithModelName(_ modelName: String) -> SCNNode {
    return SCNScene(named: modelName)!.rootNode.clone()
}

