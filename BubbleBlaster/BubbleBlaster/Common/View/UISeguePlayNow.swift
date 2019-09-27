//
//  UISeguePlayNow.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 1/3/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Segue specifically for opening a level from level chooser. Expands the level view from the preview image.
class UISeguePlayNow: UISegueExpand {
    override func perform() {
        guard let src = self.source as? LevelChooserViewController else {
            self.source.present(self.destination, animated: true, completion: nil)
            return
        }

        let chosenFrame = src.chosenFrame ?? CGRect.zero
        let initialX = chosenFrame.midX
        let initialY = chosenFrame.midY

        self.startPoint = CGPoint(x: initialX, y: initialY)
        super.perform()
    }
}
