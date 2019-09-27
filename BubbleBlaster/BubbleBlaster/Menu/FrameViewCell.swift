//
//  FrameViewCell.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 28/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// ViewCell for a level option in level chooser
class FrameViewCell: UICollectionViewCell {

    /// The view of the frame around the preview image.
    @IBOutlet private weak var frameView: UIImageView!

    /// The name label.
    @IBOutlet private weak var labelView: UILabel! {
        didSet {
            addLabelFade()
        }
    }

    /// The preview image.
    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            addImageViewBorderFade()
        }
    }

    /// Displays the input text on the label view.
    ///
    /// - Parameter name: the name to display on the label view
    func set(name: String) {
        labelView.text = name
    }

    /// Displays the input image on the image view by fading in.
    ///
    /// - Parameter image: The new image to display.
    func set(image: UIImage) {
        imageView.alpha = 0
        imageView.image = image
        UIImageView.animate(withDuration: 0.5) { [weak self] in self?.imageView.alpha = 1 }
    }

    /// Adds a fade effect to the borders of the image view.
    private func addImageViewBorderFade() {
        let maskLayer = CAGradientLayer()
        maskLayer.frame = imageView.bounds
        maskLayer.shadowRadius = 5
        maskLayer.shadowPath = CGPath(roundedRect: imageView.bounds.insetBy(dx: 2, dy: 2), cornerWidth: 10,
                                      cornerHeight: 10, transform: nil)
        maskLayer.shadowOpacity = 1
        maskLayer.shadowOffset = CGSize.zero
        maskLayer.shadowColor = UIColor.white.cgColor
        imageView.layer.mask = maskLayer
    }

    private func addLabelFade() {
        let gradientMaskLayer = CAGradientLayer()
        gradientMaskLayer.frame = labelView.bounds
        gradientMaskLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientMaskLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor,
                                    UIColor.clear.cgColor]
        gradientMaskLayer.locations = [0, 0.3, 0.7, 1]
        labelView.layer.mask = gradientMaskLayer
    }
}
