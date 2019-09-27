//
//  GridCell.swift
//  GameEngine
//
//  Created by Jason Chong on 16/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit
import a0164721j_PhysicsEngine

/// Protocol for implementations of a BubbleBlaster cell.
protocol GridCell: Object2D {

    /// The row on the grid that this cell belongs to
    var row: Int { get }

    /// The column on the grid that this cell belongs to
    var col: Int { get }

    /// The bubble that this grid contains.
    var bubble: GameBubble? { get }

    /// Changes the cell to contain the input bubble
    ///
    /// - Parameter bubble: The new `GameBubble` that the cell should contain
    func set(bubble: GameBubble)

    /// Removes the bubble that is in this cell.
    ///
    /// - Parameter type: The type of removal.
    func removeBubble(type: RemoveBubbleType?)
}
