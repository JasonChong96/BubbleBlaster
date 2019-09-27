//
//  GameBubblesControllerDelegate.swift
//  LevelDesigner
//
//  Created by Jason Chong on 4/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Controller for GameCellsController
protocol GameCellsControllerProtocol: class {

    /// Sets the input cell to contain the input bubble.
    ///
    /// - Parameters:
    ///     - bubble: The game bubble to apply.
    ///     - cell: The view cell to contain the input bubble.
    func apply(palleteBubble bubble: GameBubble?, to cell: UICollectionViewCell)

    /// Changes the color of the input cell to the next in the cycle.
    ///
    /// - Parameter cell: The cell to cycle the color of.
    func cycleColor(of cell: UICollectionViewCell)
}
