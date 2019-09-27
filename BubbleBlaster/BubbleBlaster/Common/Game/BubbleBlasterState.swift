//
//  BubbleBlasterState.swift
//  GameEngine
//
//  Created by Jason Chong on 19/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Protocol for implementing the model state of the game.
protocol BubbleBlasterState: class {
    /// Bounds of the bubble blaster game
    var bounds: CGRect { get }

    /// The bubbles that are upcoming
    var upcomingBubbles: [MobileBubbleBlasterBubble] { get }

    /// The bubble that is ready for the user to shoot.
    var readyBubbles: [MobileBubbleBlasterBubble?] { get }

    /// The layout of grid cells.
    var gridLayout: BubbleBlasterCellsLayout { get }

    /// Adds an active bubble, ready for the user to shoot
    ///
    /// - Parameters:
    ///     - pos: The position of the bubble to add.
    ///     - bubble: The bubble to add.
    /// - Returns: The mobile bubble that has been added
    func setUpcomingBubble(for bubble: GameBubble) -> MobileBubbleBlasterBubble?

    /// Gets the state of the grid represented by an array of array of grid cells.
    ///
    /// - Returns: An array of array of grid cells.
    func getAllGridCells() -> [[GridCell]]

    /// Called when the game as ended to notify the state that the game should end.
    func gameEnded()
}
