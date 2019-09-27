//
//  MobileBubbleObserver.swift
//  GameEngine
//
//  Created by Jason Chong on 19/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Protocol for a `MobileBubble` observer. To listen for removal of the bubble.
protocol MobileBubbleObserver: class {

    /// Called when the bubble should be removed from UI.
    ///
    /// - Parameter isAttached: whether the bubble is dettached when removed.
    func removed(mobileBubble: MobileBubble, isAttached: Bool)
}
