//
//  GameStateObserver.swift
//  GameEngine
//
//  Created by Jason Chong on 19/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//
/// Protocol for a `GameCell` observer. To listen to changes in bubbles contained in the cell.
protocol GameCellObserver: class {
    /// Called when the bubble in the cell has changed.
    ///
    /// - Parameters:
    ///   - row: The row that this cell is on
    ///   - col: The column that this cell is on
    ///   - bubble: The new bubble in this cell.
    func cellBubbleChanged(atRow row: Int, col: Int, to bubble: GameBubble)

    /// Called when the bubble in the cell has been removed, leaving it empty.
    ///
    /// - Parameters:
    ///   - row: The row that this cell is on.
    ///   - col: The column that this cell is on.
    ///   - removalType: The type of removal.
    func cellBubbleRemoved(atRow row: Int, col: Int, removalType: RemoveBubbleType?)
}
