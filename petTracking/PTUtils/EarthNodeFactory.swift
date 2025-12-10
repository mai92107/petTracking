//
//  EarthNodeFactory.swift
//  petTracking
//
//  Created by shue on 2025/12/10.
//

import SceneKit
import UIKit

struct EarthNodeFactory {

    // 建立一個可旋轉的 3D 地球
    static func makeEarthView(frame: CGRect = .zero) -> SCNView {
        let sceneView = SCNView(frame: frame)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.backgroundColor = UIColor.clear

        // 建立場景
        let scene = SCNScene()
        sceneView.scene = scene

        // 地球球體
        let earthSphere = SCNSphere(radius: 1.5)
        earthSphere.segmentCount = 128

        let earthMaterial = SCNMaterial()
        earthMaterial.diffuse.contents = UIImage(named: "earth")
        earthMaterial.specular.contents = UIColor(white: 0.7, alpha: 1)
        earthMaterial.shininess = 0.3
        earthMaterial.roughness.contents = 0.3
        earthSphere.firstMaterial = earthMaterial

        let earthNode = SCNNode(geometry: earthSphere)
        scene.rootNode.addChildNode(earthNode)

        // 光源
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 5, y: 5, z: 5)
        scene.rootNode.addChildNode(lightNode)

        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.4, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)

        // 相機
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3.5)
        scene.rootNode.addChildNode(cameraNode)

        // 旋轉動畫
        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float.pi * 2))
        rotation.duration = 20
        rotation.repeatCount = .infinity
        earthNode.addAnimation(rotation, forKey: "earthRotation")

        return sceneView
    }
}
