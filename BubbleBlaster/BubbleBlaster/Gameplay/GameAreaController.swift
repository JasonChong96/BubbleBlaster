//
//  GameAreaController.swift
//  GameEngine
//
//  Created by Jason Chong on 15/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Controller for the game area.
class GameAreaController {

    /// The View of the game area.
    private unowned var gameArea: UIView

    /// Game State
    private let gameState: GameState

    /// CacheOfViews
    private var movingViews = [MobileBubble: UIImageView]()

    /// The bounds of the game area.
    private var bounds: CGRect {
        return gameArea.bounds
    }

    private var guideLineLayers = [CAShapeLayer(), CAShapeLayer()]
    private var guideLinePaths = [UIBezierPath(), UIBezierPath()]
    private var initialPanPosition = CGPoint.zero
    private var cannons = [CGPoint: UIImageView]()

    /// Constructor the a `GameAreaController` instance that controls the input game area.
    ///
    /// - Parameter gameArea: `UIView` of the game area.
    init(gameArea: UIView, model: GameState) {
        self.gameArea = gameArea
        self.gameState = model
        initGuideLineLayers()
    }

    /// Sync moving objects with model
    func sync() {
        let models = gameState.mobileBubbles
        for model in models {
            let view: UIImageView
            if let cachedView = movingViews[model] {
                view = cachedView
            } else {
                view = UIImageView(image: UIImage(named: model.bubble.imageName))
                model.add(observer: self)
                if let cannonView = cannons[model.frame.origin] {
                    gameArea.insertSubview(view, belowSubview: cannonView)
                } else {
                    gameArea.addSubview(view)
                }
                movingViews[model] = view
            }

            view.translateFromDifferentScale(otherBounds: gameState.bounds, otherFrame: model.frame)
        }

        initUncreatedCannons()
    }

    /// Called when the user pans over the game area. Handles the display of the aiming guide line and shooting of the
    /// bubble when the user's pan ends. The bubble will be shot in the direction opposite of the pan translation.
    ///
    /// - Parameters:
    ///   - translation: The translation of the pan as a `CGPoint`.
    ///   - isEnded: Whether the pan has ended.
    ///   - isLeft: true only if the pan was started on the left side of the game area.
    func onUserPanChanged(to translation: CGPoint, isEnded: Bool, isLeft: Bool) {
        let readyBubbleIndex = isLeft ? 0 : 1
        let guideLineLayer = self.guideLineLayers[readyBubbleIndex]
        guideLineLayer.path = nil

        guard let readyBubble = gameState.readyBubbles[readyBubbleIndex],
            let view = movingViews.first(where: { $0.0 === readyBubble })?.1 else {
            return
        }

        guard let cannonView = cannons[readyBubble.frame.origin] else {
            return
        }

        if translation.y <= 0 || translation.x == 0 {
            return
        }

        if cannonView.isAnimating {
            return
        }

        let frame = view.frame
        let reversed = translation.applying(CGAffineTransform(scaleX: -1, y: -1))

        if isEnded {
            guideLineLayer.path = nil
            gameState.playerShot(readyBubble, in: reversed)
            cannonView.startAnimating()

        } else {
            let startPoint = CGPoint(x: frame.midX, y: frame.midY)
            let path = UIBezierPath()
            path.move(to: startPoint)
            path.addLine(to: startPoint.applying(CGAffineTransform(translationX: reversed.x, y: reversed.y)))
            guideLineLayer.path = path.cgPath
            guideLinePaths[readyBubbleIndex] = path

            setRotation(of: cannonView, to: -atan(reversed.x / reversed.y))
        }
    }

    /// Sets the rotation angle of the input view to the input angle.
    ///
    /// - Parameters:
    ///   - view: The view to rotate.
    ///   - angle: The angle of rotation (in radians).
    private func setRotation(of view: UIImageView, to angle: CGFloat) {
        gameArea.bringSubviewToFront(view)
        let oldAngle = atan2(view.transform.b, view.transform.a)
        view.transform = view.transform.rotated(by: angle - oldAngle)
    }

    /// Initialize uncreated cannons
    private func initUncreatedCannons() {
        for readyBubble in gameState.readyBubbles {
            guard let bubble = readyBubble,
                let frame = movingViews.first(where: { $0.0 === readyBubble })?.1.frame else {
                    return
            }

            let origin = bubble.frame.origin
            if cannons[origin] == nil {
                let image = UIImage(named: "cannon1")
                let imageView = UIImageView(image: image)
                gameArea.addSubview(imageView)
                imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.81)
                let curY = imageView.frame.origin.y + 0.81 * imageView.frame.height
                let curX = imageView.frame.midX
                let translationX = frame.midX - curX
                let translationY = frame.midY - curY
                imageView.transform = CGAffineTransform(translationX: translationX, y: translationY)
                cannons[origin] = imageView

                var frames = [UIImage]()
                for frameNo in 2...12 {
                    guard let frame = UIImage(named: "cannon" + String(frameNo)) else {
                        continue
                    }

                    frames.append(frame)
                }
                imageView.animationImages = frames
                imageView.animationDuration = 0.25
                imageView.animationRepeatCount = 1
            }
        }
    }

    /// Initializes the `CAShapeLayer` for displaying the shooting guide line to the user.
    private func initGuideLineLayers() {
        for guideLineLayer in guideLineLayers {
            guideLineLayer.strokeColor = UIColor.black.cgColor
            guideLineLayer.fillColor = UIColor.clear.cgColor
            guideLineLayer.lineWidth = 4.0
            guideLineLayer.lineDashPattern = [10.0, 2.0]
            gameArea.layer.addSublayer(guideLineLayer)
        }
    }

}

extension GameAreaController: MobileBubbleObserver {
    func removed(mobileBubble: MobileBubble, isAttached: Bool) {
        guard let view = movingViews.removeValue(forKey: mobileBubble) else {
            return
        }

        if !isAttached {
            view.addGlow(colored: .red)
            view.fadeOut(withDuration: 1)
        } else {
            view.removeFromSuperview()
        }
    }
}
