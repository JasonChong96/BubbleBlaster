//
//  GameStateObserver.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 27/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

/// Protocol to observe the game state to receive notification of the game ending and score updates
protocol GameStateObserver: class {
    func gameEnded(numShots: Int)
    func scoreUpdated(score: Int)
}
