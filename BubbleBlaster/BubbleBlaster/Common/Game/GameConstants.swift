//
//  GameConstants.swift
//  LevelDesigner
//
//  Created by Jason Chong on 3/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Encapsulates the constants to be used in this Bubble Blaster game
enum GameConstants {

    /// The maximum length for names of save files.
    static let maxSaveFileNameLength = 10

    /// Refresh Rate of the Game in Hz.
    static let refreshRate = 60

    /// Speed of fired bubbles, in pixels per second.
    static let bubbleSpeed: CGFloat = 1000

    /// Maximum speed of moving bubbles, in pixels per second.
    static var maxBubbleSpeed: CGFloat {
        return 4 * GameConstants.bubbleSpeed
    }

    /// Suffix to use when saving level images
    static let imageSuffix = "$image"

    /// Upcoming Bubbles to display
    static let bubblesToDisplay = 5
}
