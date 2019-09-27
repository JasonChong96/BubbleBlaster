//
//  ViewController.swift
//  LevelDesigner
//
//  Created by Jason Chong on 28/1/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit

/// The parent view controller for the LevelDesigner
class LevelDesignerViewController: UIViewControllerNoStatusBar {
    /// The game area of the level
    @IBOutlet private weak var gameArea: UIView!

    /// View for the collection of palette bubbles.
    @IBOutlet private weak var paletteCollection: UICollectionView!

    /// View for the collection of game cells.
    @IBOutlet private weak var gameCellsCollection: UICollectionView!

    /// The background area
    @IBOutlet private weak var backgroundArea: UIView!

    /// The button to open the save files chooser
    @IBOutlet private weak var loadButton: UIButton!

    /// The button used to load the chosen save file.
    @IBOutlet private weak var loadChosenButton: UIButton!

    /// The button used to open the save level UI.
    @IBOutlet private weak var saveButton: UIButton!

    /// The button used to exit the screen.
    @IBOutlet weak var exitButton: UIButton!

    /// The button used to change the palette's state to remove bubbles from the game.
    @IBOutlet private weak var removeButton: UIButton! {
        didSet {
            palette.removeButton = removeButton
        }
    }

    /// View for level options
    @IBOutlet private weak var settingsView: UIView!

    /// Button used to reset grid to isometric layout
    @IBOutlet private weak var resetToIsometricButton: UIButton!

    /// Button used to reset grid to rectangular layout
    @IBOutlet private weak var resetToRectangularButton: UIButton!

    /// The picker UI to choose the number of shooters
    @IBOutlet private weak var numShootersPicker: UIPickerView!

    /// The picker UI to choose a save file
    @IBOutlet private weak var saveFilePicker: UIPickerView!

    /// The field to enter the name of the save file to save as
    @IBOutlet private weak var saveFileNameField: UITextField!

    /// Delegate and data source for num shooters picker
    /// SwiftLint warns of a memory leak but the delegate holds no reference to this view
    var numShootersPickerDelegate = NumShootersPickerDelegate()

    /// File names of currently saved files
    var saveFiles = StorageManager.getAllSaveFileNames()

    /// The state of this `ViewController`
    private var state = MainViewControllerState.normal

    /// Reuse identifiers for `UICollectionViewCell`s
    let palleteIdentifier = "palleteCell"
    let gameCellsIdentifier = "gameCell"

    /// Controller for the palette logic
    private(set) lazy var palette = PaletteController()

    /// Controller for the game cells logic
    private var gameCellsController: GameCellsController?

