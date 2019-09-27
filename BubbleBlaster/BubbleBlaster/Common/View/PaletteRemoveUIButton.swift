//
//  PaletteRemoveButtonUI.swift
//  LevelDesigner
//
//  Created by Jason Chong on 4/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

/**
 Represents a Button View that can be used as the Remove button
 interface in a palette.
*/
protocol PaletteRemoveUIButton {
    /// Checks if the button is translucent. i.e not opaque
    var isTranslucent: Bool { get }

    /// Makes the button translucent on the screen.
    mutating func setTranslucent()

    /// Makes the button opaque on the screen.
    mutating func setOpaque()
}
