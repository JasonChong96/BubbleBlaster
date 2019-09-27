//
//  UISegueFade.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 28/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Segue where new view fades in.
class UISegueFade: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dst = self.destination

        dst.view.alpha = 0
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        dst.view.alpha = 1
        },
                       completion: { _ in
                        src.present(dst, animated: false, completion: nil)
        }
        )
    }
}
