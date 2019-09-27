//
//  BubbleBlasterEngine.swift
//  GameEngine
//
//  Created by Jason Chong on 15/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit
import a0164721j_PhysicsEngine

/**
 Encapsulates the main game logic for Bubble Blaster
 */
class BubbleBlasterEngine {

    /// The bubbles to be used (shot) by the user
    private static let bubblesForShooting = GameBubbleUtil.getAllNormalBubbles()

    /// The physics engine for this game
    private let physicsEngine: SimplePhysicsEngine

    /// The state of the game.
    private let model: BubbleBlasterState

    /// Bubbles that are ready to be shot but not yet entered in the physics engine.
    private var readyBubbles = [ActiveGameBubbleController]()

    /// The number of bubbles the user has used.
    private var bubblesUsed = 0

    /// The time which the game loop was last run in milliseconds since 1970.
    private var lastLoopTime: Int64 = 0

    /// The game grid layout
    private var layout: BubbleBlasterCellsLayout {
        return model.gridLayout
    }

    /// The game grid
    private var grid: [[GridCell]] {
        return model.getAllGridCells()
    }

    /// Constructor for Bubble Blaster Engine.
    ///
    /// - Parameters:
    ///     - bounds: The bounds of the game area
    ///     - refreshRate: The rate in which the physics engine updates objects and process interactions in Hz.
    ///     - cellsController: The controller for the game cells' view and model
    ///     - areaController: The controller for the game area
    ///
    /// - Returns: A new BubbleBlasterEngine that uses the given parameters.
    init(withBounds bounds: CGRect, refreshRate: Int, model: BubbleBlasterState) {
        self.physicsEngine = SimplePhysicsEngine(withBounds: model.bounds, andTimeStepMillis: Int64(1000 / refreshRate),
                                                 speedLimit: GameConstants.maxBubbleSpeed)
        self.model = model
        addCellsToPhysicsEngine()
    }

    /// Runs one iteration of the game loop. Calculates the elapsed time since the last iteration and tells the
    /// physics engine to update positions. Also adds an active bubble for the user to shoot if there isn't any.
    func runGameLoop() {
        let curTime = Int64(Date().timeIntervalSince1970 * 1000.0)

        if lastLoopTime == 0 {
            lastLoopTime = curTime
        }

        let timeStep = curTime - lastLoopTime
        lastLoopTime = curTime
        physicsEngine.updatePositions(after: timeStep)

        if model.upcomingBubbles.count < GameConstants.bubblesToDisplay {
            addBubbleForShooting()
        }
    }

    /// Changes the `GameBubble` in the input cell to the input bubble.
    ///
    /// - Parameters:
    ///     - bubble: The `GameBubble` to apply
    ///     - cell: The cell to modify
    func attach(_ bubble: GameBubble, to cell: GridCell) {
        cell.set(bubble: bubble)
        checkAndProcessCombo(from: IndexPath(item: cell.col, section: cell.row))
        triggerAdjacentEvents(from: cell, by: bubble)
        removeUnattachedBubbles()
        let finished = getBubbleGrid().flatMap { $0 }
            .filter { $0 != nil }
            .isEmpty && physicsEngine.mobileObjects.count < 2
        if finished {
            model.gameEnded()
        }
    }

    /// Checks if the cell can hold a bubble. i.e is connected to a non-empty neighbour.
    ///
    /// - Parameters:
    ///     - cell: The `GridCell` to check
    ///
    /// - Returns: true if the cell can hold a bubble, false if it can't
    func canHoldBubble(_ cell: GridCell) -> Bool {
        if cell.row == 0 {
            return true
        }

        let adjacentIndices = layout.getPossibleAdjacentIndices(from: IndexPath(item: cell.col, section: cell.row))
        let validIndices = getValidIndices(from: adjacentIndices)

        for otherCell in validIndices.map({ grid[$0.section][$0.item] }) where otherCell.bubble != nil {
            return true
        }

        return false
    }

    /// Called when the player has shot the input bubble. Adds the bubble to the physics engine.
    ///
    /// - Parameter activeBubble: The bubble that has just been shot.
    func playerShot(_ activeBubble: ActiveGameBubbleController) {
        physicsEngine.add(activeBubble)
        readyBubbles = readyBubbles.filter { $0 !== activeBubble }
    }

