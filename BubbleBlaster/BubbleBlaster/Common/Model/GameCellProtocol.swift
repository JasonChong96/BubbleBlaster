//
//  GameCellProtocol.swift
//  GameEngine
//
//  Created by Jason Chong on 18/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//
/// Protocol for implementing a game cell in the model fhr the controller to use.
protocol GameCellProtocol: class, Codable {

    /// Observer for this game cell.
    var observer: GameCellObserver? { get set }

}
