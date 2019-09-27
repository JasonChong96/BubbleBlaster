//
//  LoadError.swift
//  LevelDesigner
//
//  Created by Jason Chong on 6/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

/// Represents an error that occurs when trying to load a save file from storage.
enum LoadError: Error {
    case fileNotFound(String)
    case directoryError(String)
}
