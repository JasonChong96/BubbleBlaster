//
//  MobileBubbleBlasterBubble.swift
//  GameEngine
//
//  Created by Jason Chong on 15/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Protocol for implemention of a mobile bubble.
protocol MobileBubbleBlasterBubble: class {

    /// Observer of this mobile bubble blaster bubble. SwiftLint recommends not using weak in protocol variables.
    var bubbleBlasterObserver: MobileBubbleBlasterBubbleObserver? { get set }

    /// The frame of the view.
    var frame: CGRect { get }

    /// Displaces this view by the imput displacement vector.
    ///
    /// - Parameter displacement: The displacement vector as a `CGPoint` instance.
    func displace(by displacement: CGPoint)

    /// Removes this view from the game
    ///
    /// - Parameter isAttached: Whether the bubble is attached to the grid.
    func removeFromGame(isAttached: Bool)
}
