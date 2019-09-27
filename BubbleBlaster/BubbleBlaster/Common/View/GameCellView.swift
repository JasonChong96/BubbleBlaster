//
//  GameCellView.swift
//  LevelDesigner
//
//  Created by Jason Chong on 5/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/**
 Represents a ViewCell in the game area that can contain a `GameBubble`.
 */
class GameCellView: UICollectionViewCell {
    @IBOutlet private weak var imageView: UIImageView!

    /// Checks if this view is currently displaying the input `UIImage`.
    ///
    /// - Parameter image: The `UIImage` to check for.
    ///
    /// - Returns: true if this view is currently displaying the input `UIImage`, Otherwise false.
    func isDisplaying(image: UIImage) -> Bool {
        return imageView.image === image
    }

    func display(image newImage: UIImage) {
        imageView.image = newImage
    }

    func getImage() -> UIImage? {
        return imageView.image
    }
}
