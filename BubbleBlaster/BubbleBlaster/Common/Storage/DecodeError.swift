//
//  DecodeError.swift
//  LevelDesigner
//
//  Created by Jason Chong on 6/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

/// Represents an error that occurs while decoding save files.
enum DecodeError: Error {
    case missingValue(String)
    case invalidValue(String)
}
