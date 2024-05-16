//
//  CustomScnNode.swift
//  dancereality
//
//  Created by Saad Khalid on 19.12.22.
//

import Foundation
import SceneKit

class CustomScnNode : SCNNode {
    private var animationKey : String?
    private var animationPlayer: SCNAnimationPlayer?
    
    public func prepareForAnimation(){
        findAnimationIdFromChildNodes(node: self)
    }
    
    private func findAnimationIdFromChildNodes(node: SCNNode){
        for child in node.childNodes {
            // do something with the child node
            if(!child.animationKeys.isEmpty){
                for item in child.animationKeys {
                    if(item != ""){
                        self.animationKey = item
                        self.animationPlayer = child.animationPlayer(forKey: item)
                        return
                    }
                }
            }
            findAnimationIdFromChildNodes(node: child)
        }
    
        return
    }
    
    public func speedAnimation(speed: CGFloat){
        guard let animationPlayer = animationPlayer else {
            return
        }
        animationPlayer.speed = speed
        print("speed set \(speed)")
    }
    
    public func playAnimation(){
        guard let animationPlayer = animationPlayer else {
            return
        }
        animationPlayer.play()
    }
    
    public func pauseAnimation(){
        guard let animationPlayer = animationPlayer else {
            return
        }
        animationPlayer.paused = true
    }
    
    public func stopAnimation(){
        guard let animationPlayer = animationPlayer else {
            return
        }
        animationPlayer.stop()
    }
    
    public func resetAnimation(){
        guard let animationPlayer = animationPlayer else {
            return
        }
        animationPlayer.animation.timeOffset = 0.0
    }
    
    public func getAnimationDuration() -> TimeInterval{
        guard let animationPlayer = animationPlayer else {
            return 0.0
        }
        return animationPlayer.animation.duration
    }
    
    public func getAnimationPlayer() -> SCNAnimationPlayer?{
        guard let animationPlayer = animationPlayer else {
            return nil
        }
        return animationPlayer
    }
}
