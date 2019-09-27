//
//  CGRect+Hashable.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 27/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit
import Foundation

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(NSCoder.string(for: self))
    }
}
