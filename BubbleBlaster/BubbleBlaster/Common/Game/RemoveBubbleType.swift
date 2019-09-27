//
//  RemoveBubbleType.swift
//  GameEngine
//
//  Created by Jason Chong on 17/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

/// Types of bubble removal
///
/// - combo: Remove bubble as part of a combo. Associated value is the combo size.
/// - disconnectedFromTop: Remove bubble as it is disconnected from the top.
/// - explode: Explode all adjacent bubbles.
/// - removeRow: Remove row
enum RemoveBubbleType {
    case combo(size: Int)
    case disconnectedFromTop
    case explode
    case removeRow(isSource: Bool)
}
