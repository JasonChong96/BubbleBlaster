//
//  PalleteState.swift
//  LevelDesigner
//
//  Created by Jason Chong on 2/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

/// Represents the state of a Palette.
enum PaletteState {
    case adding(bubble: GameBubble)
    case removing
    case normal
}
