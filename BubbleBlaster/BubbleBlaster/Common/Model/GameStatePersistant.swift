//
//  GameBubbles.swift
//  LevelDesigner
//
//  Created by Jason Chong on 2/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//
import UIKit

/// Encapsulates the components of the game state that can be saved in the disk.
class GameStatePersistant {
    private(set) var cells: [[GameCell]]

    /// The layout of the grid.
    let gridLayout: BubbleBlasterCellsLayout

    var numOfShooters = 1

    /// Constuctor that creates a `GameCells` instance with dimensions
    /// described in `GameConstants`. All cells are initialized as empty.
    convenience init() {
        self.init(withLayout: .isometric)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GameStatePersistant.CodingKeys.self)
        self.cells = try container.decode([[GameCell]].self, forKey: .cells)
        self.gridLayout = try container.decode(BubbleBlasterCellsLayout.self, forKey: .layout)
        self.numOfShooters = try container.decode(Int.self, forKey: .numOfShooters)
    }

    /// Retrieves the cell at the given location.
    ///
    /// - Parameters:
    ///   - row: The row that the desired cell is on.
    ///   - col: The col that the desired cell is on.
    /// - Returns: The cell at the desired location. Nil if there's no cell at that location.
    func getCellAt(row: Int, col: Int) -> GameCell? {
        if !contains(col: col, inRow: row) {
            return nil
        }

        return cells[row][col]
    }

    /// Returns the game grid as an array of arrays of optional bubbles.
    ///
    /// - Returns: An array of arrays of optional bubbles.
    func getBubbleGrid() -> [[GameBubble?]] {
        return cells.map {
            return $0.map { $0.bubble }
        }
    }

    /// Constructor that creates a `GameCells` instance with the given layout for cells
    ///
    /// - Parameter layout: The layout for the grid.
    init(withLayout layout: BubbleBlasterCellsLayout) {
        self.gridLayout = layout
        self.cells = []
        for rowIndex in 0..<layout.getNumRows() {
            var row = [GameCell]()
            for col in 0..<layout.getNumColumns(forRow: rowIndex) {
                row.append(GameCell(state: .empty, row: rowIndex, col: col))
            }
            self.cells.append(row)
        }
    }

    /// Updates the frames of the `GameCell`s that is generated using the given function.
    ///
    /// - Parameter generator: The function to calculate the position and size of each cell based on its index.
    func updateFrames(withGenerator generator: (IndexPath) -> (CGRect)) {
        for row in cells.indices {
            for col in cells[row].indices {
                let indexPath = IndexPath(item: col, section: row)
                let cell = cells[row][col]
                cell.frame = generator(indexPath)
                cells[row][col] = cell
            }
        }
    }

    /// Saves the model as a file with the given file name.
    ///
    /// - Parameters:
    ///     - fileName: The name of the file to save as.
    func save(as fileName: String) throws {
        try StorageManager.save(object: self, as: fileName)
    }

    /// Changes the cell at the given position to the given bubble.
    ///
    /// - Parameters:
    ///     - row: The row index of the position.
    ///     - col: The column index of the position.
    ///     - bubble: The new bubble in the cell.
    func setCell(atRow row: Int, andCol col: Int, toBubble bubble: GameBubble?) {
        let cell = getCellAt(row: row, col: col)
        if let unwrappedBubble = bubble {
            cell?.set(bubble: unwrappedBubble)
        } else {
            cell?.removeBubble(type: nil)
        }
    }

    /// Checks if a row of `GameCell`s with the input index exists
    ///
    /// - Parameter rowIndex: The index of the row to check for
    ///
    /// - Returns: true if the row exists, else false.
    private func contains(rowIndex: Int) -> Bool {
        return cells.indices.contains(rowIndex)
    }

    /// Checks if there exists a `GameCell` at the given position.
    ///
    /// - Parameters:
    ///     - col: The column index of the position
    ///     - rowIndex: The row index of the position
    ///
    /// - Returns: true if the `GameCell` exists, else false.
    private func contains(col: Int, inRow rowIndex: Int) -> Bool {
        if !contains(rowIndex: rowIndex) {
            return false
        }

        return cells[rowIndex].indices.contains(col)
    }

    enum CodingKeys: String, CodingKey {
        case cells, layout, numOfShooters
    }
}

extension GameStatePersistant: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GameStatePersistant.CodingKeys.self)
        try container.encode(cells, forKey: .cells)
        try container.encode(gridLayout, forKey: .layout)
        try container.encode(numOfShooters, forKey: .numOfShooters)
    }
}