    /// Trigger events in bubbles that are adjacent to the input cell, if any.
    ///
    /// - Parameters:
    ///   - cell: The cell to trigger events around.
    ///   - bubble: The bubble that has just entered the input cell.
    private func triggerAdjacentEvents(from cell: GridCell, by bubble: GameBubble) {
        let adjacentIndices = layout.getPossibleAdjacentIndices(from: IndexPath(item: cell.col, section: cell.row))
        let validIndices = getValidIndices(from: adjacentIndices)

        for indexPath in validIndices {
            let row = indexPath.section
            let col = indexPath.item
            guard let event = grid[row][col].bubble?.triggerOnSnapAdjacent else {
                continue
            }

            handle(event: event, from: grid[row][col], triggeredBy: bubble)
        }
    }

    /// Explodes all bubbles adjacent from the input index.
    ///
    /// - Parameter indexPath: The index of the source of the explosion.
    private func explodeAdjacent(from indexPath: IndexPath) {
        let adjacentIndices = layout.getPossibleAdjacentIndices(from: indexPath)
        let validIndices = getValidIndices(from: adjacentIndices)
        grid[indexPath.section][indexPath.item].removeBubble(type: RemoveBubbleType.explode)

        for adjacentIndexPath in validIndices {
            let row = adjacentIndexPath.section
            let col = adjacentIndexPath.item

            removeBubble(from: grid[row][col], type: .explode, ignoreTriggers: [])
        }
    }

    /// Removes all bubbles that match(can combo with) the input bubble
    ///
    /// - Parameter bubble: The input bubble.
    private func removeAllMatching(_ bubble: GameBubble) {
        for row in grid {
            for cell in row {
                guard let otherBubble = cell.bubble else {
                    continue
                }

                if bubble.canComboWith(otherBubble: otherBubble) {
                    removeBubble(from: cell, type: .combo(size: 0), ignoreTriggers: [])
                }
            }
        }
    }

    /// Removes all bubbles in the input row in the grid.
    ///
    /// - Parameters:
    ///   - row: The row to remove bubbles from.
    ///   - cell: The cell that's the source of the removal.
    private func remove(row: Int, by cell: GridCell) {
        if !grid.indices.contains(row) {
            return
        }

        for otherCell in grid[row] where otherCell !== cell {
            removeBubble(from: otherCell, type: .removeRow(isSource: false), ignoreTriggers: [.removeRow])
        }

        cell.removeBubble(type: .removeRow(isSource: true))
    }

    /// Remove bubble from the given cell for the given removal type. Ignores input trigger events.
    ///
    /// - Parameters:
    ///   - cell: The cell to remove a bubble from.
    ///   - type: The type of removal.
    ///   - ignored: An array of events to ignore.
    private func removeBubble(from cell: GridCell, type: RemoveBubbleType, ignoreTriggers ignored: [TriggerEvent]) {
        if let event = cell.bubble?.triggerOnSnapAdjacent,
            !ignored.contains(event) {
            handle(event: event, from: cell, triggeredBy: nil)
        }

        cell.removeBubble(type: type)
    }

    /// Handles the input trigger event.
    ///
    /// - Parameters:
    ///   - event: The event to handle.
    ///   - cell: The cell that triggered the event.
    ///   - bubble: The bubble that triggered the event.
    private func handle(event: TriggerEvent, from cell: GridCell, triggeredBy bubble: GameBubble?) {
        switch event {
        case .explodeAdjacent:
            explodeAdjacent(from: IndexPath(item: cell.col, section: cell.row))
        case .removeAllMatching:
            if let bubble = bubble {
                removeAllMatching(bubble)
            }

            cell.removeBubble(type: RemoveBubbleType.combo(size: 0))
        case .removeRow:
            remove(row: cell.row, by: cell)
        }
    }

    /// Adds the game cells in cellsController to the physics engine.
    private func addCellsToPhysicsEngine() {
        model.getAllGridCells()
            .flatMap { $0 }
            .forEach { physicsEngine.add($0) }
    }

    /// Filters the input indices and only returns those that are valid in the grid.
    ///
    /// - Parameter indices: The array of indices to filter.
    /// - Returns: An array of indices that exist in the grid.
    private func getValidIndices(from indices: [IndexPath]) -> [IndexPath] {
        var validIndices = [IndexPath]()

        for indexPath in indices {
            let row = indexPath.section
            let col = indexPath.item
            if grid.indices.contains(row) && grid[row].indices.contains(col) {
                validIndices.append(indexPath)
            }
        }

        return validIndices
    }

