//
//  NormalBubble.swift
//  LevelDesigner
//
//  Created by Jason Chong on 30/1/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

/// Encapsulates a normal bubble with no special properties. Can be of different
/// colors and only those of the same color match each other.
enum NormalBubble: String, GameBubble, CaseIterable {
    case red, blue, green, orange

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let color = try? container.decode(String.self, forKey: CodingKeys.color) else {
            throw DecodeError.missingValue("Missing color value")
        }

        guard let decodedBubble = NormalBubble(rawValue: color) else {
            throw DecodeError.invalidValue("Color is invalid")
        }

        self = decodedBubble
    }

    var triggerOnSnapAdjacent: TriggerEvent? {
        return nil
    }

    var imageName: String {
        switch self {
        case .red:
            return "bubble-red"
        case .blue:
            return "bubble-blue"
        case .green:
            return "bubble-green"
        case .orange:
            return "bubble-orange"
        }
    }

    func canComboWith(otherBubble: GameBubble) -> Bool {
        return self == otherBubble as? NormalBubble
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(rawValue, forKey: CodingKeys.color)
    }

    enum CodingKeys: String, CodingKey {
        case color
    }
}
