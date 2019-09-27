//
//  UIImageCodableWrapper.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 28/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Wrapper to encode/decode UIImage using low quality jpg compression.
struct UIImageCodableWrapper: Codable {
    let image: UIImage?

    init(image: UIImage?) {
        self.image = image
    }

    public init(from decoder: Decoder) throws {
        self.image = UIImage(data: try Data(from: decoder))
    }

    public func encode(to encoder: Encoder) throws {
        guard let imageData = image?.jpegData(compressionQuality: 0.0001) else {
            return
        }
        try imageData.encode(to: encoder)
    }
}
