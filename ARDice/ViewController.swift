//
//  ViewController.swift
//  ARDice
//
//  Created by Hanh Nguyen on 7/18/18.
//  Copyright © 2018 Hanh Nguyen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: AR Editing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                addDice(atLocation: hitResult)
            } else {
                
            }
        }
    }
    
    func addDice(atLocation location: ARHitTestResult){
        let diceSene = SCNScene(named: "art.scnasserts/diceCollada.scn")!
        if let diceNode = diceSene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: location.worldTransform.columns.3.z
            )
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
        
            roll(dice: diceNode)
        }
    }
    
    func rollAll(){
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    func roll(dice : SCNNode){
        let randomX = Float(arc4random_uniform(4) + 1) * Float.pi/2
        let randomZ = Float(arc4random_uniform(4) + 1) * Float.pi/2
        dice.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX),
            y: 0,
            z: CGFloat(randomZ),
            duration: 0.5))
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem){
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    //MARK: ARSCNViewDelegateMethods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
            
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)
    }
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode{
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnasserts/grid.png")
        plane.materials = [gridMaterial]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        return planeNode
    }
    
}