    override func viewDidLoad() {
        super.viewDidLoad()
        initNumShootersPicker()
        showBackground()
        showSettingsBackground()
        addSettingsBorderFade()
        saveFileNameField.autocorrectionType = .no
        changeState(to: .normal)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        // Ensures that the UICollectionView has been loaded completely before syncing
        gameCellsCollection.performBatchUpdates(nil) { _ in
            self.gameCellsController = GameCellsController(collectionView: self.gameCellsCollection,
                                                           model: GameState())
        }
        if let layout = paletteCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
        }
    }

    /// Called when the user or system hides the keyboard. Returns the state of this view to normal
    ///
    /// - Parameter notification: The `NSNotification` sent for the event.
    @objc
    func keyboardWillHide(notification: NSNotification) {
        changeState(to: .normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "designerToGame" {
            let gameViewController = (segue.destination as? MainGameViewController)
            let model = getGameCellsController().gameState
            gameViewController?.model = model
            getGameCellsController().reset(to: model.gridLayout)
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "designerToGame" {
            let isAllowed = !getGameCellsController()
                .isEmpty()

            if !isAllowed {
                let alert = ControllerUtils.getGenericAlert(titled: "All cells are empty",
                                                            withMsg: "You can't start a game with only empty cells!")

                present(alert, animated: true, completion: nil)
            }
            return isAllowed
        }

        return true
    }

    /// Saves the gameArea as an image as the input file name.
    ///
    /// - Parameter name: The file name to save as.
    func saveImage(as name: String) {

        let renderer = UIGraphicsImageRenderer(bounds: gameArea.bounds)
        let image = renderer.image { context in
            gameArea.layer.render(in: context.cgContext)
        }

        guard let cgImage = image.cgImage else {
            return
        }

        let imageSize = min(cgImage.height, cgImage.width)
        let imageRect = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)

        guard let croppedImage = cgImage.cropping(to: imageRect) else {
            return
        }

        try? StorageManager.save(object: UIImageCodableWrapper(image: UIImage(cgImage: croppedImage)),
                                 as: "\(name)\(GameConstants.imageSuffix)")
    }

    /// Called when a text button is pressed, mainly for reset, load and save functions
    ///
    /// - Parameter sender: The view that triggered this function call.
    @IBAction func buttonPressed(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }

        switch button {
        case exitButton:
            exitButtonPressed()
        case loadButton:
            if case .normal = state {
                changeState(to: .chooseSaveFile)
            } else {
                changeState(to: .normal)
            }
        case loadChosenButton:
            loadChosenSaveFile()
        case saveButton:
            changeState(to: .enterFileName)
        case resetToIsometricButton:
            resetButtonPressed(resetTo: .isometric)
        case resetToRectangularButton:
            resetButtonPressed(resetTo: .rectangular)
        default:
            break
        }
    }

    /// Called when the game area is (short) tapped. If the tap is on a game cell, then an action is
    /// applied according to the state of the palette. If the palette's state is normal/neutral, then
    /// the cell's bubble color is changed to the next color in the cycle, if there is a bubble in the cell.
    ///
    /// - Parameter sender: The `UITapGestureRecognizer` of the tap gesture that triggered this function call.
    @IBAction func gameAreaTapped(_ sender: UITapGestureRecognizer) {
        let view = gameCellsCollection.hitTest(sender.location(in: gameCellsCollection), with: nil)

        guard let bubbleCell = view?.superview as? UICollectionViewCell else {
            return
        }

        if case .normal = palette.state {
            getGameCellsController().cycleColor(of: bubbleCell)
        }

        palette.apply(to: bubbleCell, through: getGameCellsController())
    }

    /// Called when the game area is long tapped. If the tap is on a game cell, then the cell will be set to
    /// empty.
    ///
    /// - Parameter sender: The `UILongPressGestureRecognizer` of the long tap that triggered this function call.
    @IBAction func gameAreaLongTapped(_ sender: UILongPressGestureRecognizer) {
        let view = gameCellsCollection.hitTest(sender.location(in: gameCellsCollection), with: nil)

        guard let bubbleCell = view?.superview as? UICollectionViewCell else {
            return
        }

        gameCellsController?.apply(palleteBubble: nil, to: bubbleCell)
    }

    /// Called when the game area is panned. If the pan is on a game cell, then the chosen palette action will
    /// be applied on the game cell.
    ///
    /// - Parameter sender: The `UIPanGestureRecognizer` of the pan that triggered this function call.
    @IBAction func onPanGameArea(_ sender: UIPanGestureRecognizer) {
        let view = gameCellsCollection.hitTest(sender.location(in: gameCellsCollection), with: nil)

        guard let bubbleCell = view?.superview as? UICollectionViewCell  else {
            return
        }

        palette.apply(to: bubbleCell, through: getGameCellsController())
    }

    /// Called when the remove button is pressed. Notifies the palette controller of the event through a function
    /// call.
    ///
    /// - Parameter sender: The view that triggered this function call.
    @IBAction func removeButtonPressed(_ sender: Any) {
        palette.removeButtonPressed()
    }

    /// Called when exit button is pressed, shows a confirmation to the user for exiting this designer.
    private func exitButtonPressed() {
        let confirmation = ControllerUtils.getConfirmationAlert(title: "Are you sure you want to Exit?",
                                                                desc: "All your unsaved progress will be lost.",
                                                                okAction: { [weak self] in
                                                                    self?.dismiss(animated: true, completion: nil)
            },
                                                                cancelAction: nil)

        present(confirmation, animated: true, completion: nil)
    }

    private func resetButtonPressed(resetTo layout: BubbleBlasterCellsLayout) {
        let confirmation = ControllerUtils.getConfirmationAlert(title: "Reset to \(layout)?",
            desc: "All your unsaved progress will be lost.",
            okAction: { [weak self] in
                self?.getGameCellsController().reset(to: layout)
            }, cancelAction: nil)

        present(confirmation, animated: true, completion: nil)
    }

    /// Shows the game background on the screen.
    private func showBackground() {
        /// Stretches the background area to fit the whole screen. Somehow autolayout constraints is not working
        backgroundArea.translateFromDifferentScale(otherBounds: view.bounds, otherFrame: view.bounds)

        guard let backgroundImage = UIImage(named: "gameBackground2.jpg") else {
            return
        }

        let background = UIImageView(image: backgroundImage)
        background.contentMode = .scaleAspectFill

        let gameViewHeight = backgroundArea.frame.size.height
        let gameViewWidth = backgroundArea.frame.size.width

        background.frame = CGRect(x: 0, y: 0, width: gameViewWidth, height: gameViewHeight)
        backgroundArea.addSubview(background)
        backgroundArea.sendSubviewToBack(background)
    }

    /// Shows the background for the settings panel
    private func showSettingsBackground() {
        settingsView.frame = settingsView.frame.applying(
            CGAffineTransform(scaleX: view.frame.width / settingsView.frame.width, y: 1))
        let settingsImage = UIImage(named: "settings-background.jpg")

        let settingsBackground = UIImageView(image: settingsImage)
        settingsBackground.contentMode = .scaleAspectFill
        settingsBackground.alpha = 0.1

        let settingsHeight = settingsView.frame.size.height
        let settingsWidth = settingsView.frame.size.width

        settingsBackground.frame = CGRect(x: 0, y: 0, width: settingsHeight, height: settingsWidth)

        settingsView.addSubview(settingsBackground)
        settingsView.sendSubviewToBack(settingsBackground)
    }

    /// Adds a fading border to settings panel
    private func addSettingsBorderFade() {
        let gradientMaskLayer = CAGradientLayer()
        gradientMaskLayer.frame = settingsView.bounds
        gradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor,
                                    UIColor.clear.cgColor]
        gradientMaskLayer.locations = [0, 0.1, 0.95, 1]
        settingsView.layer.mask = gradientMaskLayer
    }

    /// Gets the controller for the game area cells.
    func getGameCellsController() -> GameCellsController {
        guard let result = gameCellsController else {
            preconditionFailure("gameCellsController is nil")
        }

        return result
    }

    /// Changes the state of the view according to the input state.
    ///
    /// - Parameter newState: the new state of this view
    func changeState(to newState: MainViewControllerState) {
        switch newState {
        case .normal:
            saveFilePicker.isHidden = true
            saveFileNameField.isHidden = true
            loadChosenButton.isHidden = true
            saveFileNameField.endEditing(true)
            saveFileNameField.resignFirstResponder()
        case .enterFileName:
            saveFilePicker.isHidden = true
            saveFileNameField.isHidden = false
            loadChosenButton.isHidden = true
            saveFileNameField.becomeFirstResponder()
        case .chooseSaveFile:
            saveFilePicker.isHidden = false
            saveFileNameField.isHidden = true
            loadChosenButton.isHidden = false
            saveFileNameField.endEditing(true)
            saveFileNameField.resignFirstResponder()
        }

        state = newState
    }

    /// Shows an alert window to the user with the input title and message and an OK button.
    ///
    /// - Parameters:
    ///     - title: The title of the alert window.
    ///     - message: The message to show on the alert window.
    func showGenericAlert(titled title: String, withMsg message: String) {
        let alert = ControllerUtils.getGenericAlert(titled: title, withMsg: message)
        self.present(alert, animated: true, completion: nil)
    }

    /// Reload the save file names into memory.
    func reloadSaveFiles() {
        saveFiles = StorageManager.getAllSaveFileNames()
        saveFilePicker.reloadAllComponents()
    }

    private func initNumShootersPicker() {
        numShootersPicker.dataSource = numShootersPickerDelegate
        numShootersPicker.delegate = numShootersPickerDelegate
        numShootersPickerDelegate.changedPickerCallback = { [weak self] in
            self?.getGameCellsController().setNumberOfShooters(to: $0)
        }
    }

    /// Loads the chosen save file in the picker UI.
    private func loadChosenSaveFile() {
        guard let unwrappedSaveFiles = self.saveFiles else {
            return
        }

        if unwrappedSaveFiles.isEmpty ||
            !unwrappedSaveFiles.indices.contains(saveFilePicker.selectedRow(inComponent: 0)) {
            return
        }

        let name = unwrappedSaveFiles[saveFilePicker.selectedRow(inComponent: 0)]
        do {
            try getGameCellsController().loadModel(named: name)
        } catch {
            showGenericAlert(titled: "Error", withMsg: "Error loading \(name), please try again.")
            return
        }

        if let row = numShootersPickerDelegate.options
            .firstIndex(of: getGameCellsController().gameState.numOfShooters) {
                numShootersPicker.selectRow(row, inComponent: 0, animated: true)
        }
        showGenericAlert(titled: "Success!", withMsg: "Successfully loaded \(name)")
        changeState(to: .normal)
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait.union(.portraitUpsideDown)
    }
}

extension LevelDesignerViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case paletteCollection:
            return GameBubbleUtil.getAllUniqueBubbles().count
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

            linkToController(cell: cell, in: collectionView, at: indexPath)

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
        case paletteCollection:
            return palleteIdentifier
        case gameCellsCollection:
            return gameCellsIdentifier
        default:
            fatalError("Unsupported UICollectionView in collectionView function")
        }
    }

    /// Links the input view cell to the appropriate controller.
    ///
    /// - Parameters:
    ///     - cell: The view cell to link
    ///     - collectionView: The `UICollectionView` that contains the view cell.
    ///     - indexPath: The position of the view cell.
    private func linkToController(cell: UICollectionViewCell, in collectionView: UICollectionView,
                                  at indexPath: IndexPath) {
        switch collectionView {
        case paletteCollection:
            guard let paletteCell = cell as? PaletteViewCell else {
                fatalError("paletteCollection cells are not of type PalleteViewCell")
            }

            palette.addBubble(withInterface: paletteCell, atIndex: indexPath)
        case gameCellsCollection:
            return
        default:
            fatalError("Unsupported UICollectionView in collectionView function")
        }
    }
}
