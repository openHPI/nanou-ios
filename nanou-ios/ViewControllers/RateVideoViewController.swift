//
//  RateVideoViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 26/01/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Cosmos


class RateVideoViewController: UIViewController {
    var video: Video? {
        didSet {
            self.playerViewContoller = self.configuredPlayerViewController(for: self.video)
        }
    }
    var videoWasStartedBefore = false

    var playerViewContoller: AVPlayerViewController?

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ratingView: CosmosView!


    @IBAction func tapWatched(_ sender: Any) {
        defer {
            let _ = self.navigationController?.popViewController(animated: true)
        }

        guard
            let videoTime = self.playerViewContoller?.player?.currentTime(),
            let videoDuration = self.playerViewContoller?.player?.currentItem?.duration,
            videoTime.isValid, videoDuration.isValid else {
            return
        }

        let progress = videoTime.seconds / videoDuration.seconds
        let rating = self.ratingView.rating

        log.debug("tapWatched")
        log.verbose("rated video \(self.video?.id) with \(rating) (progress: \(progress))")
        let _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func tapResume(_ sender: Any) {
        self.playVideo()
    }

    override func viewDidLoad() {
        self.titleLabel.text = self.video?.name
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !self.videoWasStartedBefore {
            self.videoWasStartedBefore = true
            self.playVideo()
        }
    }

    func playVideo() {
        if let playerVc = self.playerViewContoller {
            self.present(playerVc, animated: true) {
                playerVc.player?.play()
            }
        }
    }

    func configuredPlayerViewController(for video: Video?) -> AVPlayerViewController? {
        guard let url = self.video?.streamUrl else {
            log.error("RateVideoViewController | invalid url string")
            return nil
        }

        guard let videoUrl = URL(string: url) else {
            log.error("RateVideoViewController | invalid url")
            return nil
        }

        let player = AVPlayer(url: videoUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        return playerViewController
    }

}
