//
//  PalleteBubble.swift
//  LevelDesigner
//
//  Created by Jason Chong on 3/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/**
 Encapsulates and supports the mutation of the state of a bubble in the Palette.
 Also encapsulates the logic to manipulate the user interface of this bubble.
 */
struct PaletteBubbleController {
    /// The interface or View of the bubble.
    private var interface: PaletteBubbleUI {
        didSet {
            interface.palettePressedCallback = callButtonPressedCallback
        }
    }

    /// The bubble as a `GameBubble`
    let bubble: GameBubble

    /// The function to be called when this bubble is pressed by the user.
    var buttonPressedCallback: ((PaletteBubbleController) -> Void)? {
        didSet {
            interface.palettePressedCallback = callButtonPressedCallback
        }
    }

    /// Checks if this bubble is currently pressed. i.e selected
    var isPressed: Bool {
        return interface.isPressed
    }

    /// Constructor that creates a `PaletteBubbleController` with the given `PaletteBubbleUI`
    /// and the given `GameBubble`.
    ///
    /// - Parameters:
    ///     - interface: The user interface of this bubble that conforms to `PaletteBubbleUI`
    ///     - bubble: The bubble represented by this palette bubble
    init(withInterface interface: PaletteBubbleUI, containing bubble: GameBubble) {
        self.interface = interface
        self.bubble = bubble
        self.interface.showImage(named: bubble.imageName)
    }

    /// Calls the appropriate function for when this bubble is pressed.
    func callButtonPressedCallback() {
        buttonPressedCallback?(self)
    }

    /// Sets this bubble to be in the released state. i.e unselected
    func setReleased() {
        interface.setReleased()
    }

    /// Sets this bubble to be in the pressed state. i.e selected
    func setPressed() {
        interface.setPressed()
    }
}
