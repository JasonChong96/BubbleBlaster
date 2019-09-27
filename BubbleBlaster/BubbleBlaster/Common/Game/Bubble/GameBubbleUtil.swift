//
//  GameBubbleUtil.swift
//  LevelDesigner
//
//  Created by Jason Chong on 6/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

/// Provides utility methods for `GameBubble`. Cannot be instantiated.
enum GameBubbleUtil {

    /// Decodes a `GameBubble` of the given type from the given decoder.
    ///
    /// - Parameters:
    ///     - type: The type of the `GameBubble`
    ///     - decoder: The decoder containing the state of the bubble.
    static func decodeGameBubble(ofType type: GameBubbleType, from decoder: Decoder) throws -> GameBubble {
        switch type {
        case .normal:
            return try NormalBubble(from: decoder)
        case .special:
            return try SpecialBubble(from: decoder)
        }
    }

    /// Encode a `GameBubble` of the given type to the given encoder.
    ///
    /// - Parameters:
    ///     - type: The type of the `GameBubble`
    ///     - decoder: The decoder containing the state of the bubble.
    static func encode(bubble: GameBubble, to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if bubble as? NormalBubble != nil {
            try container.encode(GameBubbleType.normal.rawValue, forKey: CodingKeys.bubbleType)
        } else if bubble as? SpecialBubble != nil {
            try container.encode(GameBubbleType.special.rawValue, forKey: CodingKeys.bubbleType)
        } else {
            throw DecodeError.invalidValue("Unsupported bubble")
        }

        try bubble.encode(to: encoder)
    }

    /// Gets an instance of each unique bubble.
    ///
    /// - Returns: An array of unique bubbles (different kind)
    static func getAllUniqueBubbles() -> [GameBubble] {
        return [GameBubble](NormalBubble.allCases) + [GameBubble](SpecialBubble.allCases)
    }

    /// Gets an instance of each bubble in the level designer in the order in which they should be changed
    /// to when tapped.
    ///
    /// - Returns: An array of said bubbles
    static func getCycleBubbles() -> [GameBubble] {
        return [GameBubble](NormalBubble.allCases)
    }

    /// Gets an instance of each normal bubble
    ///
    /// - Returns: An array of all normal bubbles
    static func getAllNormalBubbles() -> [GameBubble] {
        return [GameBubble](NormalBubble.allCases)
    }

    enum CodingKeys: String, CodingKey {
        case bubbleType
    }
}
