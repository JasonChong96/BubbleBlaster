//
//  ActiveGameBubbleController.swift
//  GameEngine
//
//  Created by Jason Chong on 15/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit
import a0164721j_PhysicsEngine

/// Encapsulates the logic for an active `GameBubble`.
class ActiveGameBubbleController {
    /// The `GameBubble` that is active.
    private let bubble: GameBubble

    /// The model for this active bubble.
    private let model: MobileBubbleBlasterBubble

    /// The game engine this active game bubble is for.
    weak var gameEngine: BubbleBlasterEngine?

    var velocity: CGPoint
    var mass: CGFloat = 1

    /// Contructor for an ActiveGameBubbleController that has the given `MobileBubbleBlasterBubble`, `GameBubble` and
    /// `BubbleBlasterEngine`.
    ///
    /// - Parameters:
    ///   - model: The model for the bubble that conforms to `MobileBubbleBlasterBubble`
    ///   - bubble: The bubble as a `GameBubble`
    ///   - gameEngine: The `BubbleBlasterEngine` for this game.
    init(for model: MobileBubbleBlasterBubble, with bubble: GameBubble, gameEngine: BubbleBlasterEngine) {
        self.model = model
        self.bubble = bubble
        self.gameEngine = gameEngine
        self.velocity = CGPoint.zero
        model.bubbleBlasterObserver = self
    }
}

extension ActiveGameBubbleController: MobileObject2D {

    var frame: CGRect {
        return model.frame
    }

    func handle(events: [PhysicsEvent]) -> PhysicsReaction? {
        var reaction: PhysicsReaction?
        var collisions = [CollisionInfo]()
        var snapToEmptyCell = false

        func processEvents() {
            for event in events {
                switch event {
                case .collisionWithBottomBound(let atY):
                    reaction = .reflectUp(atY: atY)
                case .collisionWithRightBound(let atX):
                    reaction = .reflectLeft(atX: atX)
                case .collisionWithLeftBound(let atX):
                    reaction = .reflectRight(atX: atX)
                case .collisionWithTopBound:
                    snapToEmptyCell = true
                case .collision(let info):
                    collisions.append(info)
                }
            }
        }

        func processCollisionWithOtherMobileObjects() {
            for collision in collisions where collision.otherObject as? MobileObject2D != nil {
                reaction = .reflectOffMobileObject(inCollision: collision)
                break
            }
        }

        func snapToClosestEmptyCellIfAppropriate() {
            if snapToEmptyCell {
                reaction = .disappear
                snapTo(cell: getClosestEligibleEmptyCell(outOf: collisions))
            }
        }

        processEvents()
        processCollisionWithOtherMobileObjects()

        snapToEmptyCell = snapToEmptyCell || !collisions
            .compactMap { ($0.otherObject as? GridCell)?.bubble }
            .isEmpty

        snapToClosestEmptyCellIfAppropriate()

        return reaction
    }

    func displace(by displacement: CGPoint) {
        model.displace(by: displacement)
    }

    func hit(by otherObject: MobileObject2D) {    }

    /// Snaps this bubble to the cell associated with the given view. If the cell is nil, does nothing.
    ///
    /// - Parameter cell: The `BubbleBlasterCellView` associated to the cell to be snapped to.
    private func snapTo(cell: GridCell?) {
        if let cell = cell {
            getGameEngine().attach(bubble, to: cell)
        }

        model.removeFromGame(isAttached: cell != nil)
    }

    /// Gets the closest empty cell out of all the cells associated with the input collisions, if any.
    ///
    /// - Parameter collisions: The array of collisions as `CollisionInfo`
    /// - Returns: The closest empty cell if there are any. Else, returns nil.
    private func getClosestEligibleEmptyCell(outOf collisions: [CollisionInfo]) -> GridCell? {
        var minDistance = CGFloat.greatestFiniteMagnitude
        var closestEmptyCell: GridCell?

        for collision in collisions {
            let distance = frame.centerDistance(from: collision.otherObjectFrame)
            if let cell = collision.otherObject as? GridCell {
                if distance < minDistance && cell.bubble == nil && getGameEngine().canHoldBubble(cell) {
                    minDistance = distance
                    closestEmptyCell = cell
                }
            }
        }

        return closestEmptyCell
    }

    private func getGameEngine() -> BubbleBlasterEngine {
        guard let gameEngine = gameEngine else {
            preconditionFailure("Game engine reference lost.")
        }

        return gameEngine
    }
}

extension ActiveGameBubbleController: MobileBubbleBlasterBubbleObserver {
    /// Shoots the input active bubble if it has yet to be shot. The bubble will be shot in the given direction but the
    /// magnitude will be fixed at the predefined speed according to `GameConstants`.
    ///
    /// - Parameters:
    ///     - bubble: The `MobileBubbleBlasterBubble` implementing instance to be shot.
    ///     - direction: The direction in which the player shoots the bubble.
    func playerShot(_ bubble: MobileBubbleBlasterBubble, in direction: CGPoint) {
        if velocity != CGPoint.zero {
            return
        }

        let magnitude = sqrt(pow(direction.x, 2) + pow(direction.y, 2))
        let unitVector = direction.applying(CGAffineTransform(scaleX: 1 / magnitude, y: 1 / magnitude))
        let speed = GameConstants.bubbleSpeed
        let newVelocity =  unitVector.applying(CGAffineTransform(scaleX: speed, y: speed))

        velocity = newVelocity
        getGameEngine().playerShot(self)
    }
}
