//
//  GameCell.swift
//  LevelDesigner
//
//  Created by Jason Chong on 2/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//
import UIKit
import a0164721j_PhysicsEngine

/// Encapsulates a game cell in the model.
class GameCell {

    /// Observer for this game cell.
    weak var observer: GameCellObserver?

    /// The state of this game cell
    private(set) var state: GameCellState

    /// The row on the grid that this game cell is on.
    let row: Int

    /// The column on the grid that this game cell is on.
    let col: Int

    /// The frame of this cell. Represents the position and size of this cell.
    var frame = CGRect.zero

    /// Constructor that creates a `GameCell` with the input state.
    ///
    /// - Parameter state: The state of the `GameCell`
    init(state: GameCellState, row: Int, col: Int) {
        self.col = col
        self.row = row
        self.state = state
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.row = try container.decode(Int.self, forKey: .row)
        self.col = try container.decode(Int.self, forKey: .col)
        self.state = try container.decode(GameCellState.self, forKey: .state)
        self.frame = try container.decode(CGRect.self, forKey: .frame)
    }

    enum CodingKeys: String, CodingKey {
        case state, row, col, frame
    }
}

extension GameCell: GridCell {
    func hit(by otherObject: MobileObject2D) {  }

    func set(bubble: GameBubble) {
        state = GameCellState.getStateForContaining(bubble: bubble)
        observer?.cellBubbleChanged(atRow: row, col: col, to: bubble)
    }

    func removeBubble(type: RemoveBubbleType?) {
        state = GameCellState.getStateForContaining(bubble: nil)
        observer?.cellBubbleRemoved(atRow: row, col: col, removalType: type)
    }
}

extension GameCell: GameCellProtocol {
    var bubble: GameBubble? {
        switch state {
        case .contains(let containedBubble):
            return containedBubble
        case .empty:
            return nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(state, forKey: .state)
        try container.encode(frame, forKey: .frame)
        try container.encode(row, forKey: .row)
        try container.encode(col, forKey: .col)
    }
}
