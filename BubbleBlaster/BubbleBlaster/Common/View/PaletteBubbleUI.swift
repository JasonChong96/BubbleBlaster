//
//  PaletteBubbleUI.swift
//  LevelDesigner
//
//  Created by Jason Chong on 3/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

/**
 Represents a Bubble in the Palette's View.
 */
protocol PaletteBubbleUI {
    /// Function to be called whenever this `PaletteBubbleUI` is pressed on the screen
    var palettePressedCallback: (() -> Void)? { get set }

    /// Checks if this bubble is currently pressed. i.e selected
    var isPressed: Bool { get }

    /// Shows the image with the input name in the cell on the screen.
    /// Parameter named: The name of the image to show to the user
    func showImage(named: String)

    /// Sets this bubble to be released. i.e unselected
    func setReleased()

    /// Sets this bubble to be pressed. i.e selected
    func setPressed()
}
