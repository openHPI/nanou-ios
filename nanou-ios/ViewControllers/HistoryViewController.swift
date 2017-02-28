//
//  HistoryViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 14/02/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreData

class HistoryViewController: UITableViewController {
    var resultsController: NSFetchedResultsController<HistoryVideo>?
    var cellReuseIdentifier = "historyVideoCell"

    var playerViewController: AVPlayerViewController?
    var lastVideo: HistoryVideo?

    var emptyStateTimer: Timer?
    var isTableViewEmpty = false {
        didSet {
            if self.isTableViewEmpty {
                if self.emptyStateTimer != nil {
                    return
                }
                self.emptyStateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { timer in
                    self.emptyState?.isHidden = false
                })
            } else {
                self.emptyStateTimer?.invalidate()
                self.emptyStateTimer = nil
                self.emptyState?.isHidden = true
            }
        }
    }
    var emptyState: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let request: NSFetchRequest<HistoryVideo> = HistoryVideo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        self.resultsController = CoreDataHelper.createResultsController(fetchRequest: request, sectionNameKeyPath: "date")
        self.resultsController?.delegate = self

        do {
            try resultsController?.performFetch()
        } catch {
            // TODO: Error handling.
        }

        // Empty State
        let frame = CGRect(origin: CGPoint.zero, size: self.view.bounds.size)
        let messageLabel = UILabel(frame: frame)
        messageLabel.text = "Los schau ein paar Videos!"
        messageLabel.textColor = UIColor.nanouOrange
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 27)
        messageLabel.sizeToFit()

        self.emptyState = messageLabel
        self.tableView.backgroundView = messageLabel
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.trackWatchVideo()
        self.syncHistory()
    }

    func trackWatchVideo() {
        defer {
            self.playerViewController = nil
            self.lastVideo = nil
        }

        guard let playerViewController = self.playerViewController else {
            log.verbose("HistoryViewController | trackWatchVideo | cannot track watch video: no player vc")
            return
        }

        guard let video = self.lastVideo else {
            log.verbose("HistoryViewController | trackWatchVideo | cannot track watch video: no video")
            return
        }

        guard
            let videoTime = playerViewController.player?.currentTime(),
            let videoDuration = playerViewController.player?.currentItem?.duration,
            videoTime.isValid, videoDuration.isValid else {
                log.verbose("HistoryViewController | trackWatchVideo | cannot track watch video: no valid video time")
                return
        }

        let progress = videoTime.seconds / videoDuration.seconds
        let rating = -1.0

        log.verbose("rated video \(video.id) with \(rating) (progress: \(progress))")


        FirebaseHelper.logHistoryVideoPlaybackStop(historyVideo: video, at: progress)


        let now = Date() as NSDate
        let _ = WatchedVideo.newEntity(forVideoId: video.id, withDate: now, progress: progress, rating: rating)
        CoreDataHelper.saveContext()
    }

    func syncHistory() {
        SyncHelper.standard.fetch(helper: HistoryHelper.self)
    }

    func configureTableCell(cell: UITableViewCell, indexPath: IndexPath) {
        guard let historyCell = cell as? HistoryCell else {
            log.error("HistoryViewController | retrieved wrong cell")
            return
        }

        let historyVideo = self.resultsController?.object(at: indexPath)
        historyCell.titleLabel.text = historyVideo?.name
        historyCell.providerLabel.text = historyVideo?.providerName
        historyCell.countLabel.text = String(describing: historyVideo?.count ?? 1)
        historyCell.imageview.loadFrom(historyVideo?.imageUrl, orShow: "?")
        historyCell.imageview.layer.masksToBounds = true
        historyCell.imageview.layer.cornerRadius = 2.0
        historyCell.progressView.progress = Float(historyVideo?.progress ?? 0)

        if let duration = historyVideo?.duration {
            historyCell.durationLabel.text = String(format: "%d:%02d", duration/60, duration % 60)
        } else {
            historyCell.durationLabel.text = nil
        }

        historyCell.tagListView.removeAllTags()
        for tag in historyVideo?.tags?.components(separatedBy: ",") ?? [] {
            if tag.characters.count > 0 {
                historyCell.tagListView.addTag(tag)
            }
        }
    }

}


extension HistoryViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) {
                self.configureTableCell(cell: cell, indexPath: indexPath!)
            }
        case .move:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }

}

// MARK: - UITableViewDataSource
extension HistoryViewController {

    override func numberOfSections(in: UITableView) -> Int {
        if let resultsController = self.resultsController {
            if resultsController.sectionNameKeyPath == nil {
                return 1
            } else {
                return resultsController.sections?.count ?? 0
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let objectCount = self.resultsController?.sections?[section].numberOfObjects ?? 0
        if section == 0 {
            self.isTableViewEmpty = (objectCount == 0)
        }
        return objectCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        self.configureTableCell(cell: cell, indexPath: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }

}

// MARK: - UITableViewDelegate
extension HistoryViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let historyVideo = self.resultsController?.object(at: indexPath)

        guard let url = historyVideo?.streamUrl else {
            log.error("HistoryViewController | invalid url string")
            return
        }

        guard let videoUrl = URL(string: url) else {
            log.error("HistoryViewController | invalid url")
            return
        }

        let player = AVPlayer(url: videoUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.playerViewController = playerViewController
        self.lastVideo = historyVideo

        self.present(playerViewController, animated: true) {
            self.tableView.deselectRow(at: indexPath, animated: true)

            let videoTime = player.currentTime()
            let videoDuration = player.currentItem?.duration ?? CMTimeMake(1, 1)
            let progress = videoTime.seconds / videoDuration.seconds

            FirebaseHelper.logHistoryVideoPlaybackStart(historyVideo: historyVideo, at: progress)

            player.play()
        }
    }

}
