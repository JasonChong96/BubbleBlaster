//
//  UISegueFromLeft.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 28/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Segue where new view is pushed in from the left.
class UISegueFromLeft: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dst = self.destination

        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)

        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
                        src.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        },
                       completion: { _ in
                        src.present(dst, animated: false, completion: nil)
        }
        )
    }
}
