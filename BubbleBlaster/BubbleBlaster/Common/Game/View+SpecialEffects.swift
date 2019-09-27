//
//  View+SpecialEffects.swift
//  GameEngine
//
//  Created by Jason Chong on 17/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

extension UIView {
    /// Adds a glow of the input color to the view.
    ///
    /// - Parameter color: `UIColor` of the glow.
    func addGlow(colored color: UIColor) {
        layer.shadowOffset = .zero
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 20
        layer.shadowOpacity = 1
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }

    /// Fades to transparent. This view is then removed from its superview upon completion of the animation
    func fadeOut(withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { [unowned self] in
            self.alpha = 0
        }, completion: { [unowned self] _ in
            self.removeFromSuperview()
        })
    }

    /// Grows to the given scale it's size. This view is then removed from its superview upon completion of the
    /// animation
    func growAndDisappear(scale: CGFloat) {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: { [unowned self] in
            self.transform = self.transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
            }, completion: { [unowned self] _ in self.removeFromSuperview() })
    }
}
