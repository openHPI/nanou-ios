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
import SDWebImage


class RateVideoViewController: UIViewController {
    var video: Video? {
        didSet {
            self.playerViewContoller = self.configuredPlayerViewController(for: self.video)
        }
    }
    var videoWasStartedBefore = false

    var playerViewContoller: AVPlayerViewController?

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var providerLabel: UILabel!
    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var buttonStack: UIStackView!
    @IBOutlet var nextButton: UIButton!

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

        let now = Date() as NSDate
        let _ = WatchedVideo.newEntity(forVideoId: self.video?.id, withDate: now, progress: progress, rating: rating)
        CoreDataHelper.saveContext()
    }

    @IBAction func tapGoBack() {
        let _ = self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        self.titleLabel.text = self.video?.name
        self.providerLabel.text = self.video?.providerText

        self.imageView.layer.cornerRadius = 2.0
        self.imageView.layer.masksToBounds = true
        self.imageView.loadFrom(self.video?.imageUrl, orShow: "No thumbnail available")

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RateVideoViewController.playVideo))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.imageView.addGestureRecognizer(tapGesture)
        self.imageView.isUserInteractionEnabled = true

        self.nextButton.backgroundColor = UIColor.nanouOrange
        self.nextButton.tintColor = UIColor.white
        self.nextButton.layer.masksToBounds = true
        self.nextButton.layer.cornerRadius = 2.0

        // set all view but imageview to hidden
        self.titleLabel.isHidden = true
        self.providerLabel.isHidden = true
        self.ratingView.isHidden = true
        self.buttonStack.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !self.videoWasStartedBefore {
            self.videoWasStartedBefore = true
            self.playVideo {
                self.titleLabel.isHidden = false
                self.providerLabel.isHidden = false
                self.ratingView.isHidden = false
                self.buttonStack.isHidden = false
            }
        }
    }

    func playVideo(_ completion: (() -> (Void))? = nil) {
        if let playerVc = self.playerViewContoller {
            self.present(playerVc, animated: true) {
                playerVc.player?.play()
                if let completion = completion {
                    completion()
                }
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
