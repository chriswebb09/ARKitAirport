//
//  Helpers.swift
//  Airport
//
//  Created by Christopher Webb-Orenstein on 10/14/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import ARKit
import SceneKit

func nodeWithModelName(_ modelName: String) -> SCNNode {
    return SCNScene(named: modelName)!.rootNode.clone()
}
