//
//  ModelView.swift
//  ModelViewer
//
//  Created by Sergio Barrio on 31/1/23.
//

import SwiftUI
import SceneKit

struct ModelView: View {
    var filename: String;
    var scene: SCNScene
        
    init(filename: String) {
        self.filename = filename
        scene = SCNScene()
        scene.background.contents = UIColor.black
                
        // Lighting
        let lightNode = setupLightNode(flipY: true)
        scene.rootNode.addChildNode(lightNode)
        
        
        // Create and configure a particle system.
        let starFieldNode = setupStarField(particleColor: UIColor.white, particleSize: 0.2, birthRate: 1000, particleVelocity: 300)
        scene.rootNode.addChildNode(starFieldNode)

        // Set up model
        let model = loadModel(named: filename, flipY: true, unfilteredTextures: true)

        model.position = SCNVector3(x: 0, y: 0, z: 0)
        scene.rootNode.addChildNode(model)
                        
        // Pixelate scene
        let filters = setupFilters(pixelize: false)
        scene.rootNode.filters = filters
        
        // Set initial camera positon and Fov
        scene.rootNode.position = SCNVector3(x: 0, y: 0, z: -50)
    }
            
    var body: some View {
        SceneView(scene: scene, options: [.allowsCameraControl], antialiasingMode: SCNAntialiasingMode.none)
    }
}

func loadModel(named name: String, flipY: Bool = false, unfilteredTextures: Bool = false) -> SCNNode {
    let scene = SCNScene(named: name)!
    let node = SCNNode()
    
    if (flipY) {
        node.scale = SCNVector3(1, -1, 1)
    }

    for child in scene.rootNode.childNodes {
        node.addChildNode(child)
    }
    
    if (unfilteredTextures) {
        for node in node.childNodes {
            if (node.geometry != nil) {
                for m in node.geometry!.materials {
                    m.diffuse.magnificationFilter = SCNFilterMode.nearest
                    m.diffuse.minificationFilter = SCNFilterMode.nearest
                }
            }
        }
    }
    
    return node
}

func setupLightNode(flipY: Bool = false) -> SCNNode{
    let lightNode = SCNNode()
    lightNode.light = SCNLight()
    lightNode.light?.type = .ambient
    lightNode.position = SCNVector3(x: 0, y: 10 * (flipY ? -1 : 1), z: 35)
    
    return lightNode;
}

func setupStarField(particleColor: UIColor, particleSize: CGFloat, birthRate: CGFloat, particleVelocity: CGFloat) -> SCNNode {
    
    let particleSystem = SCNParticleSystem()
    particleSystem.particleColor = particleColor
    particleSystem.particleSize = particleSize
    particleSystem.birthRate = birthRate
    particleSystem.emitterShape = SCNPlane(width: 1000.0, height: 1000.0) // emitter shape is a plane
    particleSystem.emittingDirection = SCNVector3(0, 0, -1)
    particleSystem.particleVelocity = particleVelocity

    // Create a node for the particle emitter.
    let emitterNode = SCNNode()
    emitterNode.position = SCNVector3(0, 0, 200) // place node behind the camera
    
    // Add the particle system to the emitter node.
    emitterNode.addParticleSystem(particleSystem)
    
    return emitterNode;
    
}

func setupFilters(pixelize: Bool = false) -> [CIFilter]
{
    var filterArray: [CIFilter] = []
    if (pixelize) {
        let pixellateFilter = CIFilter(name: "CIPixellate")
        pixellateFilter?.name = "pixellate"
        filterArray.append(pixellateFilter!)
    }

    return filterArray
}

struct ModelView_Previews: PreviewProvider {
    static var previews: some View {
        ModelView(filename: "B4BC 66001.obj")
    }
}
