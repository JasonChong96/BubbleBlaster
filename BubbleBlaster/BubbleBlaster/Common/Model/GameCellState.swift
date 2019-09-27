//
//  GameCellState.swift
//  LevelDesigner
//
//  Created by Jason Chong on 6/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

/// Represents the state of a `GameCell`. i.e Whether it contains a
/// `GameBubble` and what `GameBubble` it contains, if any.
enum GameCellState {
    case contains(bubble: GameBubble)
    case empty

    /// Return the appropriate state for a `GameCell` containing
    /// the input `GameBubble`.
    static func getStateForContaining(bubble: GameBubble?) -> GameCellState {
        guard let unwrappedBubble = bubble else {
            return .empty
        }

        return .contains(bubble: unwrappedBubble)
    }
}

extension GameCellState: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let bubbleTypeString = try? container.decode(String.self, forKey: CodingKeys.bubbleType) else {
            self = .empty
            return
        }

        guard let bubbleType = GameBubbleType(rawValue: bubbleTypeString) else {
            throw DecodeError.invalidValue("Invalid bubble type \(bubbleTypeString)")
        }

        let bubble = try GameBubbleUtil.decodeGameBubble(ofType: bubbleType, from: decoder)

        self = .contains(bubble: bubble)
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .empty:
            return
        case .contains(let bubble):
            try GameBubbleUtil.encode(bubble: bubble, to: encoder)
        }
    }

    enum CodingKeys: String, CodingKey {
        case bubbleType
    }
}
