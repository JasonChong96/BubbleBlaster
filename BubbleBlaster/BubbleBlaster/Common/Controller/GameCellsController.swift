//
//  GameCellsController.swift
//  LevelDesigner
//
//  Created by Jason Chong on 3/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// Encapsulates and supports the mutation of the state of the `GameCellsModel` used and also
/// syncs the collection of views representing the game cells to the model state.
class GameCellsController {

    /// The view for the collection of game cells.
    private weak var collectionView: UICollectionView?

    /// The cached images for each kind of `GameBubble`. A heterogenous key is required if a dictionary is used, which
    /// isn't possible due to equatable requirements. Images are only added to the cache when they are first used.
    private var images = [(GameBubble, UIImage)]()

    /// The `UIImage` representing an empty `GameCell`. This image will be added to a gray tinted UIImageView.
    private var nilImage = UIImage(named: "bubble-translucent_black.png")

    /// The model encapsulating the state of the `GameCell`s in memory.
    private(set) var gameState: GameState {
        didSet {
            syncViewWithModel()
        }
    }

    private let animator: UIDynamicAnimator
    private let gravity: UIGravityBehavior
    private let collision: UICollisionBehavior
    private let itemDynamics: UIDynamicItemBehavior

    /// Constructor that creates a `GameCellsController` for the given collectionView and model.
    ///
    /// - Parameters:
    ///     - collectionView: The UICollectionView that contains the game cell views.
    ///     - gameCellsModel: The model for the game cells.
    init(collectionView: UICollectionView, model: GameState) {
        self.gameState = model
        self.collectionView = collectionView
        self.animator = UIDynamicAnimator(referenceView: collectionView)
        self.gravity = UIGravityBehavior(items: [])
        self.collision = UICollisionBehavior(items: [])
        self.itemDynamics = UIDynamicItemBehavior(items: [])
        collision.translatesReferenceBoundsIntoBoundary = true
        itemDynamics.elasticity = 1
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        animator.addBehavior(itemDynamics)
        syncViewWithModel()
    }

    /// Saves the model as a file with the input filename
    ///
    /// - Parameter fileName: The file name to save the model as.
    func saveModel(as fileName: String) throws {
        try gameState.saveCells(as: fileName)
    }

    /// Loads the model with the given file name.
    ///
    /// - Parameter fileName: The file name of the file to load.
    func loadModel(named fileName: String) throws {
        try gameState.loadSavedFile(named: fileName)
        syncViewWithModel()
    }

    /// Sets the number of shooters to a new value
    ///
    /// - Parameter numShooters: The number of shooters. Must be either 1 or 2.
    func setNumberOfShooters(to numShooters: Int) {
        if numShooters > 2 || numShooters < 0 {
            preconditionFailure("Invalid number of shooters.")
        }

        gameState.numOfShooters = numShooters
    }

    func reset(to layout: BubbleBlasterCellsLayout) {
        gameState = GameState(gridLayout: layout)
    }

    func removeUnusedBubblesFromBehaviors() {
        for item in gravity.items where (item as? UIView)?.superview == nil {
            gravity.removeItem(item)
        }

        for item in collision.items where (item as? UIView)?.superview == nil {
            collision.removeItem(item)
        }

        for item in itemDynamics.items where (item as? UIView)?.superview == nil {
            itemDynamics.removeItem(item)
        }
    }

    func isEmpty() -> Bool {
        return gameState
            .getAllGridCells()
            .flatMap { $0 }
            .filter { $0.bubble != nil }
            .isEmpty
    }

    /// Syncs the state of the view with the state of the Model.
    private func syncViewWithModel() {
        for row in 0..<getCollectionView().numberOfSections {
            syncViewRowWithModel(row: row)
        }

        gameState.getAllCellsForController()
            .flatMap { $0 }
            .forEach { [weak self] in $0.observer = self }
    }

    /// Syncs the state of the view with the state of the model for a given row.
    ///
    /// - Parameter row: The index of the row to sync.
    private func syncViewRowWithModel(row: Int) {
        for col in 0..<getCollectionView().numberOfItems(inSection: row) {
            guard let viewCell = getViewCell(atRow: row, andCol: col) else {
                preconditionFailure("View has incorrect number of rows or columns")
            }

            guard let cell = gameState.getCellAt(row: row, col: col) else {
                viewCell.isHidden = true
                return
            }

            let image = getImage(for: cell.bubble)
            syncFrame(of: viewCell, with: cell)
            sync(viewCell: viewCell, withImage: image, tinted: cell.bubble == nil ? .gray : .clear)
        }
    }

