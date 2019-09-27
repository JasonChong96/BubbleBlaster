//
//  UISegueExpand.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 1/3/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Segue for expanding new view.
class UISegueExpand: UIStoryboardSegue {
    var startPoint: CGPoint?

    override func perform() {
        let startPoint = self.startPoint ?? CGPoint.zero
        let src = self.source
        let dst = self.destination
        let initialX = startPoint.x
        let initialY = startPoint.y

        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.alpha = 0.5
        dst.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        dst.view.transform = dst.view.transform.concatenating(
            CGAffineTransform(translationX: initialX - dst.view.frame.origin.x, y:
                initialY - dst.view.frame.origin.y))
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(rotationAngle: 0)
                        dst.view.alpha = 1
        },
                       completion: { _ in
                        src.present(dst, animated: false, completion: nil)
        }
        )
    }
}