    /// Adds a bubble that is ready for the player to shoot.
    private func addBubbleForShooting() {
        let bubblesForShooting = BubbleBlasterEngine.bubblesForShooting
        let bubble = bubblesForShooting[bubblesUsed % bubblesForShooting.count]

        guard let activeBubbleView = model.setUpcomingBubble(for: bubble) else {
            return
        }

        let activeBubbleController = ActiveGameBubbleController(for: activeBubbleView, with: bubble, gameEngine: self)
        readyBubbles.append(activeBubbleController)
        bubblesUsed += 1
    }

    /// Removes all bubbles that are not attached to the top wall.
    private func removeUnattachedBubbles() {
        var visited = grid.map {
            $0.map { _ in return false }
        }

        guard let firstRowIndex = grid.indices.first else {
            return
        }

        func traverseFromTopAndSetVisited() {
            for startCol in grid[firstRowIndex].indices {
                if visited[firstRowIndex][startCol] {
                    continue
                }

                var toVisit = [IndexPath]()
                toVisit.append(IndexPath(item: startCol, section: firstRowIndex))

                while let curIndex = toVisit.popLast() {
                    let row = curIndex.section
                    let col = curIndex.item
                    if !visited.indices.contains(row) || !visited[row].indices.contains(col) ||
                        visited[row][col] || grid[row][col].bubble == nil {
                        continue
                    }

                    visited[row][col] = true
                    let adjacentIndices = getValidIndices(from: layout.getPossibleAdjacentIndices(from: curIndex))
                    toVisit.append(contentsOf: adjacentIndices)
                }
            }
        }

        func removeUnvisitedBubbles() {
            for row in grid.indices {
                for col in grid[row].indices where grid[row][col].bubble != nil && !visited[row][col] {
                    removeBubble(from: grid[row][col], type: .disconnectedFromTop, ignoreTriggers: [])
                }
            }
        }

        traverseFromTopAndSetVisited()
        removeUnvisitedBubbles()
    }

    /// Checks for combos in the grid and carries out the appropriate operations according to them, if any. Only checks
    /// for combos that include the cell at the given `IndexPath`
    ///
    /// - Parameter indexPath: The indexPath to start checking/traversing from.
    private func checkAndProcessCombo(from indexPath: IndexPath) {
        let largestCombo = getLargestCombo(for: getBubbleGrid(), from: indexPath,
                                           currentCombo: [indexPath])

        if largestCombo.count < 3 {
            return
        }

        largestCombo.forEach { removeBubble(from: model.getAllGridCells()[$0.section][$0.item],
                                            type: .combo(size:largestCombo.count), ignoreTriggers: []) }
    }

    /// Gets the largest combo that involves the cells at the given `IndexPath`s in currentCombo, by starting from the
    /// given indexPath in the input grid.
    ///
    /// - Parameters:
    ///   - grid: The bubbles in the game grid as an array of arrays of `GameBubble`s.
    ///   - indexPath: The indexPath to start checking from.
    ///   - currentCombo: The `IndexPath`s of cells that the result has to include.
    /// - Returns: A set of `IndexPath`s of cells that are in the largest combo as described above.
    private func getLargestCombo(for grid: [[GameBubble?]], from indexPath: IndexPath, currentCombo: Set<IndexPath>) ->
            Set<IndexPath> {
        let row = indexPath.section
        let col = indexPath.item

        if !grid.indices.contains(row) || !grid[row].indices.contains(col) {
            return currentCombo
        }

        guard let currentBubble = grid[row][col] else {
            return currentCombo
        }

        if let first = currentCombo.first,
            let firstBubble = grid[first.section][first.item] {
                if !currentBubble.canComboWith(otherBubble: firstBubble) {
                    return currentCombo
                }
        }

        var updatedCombo = currentCombo
        updatedCombo.insert(indexPath)

        var largestCombos = [Set<IndexPath>]()
        for nextIndexPath in layout.getPossibleAdjacentIndices(from: indexPath)
            where !updatedCombo.contains(nextIndexPath) {
            largestCombos.append(getLargestCombo(for: grid, from: nextIndexPath, currentCombo: updatedCombo))
        }

        return largestCombos.reduce(Set<IndexPath>(), { $0.union($1) })
    }

    /// Gets the current bubble grid as an array of array of bubbles
    ///
    /// - Returns: The current bubble grid as an array of array of `GameBubble`s
    private func getBubbleGrid() -> [[GameBubble?]] {
        return model.getAllGridCells().map {
            $0.map {
                $0.bubble
            }
        }
    }
}