    /// Syncs the frame of the view to the frame of the model.
    ///
    /// - Parameters:
    ///   - viewCell: The view cell to sync
    ///   - modelCell: The model cell to sync
    private func syncFrame(of viewCell: GameCellView, with modelCell: GameCell) {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            viewCell.isHidden = false
            viewCell.translateFromDifferentScale(otherBounds: self.gameState.bounds, otherFrame: modelCell.frame)
            })
    }

    /// Gets the `UIImage` for the input GameBubble from the cache. If the cache does not contain a `UIImage`
    /// for the input bubble, then a new `UIImage` is generated and stored in the cache.
    ///
    /// - Parameter bubble: The GameBubble to use.
    private func getImage(for bubble: GameBubble?) -> UIImage {
        guard let unwrappedBubble = bubble else {
            guard let image = nilImage else {
                preconditionFailure("nilImage should never be nil.")
            }
            return image
        }

        var image = images.first { $0.0.sameImageAs(otherBubble: unwrappedBubble) }?.1
        if image == nil {
            image = UIImage(named: unwrappedBubble.imageName)
        }

        guard let unwrappedImage = image else {
            fatalError("Failed to initialize UIImage for \(String(describing: bubble))")
        }

        return unwrappedImage
    }

    /// Syncs the input view cell with the input image and tint.
    ///
    /// - Parameters:
    ///     - viewCell: The view cell to show the image on
    ///     - newImage: The new image to show on the cell
    ///     - tint: The tint color of the image in the view cell.
    private func sync(viewCell: GameCellView, withImage newImage: UIImage, tinted tint: UIColor) {
        if !viewCell.isDisplaying(image: newImage) {
            viewCell.display(image: newImage)
        }

        viewCell.tintColor = tint
    }

    /// Fetches the view cell at the input row and column if one exists.
    ///
    /// - Parameters:
    ///     - row: The index of the row
    ///     - col: The index of the column.
    private func getViewCell(atRow row: Int, andCol col: Int) -> GameCellView? {
        return getCollectionView().cellForItem(at: IndexPath(item: col, section: row)) as? GameCellView
    }

    /// Gets the collection view of game cells.
    private func getCollectionView() -> UICollectionView {
        guard let unwrappedCollectionView = collectionView else {
            preconditionFailure("collectionView reference lost.")
        }

        return unwrappedCollectionView
    }
}

extension GameCellsController: GameCellObserver {
    func cellBubbleChanged(atRow row: Int, col: Int, to bubble: GameBubble) {
        apply(bubble: bubble, toViewAtRow: row, andCol: col)
    }

    func cellBubbleRemoved(atRow row: Int, col: Int, removalType: RemoveBubbleType?) {
        if let animationType = removalType {
            animateRemovalOfBubble(atRow: row, col: col, animationType: animationType)
        }

        apply(bubble: nil, toViewAtRow: row, andCol: col)
    }

    private func animateRemovalOfBubble(atRow row: Int, col: Int, animationType: RemoveBubbleType) {
        guard let cell = getViewCell(atRow: row, andCol: col),
            let image = cell.getImage() else {
                return
        }

        if cell.getImage() === nilImage {
            return
        }

        let imageView = UIImageView(image: image)
        imageView.frame = cell.frame
        getCollectionView().addSubview(imageView)
        switch animationType {
        case .combo:
            imageView.addGlow(colored: .yellow)
            imageView.fadeOut(withDuration: 3)
            addItemToAnimator(imageView)
            itemDynamics.addLinearVelocity(CGPoint(x: CGFloat.random(in: -500...500), y: -500), for: imageView)
        case .disconnectedFromTop:
            imageView.image = UIImage(named: "bubble-indestructible")
            imageView.fadeOut(withDuration: 3)
            addItemToAnimator(imageView)
        case .explode:
            bubbleBurst(on: imageView)
        case .removeRow:
            showSliced(imageView)
            showLightning(in: imageView.frame)
        }
    }

