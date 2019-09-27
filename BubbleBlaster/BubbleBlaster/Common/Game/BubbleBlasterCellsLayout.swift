//
//  BubbleBlasterCellsLayout.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 26/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Encapsulates the grid layout type.
enum BubbleBlasterCellsLayout: String {
    case isometric, rectangular

    /// The number of rows of cells in the game area.
    ///
    /// - Returns: The number of rows in the layout
    static let maxRows = 9

    /// The number of rows of cells in the game area.
    ///
    /// - Returns: The number of rows in the layout
    static let maxColumns = 12

    /// The number of rows of cells in the game area.
    ///
    /// - Returns: The number of rows in the layout
    func getNumRows() -> Int {
        return BubbleBlasterCellsLayout.maxRows
    }

    /// Calculates the number of columns for a given row of cells in
    /// the game area.
    ///
    /// - Parameter row: The index of the row.
    ///
    /// - Returns: The number of columns for the row.
    func getNumColumns(forRow row: Int) -> Int {
        switch self {
        case .isometric:
            return BubbleBlasterCellsLayout.maxColumns - (row % 2 == 0 ? 0 : 1)
        case .rectangular:
            return BubbleBlasterCellsLayout.maxColumns
        }
    }

    /// Gets all possible adjacent `IndexPath`s in the game grid from the given `IndexPath`.
    ///
    /// - Parameter indexPath: The `IndexPath` to check from.
    /// - Returns: An array of adjacent `IndexPath`s
    func getPossibleAdjacentIndices(from indexPath: IndexPath) -> [IndexPath] {
        var indices = [IndexPath]()
        let row = indexPath.section
        let col = indexPath.item

        switch self {
        case .isometric:
            indices.append(IndexPath(item: col + 1, section: row))
            indices.append(IndexPath(item: col - 1, section: row))
            indices.append(IndexPath(item: col, section: row + 1))
            indices.append(IndexPath(item: col, section: row - 1))
            indices.append(IndexPath(item: col + (row % 2 == 0 ? -1 : 1), section: row + 1))
            indices.append(IndexPath(item: col + (row % 2 == 0 ? -1 : 1), section: row - 1))
        case .rectangular:
            indices.append(IndexPath(item: col + 1, section: row))
            indices.append(IndexPath(item: col - 1, section: row))
            indices.append(IndexPath(item: col, section: row + 1))
            indices.append(IndexPath(item: col, section: row - 1))
        }

        return indices
    }

    func rectForItem(at indexPath: IndexPath, in bounds: CGRect) -> CGRect {
        let rowNum = indexPath.section
        let colNum = indexPath.item
        let radius = (bounds.width / CGFloat(BubbleBlasterCellsLayout.maxColumns)) / 2
        let centerOffset = CGPoint(x: 2 * radius * cos(.pi / 3),
                               y: 2 * radius * sin(.pi / 3))
        let isOddRow = rowNum % 2 == 1

        var centerX: CGFloat = radius + CGFloat(colNum) * (radius * 2)
        let centerY: CGFloat

        switch self {
        case .isometric:
            if isOddRow {
                centerX += centerOffset.x
            }
            centerY = radius + CGFloat(rowNum) * centerOffset.y
        case .rectangular:
            centerY = radius + CGFloat(rowNum) * radius * 2
        }

        return CGRect(x: centerX - radius, y: centerY - radius, width: radius * 2, height: radius * 2)
    }
}

extension BubbleBlasterCellsLayout: Codable {
}
