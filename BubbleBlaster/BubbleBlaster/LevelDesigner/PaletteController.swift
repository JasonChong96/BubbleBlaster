//
//  Palette.swift
//  LevelDesigner
//
//  Created by Jason Chong on 1/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/**
 Encapsulates the logic in the controller component that is related to the Palette
 */
class PaletteController {
    /// The `GameBubble`s available in the palette.
    let paletteBubbles = GameBubbleUtil.getAllUniqueBubbles()

    /// The controllers for each palette bubble.
    var bubbleControllers = [PaletteBubbleController]()

    /// The remove button view in the palette.
    var removeButton: PaletteRemoveUIButton?

    /// The bubble chosen by the user to use.
    var bubbleChosen: GameBubble? {
        return bubbleControllers.first { $0.isPressed }?.bubble
    }

    /// The state of this palette.
    var state: PaletteState

    /// Constructor that creates a `PaletteController` that contains the input paletteBubbles
    ///
    /// - Parameter paletteBubbles: An array of `GameBubbles` to be used in this palette.
    init() {
        self.state = .normal
    }

    /// Performs the functions needed when the remove button is pressed. i.e Changes the palette's
    /// state to remove bubbles from the grid if it isn't already. If the palette is already in
    /// the removing state, then it resets the state to the default.
    func removeButtonPressed() {
        if removeButton?.isTranslucent ?? true {
            changeTo(state: .normal)
        } else {
            changeTo(state: .removing)
        }
    }

    /// Adds a bubble with a given user interface that conforms to `PaletteBubbleUI` to the
    /// input `IndexPath` in the Palette
    /// - Parameters:
    ///     - cell: The user interface of the bubble
    ///     - indexPath: The position where the interface will be added to in this palette
    func addBubble(withInterface cell: PaletteBubbleUI, atIndex indexPath: IndexPath) {
        bubbleControllers.append(initBubbleController(withInterface: cell, atIndex: indexPath.item))
    }

    /// Initializes the controller for a given user interface that conforms to `PaletteBubbleUI`
    /// - Parameters:
    ///     - cell: The user interface of the bubble
    ///     - indexPath: The position where the interface in this palette
    /// - Returns: A `PaletteBubbleController` for the given bubble.
    private func initBubbleController(withInterface cell: PaletteBubbleUI, atIndex index: Int) ->
        PaletteBubbleController {
            var bubbleController = PaletteBubbleController(withInterface: cell, containing: paletteBubbles[index])
            bubbleController.buttonPressedCallback = palleteButtonPressed

            return bubbleController
    }

    /// Changes the state of this palette according to the input `PaletteBubbleController` when it is pressed.
    /// If the bubble is already in the presssed state then the palette's state will be set back to normal.
    /// If not, then the palette will be set to be using the bubble of the PaletteBubble pressed.
    ///
    /// - Parameter sender: the PaletteBubbleController of the palette bubble pressed.
    func palleteButtonPressed(_ sender: PaletteBubbleController) {
        if sender.isPressed {
            changeTo(state: .normal)
        } else {
            changeTo(state: .adding(bubble: sender.bubble))
        }
    }

    /// Applies the chosen pallete bubble to or removes the bubble from the input `UICollectionViewCell` .
    /// The action depends on the state of this palette.
    ///
    /// - Parameters:
    ///     - cell: The `UICollectionViewCell` to apply this palette to.
    ///     - controller: The controller for the game cells which conforms to `GameBubblesControllerDelegate`.
    func apply(to cell: UICollectionViewCell, through controller: GameCellsControllerProtocol) {
        switch state {
        case .normal:
            return
        case .adding(let bubble):
            controller.apply(palleteBubble: bubble, to: cell)
        case .removing:
            controller.apply(palleteBubble: nil, to: cell)
        }
    }

    /// Changes the state of the palette.
    ///
    /// - Parameter newState: The new state of the Palette.
    private func changeTo(state newState: PaletteState) {
        state = newState
        switch newState {
        case .normal:
            bubbleControllers.forEach { $0.setReleased() }
            removeButton?.setOpaque()
        case .adding(let newBubble):
            bubbleControllers.forEach { $0.setReleased() }
            bubbleControllers.first { $0.bubble.sameImageAs(otherBubble: newBubble) }?.setPressed()
            removeButton?.setOpaque()
        case .removing:
            bubbleControllers.forEach { $0.setReleased() }
            removeButton?.setTranslucent()
        }
    }
}
