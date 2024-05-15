//
//  makeARViewWithSession.swift
//  ARSticker
//
//  Created by Jinwoo Kim on 5/15/24.
//

import ARKit
import RealityKit

@_cdecl("makeARViewWithSession")
func makeARViewWithSession(_ session: ARSession) -> ARView {
    let arView: ARView = .init(frame: .null)
    arView.automaticallyConfigureSession = false
    arView.session = session
    arView.debugOptions = [.showAnchorGeometry, .showAnchorOrigins, .showFeaturePoints, .showPhysics, .showSceneUnderstanding, .showWorldOrigin]
    
    return arView
}

@_cdecl("setupAddedAnchor")
func setupAddedAnchor(_ anchor: ARAnchor, _ stickerImage: UIImage, _ arView: ARView) {
    print("Detected!")
    
    let texture = try! TextureResource.generate(from: stickerImage.cgImage!, options: .init(semantic: .none))
    
    var material = SimpleMaterial()
    material.color = .init(tint: .white, texture: .init(texture))
    
    let entity = ModelEntity(mesh: .generatePlane(width: 0.5, depth: 0.5), materials: [material])
    
    let anchor = AnchorEntity.init(anchor: anchor)
    anchor.addChild(entity)
    
    arView.scene.addAnchor(anchor)
}

@_cdecl("removeAnchor")
func removeAnchor(_ anchor: ARAnchor, _ arView: ARView) {
    arView.scene.anchors.removeAll()
}
