//
//  UISegueLevelDesigner.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 1/3/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Segue specifically and only for opening level designer from the level designer button in the title screen.
/// Expands the level designer from the middle of the button.
class UISegueLevelDesigner: UISegueExpand {
    override func perform() {
        guard let src = self.source as? TitleViewController else {
            self.source.present(self.destination, animated: true, completion: nil)
            return
        }

        let initialX = src.levelDesignerButtonFrame.midX
        let initialY = src.levelDesignerButtonFrame.midY

        self.startPoint = CGPoint(x: initialX, y: initialY)
        super.perform()
    }
}
