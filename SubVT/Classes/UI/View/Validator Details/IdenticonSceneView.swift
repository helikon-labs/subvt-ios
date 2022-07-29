//
//  IdenticonSceneView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 29.07.2022.
//

import SceneKit
import SubVTData
import SwiftUI

fileprivate var cubeMaterial: SCNMaterial = {
    let material = SCNMaterial()
    material.lightingModel = .blinn
    material.transparent.contents = UIColor(white: 0.0, alpha: 0.15)
    //material.transparent.contents = UIColor(white: 0.0, alpha: 0.25)
    material.transparencyMode = .dualLayer
    material.fresnelExponent = 2
    //material.fresnelExponent = 1
    material.reflective.intensity = 2.0
    material.isDoubleSided = true
    material.specular.contents = UIColor(white: 0.6, alpha: 1.0)
    material.diffuse.contents = UIColor.black
    //material.diffuse.contents = UIColor.blue
    material.shininess = 50
    material.reflective.contents = "cube_environment.hdr"
    material.reflective.intensity = 10.0
    //material.blendMode = .add
    return material
}()

fileprivate func getBallMaterial(color: Color) -> SCNMaterial {
    let material = SCNMaterial()
    material.lightingModel = .phong
    material.diffuse.contents = UIColor(color) // color
    material.specular.contents = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
    material.shininess = 0.0
    return material
}

fileprivate func getBallPBRMaterial(color: Color) -> SCNMaterial {
    let material = SCNMaterial()
    material.lightingModel = .physicallyBased
    material.diffuse.contents = UIColor(color)
    material.roughness.contents = UIImage(named: "ball-roughness.png")!
    material.metalness.contents = UIColor.black // UIImage(named: "ball-metallic.png")!
    material.normal.contents = UIImage(named: "ball-normal-ogl.png")!
    material.ambientOcclusion.contents = UIImage(named: "ball-ao.png")!
    return material
}

fileprivate func getAmbientLight(_ name: String) -> SCNNode {
    let light = SCNLight()
    light.type = .ambient
    light.intensity = 150
    let node = SCNNode()
    node.light = light
    node.position = SCNVector3(0, 0, 0)
    node.name = name
    return node
}

fileprivate func getOmniLight(
    _ name: String,
    _ x: CGFloat,
    _ y: CGFloat,
    _ z: CGFloat
) -> SCNNode {
    let light = SCNLight()
    light.type = .omni
    light.intensity = 250
    let node = SCNNode()
    node.light = light
    node.position = SCNVector3(x, y, z)
    node.name = name
    return node
}

fileprivate func getScene(accountId: AccountId) -> SCNScene {
    let ballsScene = SCNScene(named: "balls_gather.scn")!
    let cubeScene = SCNScene(named: "cube.obj")!
    let child = cubeScene.rootNode.childNodes[0]
    child.name = "cube"
    child.geometry?.firstMaterial = cubeMaterial
    let ballsClone = ballsScene.rootNode.clone()
    if let colors = try? accountId.getIdenticonColors() {
        print("colors \(colors.count)")
        for (index, child) in ballsClone.childNodes.enumerated() {
            // child.removeAllAnimations(withBlendOutDuration: 0)
            let player = child.animationPlayer(forKey: child.animationKeys[0])
            player?.animation.repeatCount = 1
            player?.animation.startDelay = 0.5
            child.geometry?.firstMaterial = getBallPBRMaterial(color: colors[index])
            //child.geometry?.firstMaterial?.diffuse.contents = UIColor(colors[index])
        }
    }
    ballsClone.name = "balls"
    cubeScene.rootNode.addChildNode(ballsClone)
    // add lights
    cubeScene.rootNode.addChildNode(getAmbientLight("ambient-0"))
    cubeScene.rootNode.addChildNode(getOmniLight("light-0", 0.0, 12.0, -12.0))
    cubeScene.rootNode.addChildNode(getOmniLight("light-1", 0.0, 9.4, 4.3))
    cubeScene.rootNode.addChildNode(getOmniLight("light-1-clone", 0.0, 9.4, 4.3))
    cubeScene.rootNode.addChildNode(getOmniLight("light-2", 0.0, -9.0, 0.2))
    cubeScene.rootNode.addChildNode(getOmniLight("light-3", 11.6, -4.9, -0.6))
    cubeScene.rootNode.addChildNode(getOmniLight("light-3-clone", 11.6, -4.9, -0.6))
    /*
     // add camera
    let cameraNode = SCNNode()
    let pov = SCNCamera()
    cameraNode.camera = pov
    cameraNode.position = SCNVector3.init(0, 0, 20)
    cubeScene.rootNode.addChildNode(cameraNode)
     */
    return cubeScene
}

final class IdenticonSceneView: UIViewRepresentable {
    typealias UIViewType = SCNView
    typealias Context = UIViewRepresentableContext<IdenticonSceneView>
    
    private let accountId: AccountId
    
    init(accountId: AccountId) {
        self.accountId = accountId
    }
    
    deinit {
        self.scene = nil
    }
    
    private lazy var scene: SCNScene? = getScene(accountId: accountId)

    func updateUIView(_ uiView: UIViewType, context: Context) {}
    func makeUIView(context: Context) -> UIViewType {
        let view = SCNView()
        view.backgroundColor = UIColor.clear
        view.allowsCameraControl = true
        view.isTemporalAntialiasingEnabled = false
        view.autoenablesDefaultLighting = false
        view.scene = self.scene
        view.antialiasingMode = .multisampling2X
        view.cameraControlConfiguration.allowsTranslation = false
        //view.isJitteringEnabled = true
        return view
    }
}
