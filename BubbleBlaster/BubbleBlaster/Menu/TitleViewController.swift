//
//  ViewController.swift
//  BubbleBlaster
//
//  Created by Jason Chong on 21/2/19.
//  Copyright © 2019 nus.cs3217.a0164721j. All rights reserved.
//

import UIKit
import AVFoundation

/// ViewController for title screen.
class TitleViewController: UIViewControllerNoStatusBar {
    /// Video player for background
    var avPlayer: AVPlayer!

    /// Layer to display avPlayer
    var avPlayerLayer: AVPlayerLayer!

    /// The button to open the level chooser.
    @IBOutlet private weak var playButton: UIButton!

    /// The button to open the level designer
    @IBOutlet private weak var levelDesignerButton: UIButton!

    /// The translucent area in the middle.
    @IBOutlet private weak var middleArea: UIView!

    /// The frame of the play button within the bounds of this view
    var playButtonFrame: CGRect {
        return view.convert(playButton.frame, from: middleArea)
    }

    /// The frame of the level designer button within the bounds of this view
    var levelDesignerButtonFrame: CGRect {
        return view.convert(levelDesignerButton.frame, from: middleArea)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadBackground()
        StorageManager.copyPresetsIntoFolder()
    }

    /// Displays the background video.
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
        background.transform = CGAffineTransform(translationX: (view.frame.width - background.frame.width), y: 0)

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
}
