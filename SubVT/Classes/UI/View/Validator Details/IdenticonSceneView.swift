//
//  IdenticonSceneView.swift
//  SubVT
//
//  Created by Kutsal Kaan Bilgin on 29.07.2022.
//

import SceneKit
import SubVTData
import SwiftUI

fileprivate let sphereOrdering = [18, 13, 16, 15, 7, 4, 3, 6, 5, 10, 11, 0, 8, 1, 9, 17, 2, 14, 12]

fileprivate var cubeMaterial: SCNMaterial = {
    let material = SCNMaterial()
    material.lightingModel = .blinn
    material.transparent.contents = UIColor(white: 0.0, alpha: 0.15)
    //material.transparent.contents = UIColor(white: 0.0, alpha: 0.25)
    material.transparencyMode = .dualLayer
    material.fresnelExponent = 1.0
    //material.fresnelExponent = 1
    material.reflective.intensity = 2.0
    material.isDoubleSided = false
    material.specular.contents = UIColor(white: 0.6, alpha: 1.0)
    material.diffuse.contents = UIColor.black
    //material.diffuse.contents = UIColor.blue
    material.shininess = 1.0
    material.reflective.contents = "cube_environment.hdr"
    material.reflective.intensity = 10.0
    //material.blendMode = .add
    return material
}()

fileprivate func getSphereMaterial(color: Color) -> SCNMaterial {
    let material = SCNMaterial()
    material.lightingModel = .phong
    material.diffuse.contents = UIColor(color) // color
    material.specular.contents = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
    material.shininess = 0.0
    return material
}

fileprivate func getSpherePBRMaterial(color: Color) -> SCNMaterial {
    let material = SCNMaterial()
    material.lightingModel = .physicallyBased
    material.diffuse.contents = UIColor(color)
    material.roughness.contents = UIImage(named: "sphere-roughness.png")!
    material.metalness.contents = UIColor.black // UIImage(named: "sphere-metallic.png")!
    material.normal.contents = UIImage(named: "sphere-normal-ogl.png")!
    material.ambientOcclusion.contents = UIImage(named: "sphere-ao.png")!
    return material
}

fileprivate func getAmbientLight(_ name: String) -> SCNNode {
    let light = SCNLight()
    light.type = .ambient
    light.intensity = 20
    let node = SCNNode()
    node.light = light
    node.position = SCNVector3(1, 0, 0)
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
    light.intensity = 150
    let node = SCNNode()
    node.light = light
    node.position = SCNVector3(x, y, z)
    node.name = name
    return node
}

fileprivate func getScene(accountId: AccountId) -> SCNScene {
    let spheresScene = SCNScene(named: "spheres_gather.scn")!
    let cubeScene = SCNScene(named: "cube.obj")!
    let cube = cubeScene.rootNode.childNodes[0]
    cube.name = "cube"
    cube.geometry?.firstMaterial = cubeMaterial
    let spheres = spheresScene.rootNode.clone()
    if let colors = try? accountId.getIdenticonColors() {
        for (index, color) in colors.enumerated() {
            let sphere = spheres.childNodes[sphereOrdering[index]]
            let player = sphere.animationPlayer(forKey: sphere.animationKeys[0])
            player?.animation.repeatCount = 1
            player?.animation.startDelay = 0.5
            sphere.geometry?.firstMaterial = getSpherePBRMaterial(color: color)
        }
    }
    spheres.name = "spheres"
    cube.addChildNode(spheres)
    // add lights
    cubeScene.rootNode.addChildNode(getAmbientLight("ambient-0"))
    /*
    cubeScene.rootNode.addChildNode(getOmniLight("light-0", 0.0, 0.0, 15.0))
    cubeScene.rootNode.addChildNode(getOmniLight("light-0", -12.0, 0.0, 0.0))
    cubeScene.rootNode.addChildNode(getOmniLight("light-0", 12.0, 0.0, 0.0))
    cubeScene.rootNode.addChildNode(getOmniLight("light-0", 0.0, 12.0, 0.0))
    cubeScene.rootNode.addChildNode(getOmniLight("light-0", 0.0, -12.0, 0.0))
     */
    
    cubeScene.rootNode.addChildNode(getOmniLight("light-0", 0.0, 12.0, -12.0))
    cubeScene.rootNode.addChildNode(getOmniLight("light-1", 0.0, 9.4, 4.3))
    cubeScene.rootNode.addChildNode(getOmniLight("light-1-clone", 0.0, 9.4, 4.3))
    cubeScene.rootNode.addChildNode(getOmniLight("light-2", 0.0, -9.0, 0.2))
    cubeScene.rootNode.addChildNode(getOmniLight("light-3", 11.6, -4.9, -0.6))
    cubeScene.rootNode.addChildNode(getOmniLight("light-3-clone", -11.6, 4.9, -0.6))
    
    let bloomFilter = CIFilter(name:"CIBloom")!
    bloomFilter.setValue(10.0, forKey: "inputIntensity")
    bloomFilter.setValue(30.0, forKey: "inputRadius")
     // add camera
    let cameraNode = SCNNode()
    let camera = SCNCamera()
    camera.fieldOfView = 25.0
    cameraNode.camera = camera
    cameraNode.position = SCNVector3.init(0, 0, 35.5)
    cubeScene.rootNode.filters?.append(bloomFilter)
    cubeScene.rootNode.addChildNode(cameraNode)
    
    cubeScene.rootNode.childNode(
        withName: "cube",
        recursively: false
    )!.runAction(SCNAction.rotateBy(
        x: 0,
        y: Double.pi,
        z: 0,
        duration: 10.0
    ))
    
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
        view.allowsCameraControl = false
        view.isTemporalAntialiasingEnabled = false
        view.autoenablesDefaultLighting = false
        view.scene = self.scene
        view.antialiasingMode = .multisampling2X
        view.cameraControlConfiguration.allowsTranslation = false
        // view.isJitteringEnabled = true
        return view
    }
}

struct IdenticonSceneView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            IdenticonSceneView(accountId: PreviewData.stashAccountId)
                .frame(height: UI.Dimension.ValidatorDetails.identiconHeight * 1.3)
        }
        .frame(maxHeight: .infinity)
        .background(Color("Bg"))
        .preferredColorScheme(.dark)
    }
}