    private func showSliced(_ imageView: UIImageView) {
        imageView.removeFromSuperview()
        guard let cgImage = imageView.image?.cgImage,
            let imageTop = cgImage.cropping(to: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height / 2)),
            let imageBottom = cgImage.cropping(to: CGRect(x: 0, y: cgImage.height / 2,
                                                          width: cgImage.width, height: cgImage.height / 2)) else {
                return
        }
        let originalFrame = imageView.frame
        let originalOrigin = originalFrame.origin
        let imageViewTop = UIImageView(image: UIImage(cgImage: imageTop))
        let imageViewBottom = UIImageView(image: UIImage(cgImage: imageBottom))
        imageViewTop.frame = CGRect(x: originalOrigin.x, y: originalOrigin.y,
                                    width: originalFrame.width, height: originalFrame.height / 2)
        imageViewBottom.frame = CGRect(x: originalOrigin.x, y: originalOrigin.y + originalFrame.height / 2,
                                       width: originalFrame.width, height: originalFrame.height / 2)
        imageViewTop.contentMode = .scaleAspectFit
        imageViewTop.contentMode = .scaleAspectFit
        getCollectionView().addSubview(imageViewTop)
        getCollectionView().addSubview(imageViewBottom)

        imageViewTop.fadeOut(withDuration: 3)
        addItemToAnimator(imageViewTop)
        itemDynamics.addLinearVelocity(CGPoint(x: CGFloat.random(in: -500...500), y: 0), for: imageViewTop)
        imageViewBottom.fadeOut(withDuration: 3)
        addItemToAnimator(imageViewBottom)
    }

    private func showLightning(in rect: CGRect) {
        let lightning = UIImageView()
        lightning.contentMode = .scaleAspectFit
        lightning.frame = rect
        var lightningFrames = [UIImage]()
        for frameNo in 1...4 {
            guard let frame = UIImage(named: "lightning" + String(frameNo)) else {
                continue
            }
            lightningFrames.append(frame)
        }

        lightning.animationImages = lightningFrames
        lightning.animationDuration = 0.1
        lightning.startAnimating()
        collectionView?.addSubview(lightning)
        collectionView?.bringSubviewToFront(lightning)
        lightning.fadeOut(withDuration: 1)
    }

    private func addItemToAnimator(_ item: UIDynamicItem) {
        gravity.addItem(item)
        collision.addItem(item)
        itemDynamics.addItem(item)
    }

    private func bubbleBurst(on imageView: UIImageView) {
        imageView.image = nil

        var frames = [UIImage]()
        for frameNo in 1...4 {
            guard let frame = UIImage(named: "bubble-burst" + String(frameNo)) else {
                continue
            }
            frames.append(frame)
        }

        imageView.animationImages = frames
        imageView.animationRepeatCount = 1
        imageView.animationDuration = 0.3
        imageView.startAnimating()
        imageView.growAndDisappear(scale: 5)
    }

    private func apply(bubble: GameBubble?, toViewAtRow row: Int, andCol col: Int) {
        guard let viewCell = getViewCell(atRow: row, andCol: col) else {
            preconditionFailure("View has incorrect number of rows or columns")
        }

        let image = getImage(for: bubble)

        sync(viewCell: viewCell, withImage: image, tinted: bubble == nil ? .gray : .clear)
    }
}

extension GameCellsController: GameCellsControllerProtocol {
    func apply(palleteBubble bubble: GameBubble?, to cell: UICollectionViewCell) {
        guard let indexPath = getCollectionView().indexPath(for: cell) else {
            preconditionFailure("This cell is not an instance of GameCellView.")
        }

        gameState.setCell(atRow: indexPath.section, col: indexPath.item, to: bubble)
    }

    func cycleColor(of cell: UICollectionViewCell) {
        guard let unwrappedCollectionView = collectionView else {
            preconditionFailure("collectionView reference lost.")
        }

        guard let indexPath = unwrappedCollectionView.indexPath(for: cell) else {
            preconditionFailure("cell is not in collectionView")
        }

        guard let gameCell = gameState.getCellAt(row: indexPath.section, col: indexPath.item) else {
            preconditionFailure("cell is not in model")
        }

        guard let curBubble = gameCell.bubble else {
            return
        }

        let colors: [GameBubble] = GameBubbleUtil.getCycleBubbles()

        guard var colorIndex = colors.firstIndex(where: { curBubble.sameImageAs(otherBubble: $0) }) else {
            return
        }

        colorIndex = (colorIndex + 1) % colors.count

        apply(palleteBubble: colors[colorIndex], to: cell)
    }
}
