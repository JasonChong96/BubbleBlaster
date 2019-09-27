//
//  Bubble.swift
//  LevelDesigner
//
//  Created by Jason Chong on 30/1/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

/// Protocol for representations of game bubbles in the memory model.
protocol GameBubble: Codable {
    /// The imagename of the image representing this game bubble.
    var imageName: String { get }

    /// The special effect to trigger when a bubble enters an adjacent cell
    var triggerOnSnapAdjacent: TriggerEvent? { get }

    /// Checks if this bubble matches another bubble, to check if they can be in the same combo in the grid.
    func canComboWith(otherBubble: GameBubble) -> Bool
}

extension GameBubble {
    func canComboWith(otherBubble: GameBubble) -> Bool {
        return false
    }

    /// Checks if this bubble is represented by the same image as another bubble.
    func sameImageAs(otherBubble: GameBubble?) -> Bool {
        return self.imageName == otherBubble?.imageName
    }
}
