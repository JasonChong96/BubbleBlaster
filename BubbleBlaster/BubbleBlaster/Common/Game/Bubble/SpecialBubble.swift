//
//  IndestructibleBubble.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 27/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

enum SpecialBubble: String, GameBubble, CaseIterable {
    case indestructible, lightning, star, bomb

    var imageName: String {
        switch self {
        case .indestructible:
            return "bubble-indestructible"
        case .lightning:
            return "bubble-lightning"
        case .star:
            return "bubble-star"
        case .bomb:
            return "bubble-bomb"
        }
    }

    var triggerOnSnapAdjacent: TriggerEvent? {
        switch self {
        case .indestructible:
            return nil
        case .lightning:
            return .removeRow
        case .bomb:
            return .explodeAdjacent
        case .star:
            return .removeAllMatching
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let type = try? container.decode(String.self, forKey: CodingKeys.type) else {
            throw DecodeError.missingValue("Missing color value")
        }

        guard let decodedBubble = SpecialBubble(rawValue: type) else {
            throw DecodeError.invalidValue("Color is invalid")
        }

        self = decodedBubble
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(rawValue, forKey: CodingKeys.type)
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
