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
import TagListView


class RateVideoViewController: UIViewController {
    var video: Video? {
        didSet {
            self.playerViewController = self.configuredPlayerViewController(for: self.video)
        }
    }
    var videoWasStartedBefore = false
    var ratingActive = false {
        didSet {
            let color = self.ratingActive ? UIColor.nanouOrange : UIColor.lightGray
            self.ratingView.settings.filledColor = color
            self.ratingView.settings.filledBorderColor = color
            self.ratingView.settings.emptyBorderColor = color
        }
    }

    var playerViewController: AVPlayerViewController?

    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var providerLabel: UILabel!
    @IBOutlet var tagListView: TagListView!
    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var buttonStack: UIStackView!
    @IBOutlet var nextButton: UIButton!

    @IBAction func tapWatched(_ sender: Any) {
        defer {
            let _ = self.navigationController?.popViewController(animated: true)
        }

        var progress = 1.0
        if
            let queuePlayer = self.playerViewController?.player as? AVQueuePlayer,
            let videoTime = queuePlayer.items()[safe: 0]?.currentTime(),
            let videoDuration = queuePlayer.items()[safe: 0]?.duration,
            queuePlayer.items().count > 1, videoTime.isValid, videoDuration.isValid {
            if queuePlayer.items().count == 3 {
                progress = 0.0
            } else {
                progress = videoTime.seconds / videoDuration.seconds
            }
        }

        let rating = self.ratingActive ? (self.ratingView.rating - 1) / Double(self.ratingView.settings.totalStars - 1) : -1.0

        log.debug("tapWatched")
        log.verbose("rated video \(self.video?.id) with \(rating) (progress: \(progress))")

        let now = Date() as NSDate
        let _ = WatchedVideo.newEntity(forVideoId: self.video?.id, withDate: now, progress: progress, rating: rating)
        CoreDataHelper.saveContext()
    }

    @IBAction func tapGoBack() {
        let videoTime = self.playerViewController?.player?.currentTime() ?? CMTimeMake(0, 1)
        let videoDuration = self.playerViewController?.player?.currentItem?.duration ?? CMTimeMake(1, 1)
        let progress = videoTime.seconds / videoDuration.seconds

        FirebaseHelper.logVideoGoBack(video: self.video, time: progress)

        let _ = self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        self.titleLabel.text = self.video?.name
        self.providerLabel.text = self.video?.providerText

        if let duration = self.video?.duration {
            self.durationLabel.text = String(format: "%d:%02d", duration/60, duration % 60)
        } else {
            self.durationLabel.text = nil
        }

        self.imageView.layer.cornerRadius = 2.0
        self.imageView.layer.masksToBounds = true
        self.imageView.loadFrom(self.video?.imageUrl, orShow: "Keine Vorschau verfügbar")

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RateVideoViewController.resumeVideo))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.imageView.addGestureRecognizer(tapGesture)
        self.imageView.isUserInteractionEnabled = true

        self.tagListView.alignment = .center
        self.tagListView.removeAllTags()
        for tag in self.video?.tags?.components(separatedBy: ",") ?? [] {
            if tag.characters.count > 0 {
                self.tagListView.addTag(tag)
            }
        }

        self.nextButton.backgroundColor = UIColor.nanouOrange
        self.nextButton.tintColor = UIColor.white
        self.nextButton.layer.masksToBounds = true
        self.nextButton.layer.cornerRadius = 2.0

        // set all view but imageview to hidden
        self.durationLabel.isHidden = true
        self.titleLabel.isHidden = true
        self.providerLabel.isHidden = true
        self.tagListView.isHidden = true
        self.ratingView.isHidden = true
        self.buttonStack.isHidden = true

        self.ratingView.didTouchCosmos = { value in
            if !self.ratingActive {
                self.ratingActive = true
            }
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(RateVideoViewController.didEndPlayback),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !self.videoWasStartedBefore {
            self.videoWasStartedBefore = true
            self.playVideo(automatically: true) {
                self.durationLabel.isHidden = false
                self.titleLabel.isHidden = false
                self.providerLabel.isHidden = false
                self.tagListView.isHidden = false
                self.ratingView.isHidden = false
                self.buttonStack.isHidden = false
            }
        } else {
            let videoTime = self.playerViewController?.player?.currentTime() ?? CMTimeMake(0, 1)
            let videoDuration = self.playerViewController?.player?.currentItem?.duration ?? CMTimeMake(1, 1)
            let progress = videoTime.seconds / videoDuration.seconds

            FirebaseHelper.logVideoPlaybackStop(video: self.video, at: progress)
        }
    }

    func resumeVideo() {
        self.playVideo(automatically: false)
    }

    func playVideo(automatically: Bool, _ completion: (() -> (Void))? = nil) {
        if let playerVc = self.playerViewController {
            let videoTime = playerVc.player?.currentTime() ?? CMTimeMake(0, 1)
            let videoDuration = playerVc.player?.currentItem?.duration ?? CMTimeMake(1, 1)
            let progress = videoTime.seconds / videoDuration.seconds

            FirebaseHelper.logVideoPlaybackStart(video: self.video, at: progress, automatic: automatically)

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

        let player = AVQueuePlayer(contentUrl: videoUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        return playerViewController
    }

    func didEndPlayback() {
        if let queuePlayer = self.playerViewController?.player as? AVQueuePlayer {
            let lastItem = queuePlayer.items().last
            if queuePlayer.currentItem == lastItem {
                self.playerViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }

}
