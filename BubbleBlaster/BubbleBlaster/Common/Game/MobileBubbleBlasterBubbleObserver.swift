//
//  MobileBubbleBlasterBubbleObserver.swift
//  GameEngine
//
//  Created by Jason Chong on 19/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Observer for `MobileBubbleBlasterBubble` to be notified when a player shoots a bubble
protocol MobileBubbleBlasterBubbleObserver: class {
    /// Called when the player has shot the input bubble.
    ///
    /// - Parameters:
    ///   - bubble: The `MobileBubbleBlasterBubble` that was shot.
    ///   - direction: The direction in which the user shot the bubble.
    func playerShot(_ bubble: MobileBubbleBlasterBubble, in direction: CGPoint)
}
