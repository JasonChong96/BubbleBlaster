//
//  UIView+Translate.swift
//  GameEngine
//
//  Created by Jason Chong on 19/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

extension UIView {
    /// Transforms the frame of this view to match the given frame, which is of a different scale due to being in the
    /// given other bound. This view will be scaled and transformed to have a frame equivalent of the given frame.
    ///
    /// - Parameters:
    ///   - otherBounds: The bounds that contain the other frame.
    ///   - otherFrame: The frame to match.
    func translateFromDifferentScale(otherBounds: CGRect, otherFrame: CGRect) {
        guard let bounds = superview?.bounds else {
            return
        }

        let ratio = min(bounds.width / otherBounds.width, bounds.height / otherBounds.height)

        let finalWidth = ratio * otherFrame.width
        let finalHeight = ratio * otherFrame.height

        if frame.height != finalHeight || frame.width != finalWidth {
        /// Transforms the size of the view to match.
            transform = transform.concatenating(
                CGAffineTransform(scaleX: finalWidth / frame.width, y: finalHeight / frame.height))
        }

        let finalX = ratio * otherFrame.origin.x
        let finalY = ratio * otherFrame.origin.y

        if frame.origin.x != finalX || frame.origin.y != finalY {
            /// Changes the position of the view to match.
            transform = transform.concatenating(
                CGAffineTransform(translationX: finalX - frame.origin.x, y: finalY - frame.origin.y))
        }
    }
}
