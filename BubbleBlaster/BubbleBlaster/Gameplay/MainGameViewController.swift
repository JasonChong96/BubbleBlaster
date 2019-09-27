//
//  ViewController.swift
//  GameEngine
//
//  Created by Jason Chong on 13/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Main View Controller for game play screen
class MainGameViewController: UIViewControllerNoStatusBar {

    var model: GameState = GameState()

    @IBOutlet private weak var backgroundArea: UIView!
    @IBOutlet private weak var gameArea: UIView!
    @IBOutlet private weak var bottomArea: UIView!
    @IBOutlet private weak var gameCellsCollection: UICollectionView!
    @IBOutlet private weak var defaultPanGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet private weak var leftGameArea: UIView!
    @IBOutlet private weak var rightGameArea: UIView!
    @IBOutlet private weak var scoreLabel: UILabel! {
        didSet {
            scoreLabel.adjustsFontSizeToFitWidth = true
        }
    }
    private let gameCellsIdentifier = "gameCell"
    private var gameCellsController: GameCellsController?
    private var gameEngine: BubbleBlasterEngine?
    private var gameAreaController: GameAreaController?
    private var lastLoopTime: Int64 = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        showBackground()
        initGestureRecognizers()
        model.observer = self
        gameAreaController = GameAreaController(gameArea: gameArea, model: model)
        scheduleGameInit(with: model)
    }

    /// Load save file matching the given name
    ///
    /// - Parameter fileName: The save file name
    func loadSaveFile(named fileName: String) throws {
        try model.loadSavedFile(named: fileName)
    }

    /// Initialize gesture recognizers
    private func initGestureRecognizers() {
        if model.numOfShooters == 1 {
            leftGameArea.gestureRecognizers?.removeAll()
            rightGameArea.gestureRecognizers?.removeAll()

            gameArea.addGestureRecognizer(defaultPanGestureRecognizer)
        }
    }

    /// Schedules the initialization of cells and game engine after the appropriate `UICollectionView` has loaded.
    private func scheduleGameInit(with model: GameState) {
        // Ensures that the UICollectionView has been loaded completely before syncing
        gameCellsCollection.performBatchUpdates(nil) { _ in
            let cellsController = GameCellsController(collectionView: self.gameCellsCollection, model: model)
            self.gameCellsController = cellsController
            self.initGameEngine(with: model)
        }
    }

    /// Initializes the game engine.
    ///
    /// - Parameter cellsController: The controller for the game cells.
    private func initGameEngine(with model: GameState) {
        let engine = BubbleBlasterEngine(withBounds: gameArea.bounds, refreshRate: GameConstants.refreshRate,
                                         model: model)
        gameEngine = engine

        let updater = CADisplayLink(target: self, selector: #selector(runGameLoop))
        updater.preferredFramesPerSecond = GameConstants.refreshRate
        updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }

    /// Runs the game loop.
    @objc private func runGameLoop() {
        gameEngine?.runGameLoop()
        getGameAreaController().sync()
        gameCellsController?.removeUnusedBubblesFromBehaviors()
    }

    /// Shows the game background on the screen.
    private func showBackground() {
        /// Stretches the background area to fit the whole screen. Somehow autolayout constraints is not working
        backgroundArea.translateFromDifferentScale(otherBounds: view.bounds, otherFrame: view.bounds)

        let backgroundImage = UIImage(named: "gameBackground2.jpg")

        let background = UIImageView(image: backgroundImage)
        background.contentMode = .scaleAspectFill
        background.alpha = 0.5
        let gameViewHeight = backgroundArea.frame.size.height
        let gameViewWidth = backgroundArea.frame.size.width

        background.frame = CGRect(x: 0, y: 0, width: gameViewWidth, height: gameViewHeight)
        backgroundArea.addSubview(background)
        backgroundArea.sendSubviewToBack(background)
    }

    /// Called when a pen gesture is detected in the right game area.
    ///
    /// - Parameter sender: the recognizer for the pan gesture.
    @IBAction func onPanRightGameArea(_ sender: UIPanGestureRecognizer) {
        onPanGameArea(sender, isLeft: false)
    }

    /// Called when a pen gesture is detected in the left game area.
    ///
    /// - Parameter sender: the recognizer for the pan gesture.
    @IBAction func onPanLeftGameArea(_ sender: UIPanGestureRecognizer) {
        onPanGameArea(sender, isLeft: true)
    }

    /// Called when the exit button is pressed. Shows a confirmation message for exit.
    ///
    /// - Parameter sender: The sender that triggered the function call.
    @IBAction func onExitButtonPressed(_ sender: Any) {
        let confirmation = ControllerUtils.getConfirmationAlert(title: "Are you sure you want to Exit?",
                                                                desc: "All your progress will be lost.",
                                                                okAction: { [weak self] in self?.exit()},
                         cancelAction: nil)

        present(confirmation, animated: true, completion: nil)
    }

    /// Called when the game area is panned. Passes the information to the game area controller to handle.
    ///
    /// - Parameters:
    ///   - sender: The sender that triggered this function call.
    ///   - isLeft: true if the pan started on the left half of the game area. false if not.
    private func onPanGameArea(_ sender: UIPanGestureRecognizer, isLeft: Bool) {
        let translation = sender.translation(in: sender.view)

        gameAreaController?.onUserPanChanged(to: translation, isEnded: sender.state == .ended, isLeft: isLeft)
    }

    /// Gets the game area controller
    ///
    /// - Returns: The game area controller.
    private func getGameAreaController() -> GameAreaController {
        guard let controller = gameAreaController else {
            fatalError("Game area controller not initialized")
        }

        return controller
    }

    /// Fades out and dismisses this view.
    private func exit() {
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .fade
        self.view.window?.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }
}

extension MainGameViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case gameCellsCollection:
            return BubbleBlasterCellsLayout.maxColumns
        default:
            fatalError("Unsupported UICollectionView in collectionView function")
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
        UICollectionViewCell {
            let identifier = getReuseIdentifier(for: collectionView)

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)

            return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView {
        case gameCellsCollection:
            return BubbleBlasterCellsLayout.maxRows
        default:
            return 1
        }
    }

    /// Gets the reuse identifier for a `UICollectionView`
    ///
    /// - Parameter collectionView: The `UICollectionView`
    ///
    /// - Returns: the reuse identifier for `collectionView`
    private func getReuseIdentifier(for collectionView: UICollectionView) -> String {
        switch collectionView {
        case gameCellsCollection:
            return gameCellsIdentifier
        default:
            fatalError("Unsupported UICollectionView in collectionView function")
        }
    }
}

extension MainGameViewController: GameStateObserver {
    func scoreUpdated(score: Int) {
        scoreLabel.text = String(score)
    }

    func gameEnded(numShots: Int) {
        let alert = ControllerUtils.getGenericAlert(titled: "Congratulations!",
                                                    withMsg: "You took \(numShots) shots to win!",
            action: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        })

        present(alert, animated: true, completion: nil)
    }
}
