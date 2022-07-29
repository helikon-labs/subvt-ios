//
//  IdenticonSceneView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 29.07.2022.
//

import SceneKit
import SwiftUI

fileprivate var cubeMaterial: SCNMaterial = {
    let material = SCNMaterial()
    material.lightingModel = .blinn
    material.transparent.contents = UIColor(white: 0.0, alpha: 0.15)
    material.transparencyMode = .dualLayer
    material.fresnelExponent = 2
    material.reflective.intensity = 2.0
    material.isDoubleSided = true
    material.specular.contents = UIColor(white: 0.6, alpha: 1.0)
    material.diffuse.contents = UIColor.black
    material.shininess = 50
    material.reflective.contents = "cube_environment.hdr"
    material.reflective.intensity = 10.0
    return material
}()

final class IdenticonSceneView: UIViewRepresentable {
    typealias UIViewType = SCNView
    typealias Context = UIViewRepresentableContext<IdenticonSceneView>
    
    private lazy var scene: SCNScene = {
        let scene = SCNScene(named: "cube.obj")!
        let child = scene.rootNode.childNodes[0]
        child.geometry?.firstMaterial = cubeMaterial
        return scene
    }()

    func updateUIView(_ uiView: UIViewType, context: Context) {}
    func makeUIView(context: Context) -> UIViewType {
        let view = SCNView()
        view.backgroundColor = UIColor.clear
        view.allowsCameraControl = false
        view.isTemporalAntialiasingEnabled = false
        view.autoenablesDefaultLighting = false
        view.scene = self.scene
        return view
    }
}
