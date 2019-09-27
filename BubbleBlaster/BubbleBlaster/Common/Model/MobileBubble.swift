//
//  MobileBubble.swift
//  GameEngine
//
//  Created by Jason Chong on 19/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Encapsulates a Bubble in the model that is capable of movement.
class MobileBubble: MobileBubbleBlasterBubble {

    /// Observers for this mobile bubble. Listening to an event where a player has shot this bubble.
    private(set) var observers = [WeakMobileBubbleObserver]()

    var mass: CGFloat = 1
    var frame: CGRect
    var velocity: CGPoint
    let bubble: GameBubble
    weak var bubbleBlasterObserver: MobileBubbleBlasterBubbleObserver?

    init(frame: CGRect, bubble: GameBubble) {
        self.frame = frame
        self.velocity = CGPoint.zero
        self.bubble = bubble
    }

    func displace(by displacement: CGPoint) {
        frame = frame.applying(CGAffineTransform(translationX: displacement.x, y: displacement.y))
    }

    func removeFromGame(isAttached: Bool) {
        observers.forEach {
            $0.observer?.removed(mobileBubble: self, isAttached: isAttached)
        }
    }

    func add(observer: MobileBubbleObserver) {
        observers.append(WeakMobileBubbleObserver(observer: observer))
    }

    func playerShot(in direction: CGPoint) {
        bubbleBlasterObserver?.playerShot(self, in: direction)
    }

    enum CodingKeys: String, CodingKey {
        case mass, frame, velocity, bubble
    }
}

extension MobileBubble: Hashable {
    static func == (lhs: MobileBubble, rhs: MobileBubble) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
