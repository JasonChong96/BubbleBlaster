//
//  LevelChooserViewController.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 28/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit
import AVFoundation

/// View controller for the level chooser screen.
class LevelChooserViewController: UIViewControllerNoStatusBar {

    /// Information on saved files.
    private var savedFiles: SaveFileList? = SaveFileList(isLoadFromStorage: true)

    /// The player for the video background.
    private var avPlayer: AVPlayer!

    /// The layer to display avPlayer
    private var avPlayerLayer: AVPlayerLayer!

    /// The name of the chosen saved file
    private var chosenFilename: String?

    /// The translucent view in the center.
    @IBOutlet private weak var centerView: UIView!

    /// The exit button.
    @IBOutlet private weak var exitButton: UIButton!

    /// The frame for the chosen saved file.
    var chosenFrame: CGRect?

    override func viewDidLoad() {
        loadBackground()
    }

    /// Get the name and preview image for all saved files.
    ///
    /// - Returns: An array of tuples with first element being the name and the second element being the preview image.
    private func getSavedFiles() -> SaveFileList {
        guard let savedFiles = savedFiles else {
            let alert = ControllerUtils.getGenericAlert(titled: "Failed to load saved files.",
                                                        withMsg: "Please try again later")
            present(alert, animated: true, completion: nil)
            dismiss(animated: true, completion: nil)
            return SaveFileList.empty
        }

        return savedFiles
    }

    /// Displays the video background
    private func loadBackground() {
        guard let theURL = Bundle.main.url(forResource: "titleBackground", withExtension: ".mp4") else {
            return
        }

        let background = UIView()
        background.frame = CGRect(x: 0, y: 0, width: 2429, height: 1366)

        avPlayer = AVPlayer(url: theURL)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        view.backgroundColor = .clear
        avPlayerLayer.frame = background.frame
        background.backgroundColor = .clear
        background.layer.insertSublayer(avPlayerLayer, at: 0)
        avPlayer.play()
        view.addSubview(background)
        view.sendSubviewToBack(background)
        background.transform = CGAffineTransform(
            translationX: (view.frame.width - background.frame.width + view.frame.width), y: 0)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
    }

    /// Called when the video player reaches the end. Resets the player to play the video
    /// from the start.
    ///
    /// - Parameter notification: The notification that triggered this function.
    @objc private func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
        }
    }

    /// Called when the exit button is pressed. Pushes the current screen out to the left.
    ///
    /// - Parameter sender: The sender that triggered this function call.
    @IBAction private func onExitButtonPressed(_ sender: Any) {
        exit()
    }

    /// Called when the collection view is tapped. Displays confirmation message for loading the tapped level.
    ///
    /// - Parameter sender: The sender that triggered this function call.
    @IBAction private func onTapGesture(_ sender: UITapGestureRecognizer) {
        guard let collectionView = sender.view as? UICollectionView,
            let cell = collectionView.hitTest(sender.location(in: collectionView), with: nil)?
                .superview as? UICollectionViewCell,
            let indexPath = collectionView.indexPath(for: cell),
            let fileName = savedFiles?.savedFileNames[indexPath.item] else {
                return
        }

        let confirmMsg = ControllerUtils.getConfirmationAlert(title: "Are you sure you wish to load \(fileName)?",
            desc: "", okAction: { [weak self] in
                self?.chosenFilename = fileName
                if let frame = self?.centerView.convert(cell.frame, from: cell.superview) {
                    self?.chosenFrame = self?.view.convert(frame, from: self?.centerView)
                }

                self?.performSegue(withIdentifier: "chooserToGame", sender: sender)
            }, cancelAction: nil)

        present(confirmMsg, animated: true, completion: nil)
    }

    /// Called when the collection view is long tapped. Displays confirmation message for deleting the tapped level.
    ///
    /// - Parameter sender: The sender that triggered this function call.
    @IBAction private func onLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        guard let collectionView = sender.view as? UICollectionView,
            let cell = collectionView.hitTest(sender.location(in: collectionView), with: nil)?
                .superview as? UICollectionViewCell,
            let indexPath = collectionView.indexPath(for: cell),
            let fileName = savedFiles?.savedFileNames[indexPath.item] else {
                return
        }

        if !SaveFileList.isDeletionAllowed(for: fileName) {
            let alert = ControllerUtils.getGenericAlert(titled: "Preset levels cannot be deleted.",
                                                        withMsg: "\(fileName) is a preset level.")
            present(alert, animated: true, completion: nil)
            return
        }

        let confirmMsg = ControllerUtils.getConfirmationAlert(title: "Are you sure you wish to delete \(fileName)?",
            desc: "", okAction: { [weak self] in
                guard let success = self?.savedFiles?.deleteFile(named: fileName),
                    success else {
                    let alert = ControllerUtils.getGenericAlert(titled: "Failed to delete \(fileName).",
                        withMsg: "Please try again alter.")
                    self?.present(alert, animated: true, completion: nil)
                    return
                }

                guard let indexPath = collectionView.indexPath(for: cell) else {
                    return
                }

                collectionView.deleteItems(at: [indexPath])
            }, cancelAction: nil)

        present(confirmMsg, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? MainGameViewController,
            let fileName = chosenFilename else {
                return
        }

        do {
            try dest.loadSaveFile(named: fileName)
        } catch {
            let alert = ControllerUtils.getGenericAlert(titled: "Failed to load \(fileName).",
                withMsg: "Please try again later.")
            present(alert, animated: true, completion: nil)
        }
    }

    /// Load and present the saved file matching the input name.
    ///
    /// - Parameter fileName: The name of the saved file.
    private func loadAndPlaySavedFile(named fileName: String) {
        let gameViewController = MainGameViewController()

        do {
            try gameViewController.loadSaveFile(named: fileName)
        } catch {
            let alert = ControllerUtils.getGenericAlert(titled: "Failed to load \(fileName).",
                withMsg: "Please try again later.")
            present(alert, animated: true, completion: nil)
        }

        present(gameViewController, animated: true, completion: nil)
    }

    /// Pushes this view to the left and dismisses it.
    private func exit() {
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .push
        transition.subtype = .fromRight
        self.view.window?.layer.add(transition, forKey: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

extension LevelChooserViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getSavedFiles().savedFileNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "frames", for: indexPath)
                as? FrameViewCell else {
                    preconditionFailure("Cell is not of type FrameViewCell.")
            }

            let name = getSavedFiles().savedFileNames[indexPath.item]

            cell.set(name: name)
            DispatchQueue.global(qos: .background).async {
                guard let image = StorageManager.loadPreviewImage(named: name) else {
                    return
                }

                DispatchQueue.main.async {
                    cell.set(image: image)
                }
            }
            return cell
    }
}
