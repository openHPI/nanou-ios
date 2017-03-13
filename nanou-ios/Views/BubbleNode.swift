//
//  BubbleNode.swift
//  nanou-ios
//
//  Created by Max Bothe on 03/01/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import UIKit
import SpriteKit
import SIFloatingCollection

class BubbleNode: SIFloatingNode {
    var labelNode = SKLabelNode(fontNamed: "")
    var preference: Preference?

    class func instantiate(preference: Preference) -> BubbleNode! {
        let node = BubbleNode(circleOfRadius: 60)
        configureNode(node, preference: preference)
        return node
    }

    class func configureNode(_ node: BubbleNode!, preference: Preference) {
        let boundingBox = node.path?.boundingBox
        let radius = (boundingBox?.size.width)! / 2.0
        node.physicsBody = SKPhysicsBody(circleOfRadius: radius + 1.5)
        node.fillColor = UIColor.nanouOrange
        node.strokeColor = node.fillColor

        node.preference = preference
        node.labelNode.text = preference.name
        node.labelNode.position = CGPoint.zero
        node.labelNode.fontColor = SKColor.white
        node.labelNode.fontSize = 15
        node.labelNode.isUserInteractionEnabled = false
        node.labelNode.verticalAlignmentMode = .center
        node.labelNode.horizontalAlignmentMode = .center


        let padding = CGFloat(8.0)
        let nodeSize = CGSize(width: node.frame.width - 2*padding, height: node.frame.height - 2*padding)
        let labelSize = CGSize(width: node.labelNode.frame.width, height: node.labelNode.frame.height)
        let scalingFactor = min(min(nodeSize.width / labelSize.width, nodeSize.height / labelSize.height), 1)
        node.labelNode.fontSize *= scalingFactor

        node.addChild(node.labelNode)
    }

    override func selectingAnimation() -> SKAction? {
        removeAction(forKey: BubbleNode.removingKey)
        let scaleAction = SKAction.scale(to: 1.15, duration: 0.2)
        let colorAction = colorTransitionAction(from: UIColor.nanouOrange, to: UIColor.nanouPink, duration: 0.2)
        return SKAction.group([scaleAction, colorAction])
    }

    override func normalizeAnimation() -> SKAction? {
        removeAction(forKey: BubbleNode.removingKey)
        let scaleAction = SKAction.scale(to: 1.0, duration: 0.2)
        let colorAction = colorTransitionAction(from: UIColor.nanouPink, to: UIColor.nanouOrange, duration: 0.2)
        return SKAction.group([scaleAction, colorAction])
    }

    override func removeAnimation() -> SKAction? {
        removeAction(forKey: BubbleNode.removingKey)
        return SKAction.fadeOut(withDuration: 0.2)
    }

    override func removingAnimation() -> SKAction {
        let pulseUp = SKAction.scale(to: xScale + 0.13, duration: 0)
        let pulseDown = SKAction.scale(to: xScale, duration: 0.3)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        return repeatPulse
    }

}


func lerp(a: CGFloat, b: CGFloat, fraction: CGFloat) -> CGFloat {
    return (b-a) * fraction + a
}

func colorTransitionAction(from fromColor: UIColor, to toColor: UIColor, duration: TimeInterval) -> SKAction {
    let fromCIColor = CIColor(color: fromColor)
    let toCIColor = CIColor(color: toColor)
    return SKAction.customAction(withDuration: duration, actionBlock: { node, elapsedTime in
        let fraction = CGFloat(elapsedTime / CGFloat(duration))
        let transColor = UIColor(red: lerp(a: fromCIColor.red, b: toCIColor.red, fraction: fraction),
                                 green: lerp(a: fromCIColor.green, b: toCIColor.green, fraction: fraction),
                                 blue: lerp(a: fromCIColor.blue, b: toCIColor.blue, fraction: fraction),
                                 alpha: lerp(a: fromCIColor.alpha, b: toCIColor.alpha, fraction: fraction))
        (node as! SKShapeNode).fillColor = transColor
        (node as! SKShapeNode).strokeColor = transColor
    }
    )
}
