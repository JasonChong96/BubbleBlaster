//
//  PalleteCollectionViewCell.swift
//  LevelDesigner
//
//  Created by Jason Chong on 30/1/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/**
A ViewCell which represents a Cell in the Palette `UICollectionView`.
 */
class PaletteViewCell: UICollectionViewCell, PaletteBubbleUI {
    var palettePressedCallback: (() -> Void)?

    @IBOutlet private weak var palleteButton: UIButton! {
        didSet {
            palleteButton.layer.cornerRadius = 0.5 * palleteButton.bounds.size.width
        }
    }

    var isPressed: Bool {
        return palleteButton.alpha < 1
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        palettePressedCallback?()
    }

    func showImage(named imageName: String) {
        palleteButton.tintColor = .clear
        palleteButton.setBackgroundImage(UIImage(named: imageName), for: .normal)
    }

    func setPressed() {
        palleteButton.alpha = 0.50
    }

    func setReleased() {
        palleteButton.alpha = 1
    }
}
