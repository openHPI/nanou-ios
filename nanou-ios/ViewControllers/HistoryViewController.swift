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
import SafariServices

class HistoryViewController: UITableViewController {
    var resultsController: NSFetchedResultsController<HistoryVideo>?
    var cellReuseIdentifier = "historyVideoCell"

    var playerViewController: AVPlayerViewController?
    var lastVideo: HistoryVideo?

    var emptyStateTimer: Timer?
    var tableViewState: CollectionViewState = .displaying {
        didSet {
            DispatchQueue.main.async {
                switch self.tableViewState {
                case .displaying:
                    self.emptyState?.isHidden = true
                    self.loadingView?.isHidden = true
                case .loading:
                    self.emptyState?.isHidden = true
                    self.loadingView?.isHidden = false
                case .empty:
                    self.emptyState?.isHidden = false
                    self.loadingView?.isHidden = true
                }
            }
        }
    }
    var emptyState: UIView?
    var loadingView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let request: NSFetchRequest<HistoryVideo> = HistoryVideo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        self.resultsController = CoreDataHelper.createResultsController(fetchRequest: request, sectionNameKeyPath: nil)
        self.resultsController?.delegate = self

        do {
            try resultsController?.performFetch()
        } catch {
            // TODO: Error handling.
        }

        // Empty State
        let emptyFrame = CGRect(origin: CGPoint.zero, size: self.view.bounds.size)
        let emptyLabel = UILabel(frame: emptyFrame)
        emptyLabel.text = "Los schau ein paar Videos!"
        emptyLabel.textColor = UIColor.nanouOrange
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 27)
        emptyLabel.sizeToFit()
        emptyLabel.isHidden = true
        self.emptyState = emptyLabel


        // Loading View
        let loadingFrame = CGRect(origin: CGPoint.zero, size: self.view.bounds.size)
        let loadingLabel = UILabel(frame: loadingFrame)
        loadingLabel.text = "Laden ..."
        loadingLabel.textColor = UIColor.nanouOrange
        loadingLabel.numberOfLines = 0
        loadingLabel.textAlignment = .center
        loadingLabel.font = UIFont.systemFont(ofSize: 21)
        loadingLabel.sizeToFit()
        loadingLabel.isHidden = true
        self.loadingView = loadingLabel

        self.tableView.backgroundView = UIView(frame: loadingFrame)
        self.tableView.backgroundView?.addSubview(self.emptyState!)
        self.tableView.backgroundView?.addSubview(self.loadingView!)
        self.emptyState?.frame = emptyFrame
        self.loadingView?.frame = loadingFrame

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(HistoryViewController.didEndPlayback),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableViewState = .loading
        self.trackWatchVideo()
        self.syncHistory()
    }

    func trackWatchVideo() {
        defer {
            self.playerViewController = nil
            self.lastVideo = nil
        }

        guard let video = self.lastVideo else {
            log.verbose("HistoryViewController | trackWatchVideo | cannot track watch video: no video")
            return
        }

        let progress = (self.playerViewController?.player as? NanouPlayer)?.progress ?? -1.0
        let rating = -1.0

        log.verbose("rated video \(video.id) with \(rating) (progress: \(progress))")


        FirebaseHelper.logHistoryVideoPlaybackStop(historyVideo: video, at: progress)


        let now = Date() as NSDate
        let _ = WatchedVideo.newEntity(forVideoId: video.id, withDate: now, progress: progress, rating: rating)
        CoreDataHelper.saveContext()
    }

    func syncHistory() {
        SyncHelper.standard.fetch(helper: HistoryHelper.self) { count in
            self.tableViewState = count == 0 ? .empty : .displaying
        }
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

        DispatchQueue.main.async {
            if let licenseName = historyVideo?.licenseName {
                historyCell.licenseButton.setTitle(licenseName, for: .normal)
                historyCell.licenseButton.isHidden = false
            } else {
                historyCell.licenseButton.isHidden = true
            }
        }

        historyCell.tagListView.removeAllTags()
        for tag in historyVideo?.tags?.components(separatedBy: ",") ?? [] {
            if tag.characters.count > 0 {
                historyCell.tagListView.addTag(tag)
            }
        }

        historyCell.delegate = self
    }

    func didEndPlayback() {
        if let player = self.playerViewController?.player as? NanouPlayer, player.isLastItem {
            self.playerViewController?.dismiss(animated: true, completion: nil)
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
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
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
//        self.showEmptyState()
        return self.resultsController?.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        self.configureTableCell(cell: cell, indexPath: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
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

        let player = NanouPlayer(contentUrl: videoUrl)
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

extension HistoryViewController: HistoryCellDelegate {

    func didTapLicense(cell: HistoryCell) {
        if let indexPath = self.tableView?.indexPath(for: cell), let video = self.resultsController?.object(at: indexPath), let urlString = video.licenseUrl, let licenseUrl = URL(string: urlString) {
            let safariViewController = SFSafariViewController(url: licenseUrl)
            self.present(safariViewController, animated: true, completion: nil)
        } else {
            log.error("HistoryViewController | Failed to show license")
        }
    }

}
