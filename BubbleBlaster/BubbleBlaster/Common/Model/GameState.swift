//
//  GameState.swift
//  GameEngine
//
//  Created by Jason Chong on 18/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit
import a0164721j_PhysicsEngine

/// Model representing the state of the game in memory.
class GameState {
    /// Bounds of the game area.
    let bounds: CGRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 1024, height: 1346))

    /// The layout of the grid.
    var gridLayout: BubbleBlasterCellsLayout {
        return persistantState.gridLayout
    }

    var numOfShooters: Int {
        get {
            return persistantState.numOfShooters
        }

        set {
            persistantState.numOfShooters = newValue
        }
    }

    var numShots = 0 {
        didSet {
            observer?.scoreUpdated(score: numShots)
        }
    }

    /// Persistant state of the game
    private var persistantState: GameStatePersistant

    /// Mobile bubbles
    private(set) var mobileBubbles = [MobileBubble]()

    /// Mobile bubble that is ready for the user to shoot.
    private(set) var readyBubbles: [MobileBubbleBlasterBubble?] = [nil, nil]

    /// Upcoming mobile bubbles
    var upcomingBubbles = [MobileBubbleBlasterBubble]()

    weak var observer: GameStateObserver? {
        didSet {
            observer?.scoreUpdated(score: numShots)
        }
    }

    convenience init() {
        self.init(gridLayout: .isometric)
    }

    init(gridLayout: BubbleBlasterCellsLayout) {
        persistantState = GameStatePersistant(withLayout: gridLayout)
        persistantState.updateFrames(withGenerator: rectForItem)
    }

    /// Gets all cells as a protocol for usage by the controller component.
    ///
    /// - Returns: An array of arrays of `GameCellProtocol` according to their positiion in the grid.
    func getAllCellsForController() -> [[GameCellProtocol]] {
        return persistantState.cells
    }

    /// Called when the player shoots the bubble.
    ///
    /// - Parameters:
    ///   - bubble: The bubble shot
    ///   - direction: The direction which the user has shot the bubble.
    func playerShot(_ bubble: MobileBubbleBlasterBubble, in direction: CGPoint) {
        numShots += 1
        readyBubbles = readyBubbles.map { $0 === bubble ? nil : $0 }
        (bubble as? MobileBubble)?.playerShot(in: direction)
        tryPushUpcomingBubble()
    }

    /// Retrieves the cell at the given posision
    ///
    /// - Parameters:
    ///   - row: The row the cell is on.
    ///   - col: The column the cell is on
    /// - Returns: The cell if it exists. Otherwise, nil is returned.
    func getCellAt(row: Int, col: Int) -> GameCell? {
        return persistantState.getCellAt(row: row, col: col)
    }

    /// Sets the cell at the given row and col to contain the input bubble. Removes bubble in cell if the bubble is nil.
    ///
    /// - Parameters:
    ///   - row: row of the cell.
    ///   - col: column of the cell.
    ///   - bubble: The new bubble to insert into the cell.
    func setCell(atRow row: Int, col: Int, to bubble: GameBubble?) {
        persistantState.setCell(atRow: row, andCol: col, toBubble: bubble)
    }

    /// Loads the saved file that matches the input name
    ///
    /// - Parameter name: the name of the saved file.
    /// - Throws: Error if unable to load and decode the saved file.
    func loadSavedFile(named name: String) throws {
        try persistantState = StorageManager.loadSaveFile(named: name)
    }

    /// Saves the persistent state as the input name.
    ///
    /// - Parameter name: The name of the save file.
    /// - Throws: Error if unable to encode and save the file.
    func saveCells(as name: String) throws {
        try StorageManager.save(object: persistantState, as: name)
    }

    func gameEnded() {
        observer?.gameEnded(numShots: numShots)
    }

    /// Calculates the `CGRect` of the item at the input `IndexPath`.
    ///
    /// - Parameter indexPath: The indexPath of the item
    ///
    /// - Returns: A `CGRect` representing the position of the item
    private func rectForItem(at indexPath: IndexPath) -> CGRect {
        return gridLayout.rectForItem(at: indexPath, in: bounds)
    }

    private func tryPushUpcomingBubble() {
        guard let index = readyBubbles.firstIndex(where: { $0 === nil }),
            index < numOfShooters,
            !upcomingBubbles.isEmpty else {
            return
        }

        let bubble = upcomingBubbles.removeFirst()
        let yCoord = (bounds.height * 3 / 4).rounded()
        var xCoord = bounds.width / 2 - bubble.frame.width / 2

        if numOfShooters == 2 {
            xCoord += (index == 0 ? -bounds.width : bounds.width) / 4
        }
        xCoord = xCoord.rounded()

        bubble.displace(by: CGPoint(x: xCoord, y: yCoord) - CGPoint(x: (bubble.frame.origin.x).rounded(),
                                                                    y: (bubble.frame.origin.y).rounded()))
        for upcomingBubble in upcomingBubbles {
            upcomingBubble.displace(by: CGPoint(x: -(upcomingBubble.frame.width * 1.5).rounded(), y: 0))
        }

        readyBubbles[index] = bubble
    }
}

extension GameState: MobileBubbleObserver {
    func removed(mobileBubble: MobileBubble, isAttached: Bool) {
        mobileBubbles = mobileBubbles.filter { mobileBubble !== $0 }
    }
}

extension GameState: BubbleBlasterState {
    func setUpcomingBubble(for bubble: GameBubble) -> MobileBubbleBlasterBubble? {
        let cellRect = rectForItem(at: IndexPath(item: 0, section: 0))
        let size = CGSize(width: cellRect.width, height: cellRect.height)
        let yCoord: CGFloat = (bounds.height - size.height - 20).rounded()
        let xCoord: CGFloat = (bounds.width / 2 - size.width / 2 + CGFloat(upcomingBubbles.count) * size.width * 1.5)
            .rounded()

        let mobileBubble = MobileBubble(frame: CGRect(origin: CGPoint(x: xCoord, y: yCoord), size: size),
                                        bubble: bubble)
        mobileBubbles.append(mobileBubble)
        mobileBubble.add(observer: self)
        upcomingBubbles.append(mobileBubble)
        tryPushUpcomingBubble()

        return mobileBubble
    }

    func getAllGridCells() -> [[GridCell]] {
        return persistantState.cells
    }
}
