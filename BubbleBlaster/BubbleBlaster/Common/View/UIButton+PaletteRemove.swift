//
//  UIButton+PaletteRemove.swift
//  LevelDesigner
//
//  Created by Jason Chong on 5/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

extension UIButton: PaletteRemoveUIButton {
    var isTranslucent: Bool {
        return alpha < 1
    }

    func setTranslucent() {
        alpha = 0.5
    }

    func setOpaque() {
        alpha = 1
    }
}
