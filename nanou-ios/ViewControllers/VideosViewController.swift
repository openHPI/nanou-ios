//
//  VideosViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 25/01/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage
import SafariServices

enum CollectionViewState {
    case displaying
    case loading
    case empty
}

class VideosViewController: UICollectionViewController {
    var resultsController: NSFetchedResultsController<Video>?
    var cellReuseIdentifier = "videoCell"
    var emptyStateTimer: Timer?
    var videosSynced = false
    var collectionViewState: CollectionViewState = .displaying {
        didSet {
            DispatchQueue.main.async {
                switch self.collectionViewState {
                case .displaying:
                    self.emptyState.isHidden = true
                    self.loadingView.isHidden = true
                case .loading:
                    self.emptyState.isHidden = true
                    self.loadingView.isHidden = false
                case .empty:
                    self.emptyState.isHidden = false
                    self.loadingView.isHidden = true
                }
            }
        }
    }
    @IBOutlet var emptyState: UIView!
    @IBOutlet var loadingView: UIView!

    var contentChangeOperations: [ContentChangeOperation] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.decelerationRate = UIScrollViewDecelerationRateFast

        let request: NSFetchRequest<Video> = Video.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        self.resultsController = CoreDataHelper.createResultsController(fetchRequest: request, sectionNameKeyPath: nil)
        self.resultsController?.delegate = self

        do {
            try resultsController?.performFetch()
        } catch {
            // TODO: Error handling.
        }

        self.emptyState.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.videosSynced {
            self.collectionViewState = .loading
            self.syncVideos()
            self.videosSynced = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videosSynced = false
    }

    func syncVideos() {
        FirebaseHelper.logVideoFetch()
        SyncHelper.standard.fetch(helper: VideoHelper.self) { count in
            self.collectionViewState = count == 0 ? .empty : .displaying
        }
        SurveyHelper.standard.fetchLatestSurvey { survey in
            if let survey = survey, !SurveyHelper.standard.askedForLatestBefore {
                let alert = UIAlertController(title: "Hilf uns die App zu besseren",
                                              message: "Mit einer Umfrage wollen wir das Konzept der App verbessern. Die Umfrage kann auch jeder Zeit im Nutzer-Tab aufgerufen werden.",
                                              preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.cancel, handler: { action in
                    SurveyHelper.standard.setAsked()
                }))
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { action in
                    SurveyHelper.standard.showSurvey(with: survey.url, on: self)
                }))
                self.present(alert, animated: true)
            }
        }
    }

    deinit {
        self.contentChangeOperations.removeAll(keepingCapacity: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "watchVideo" {
            guard let rateVc = segue.destination as? RateVideoViewController else {
                log.error("VideosViewController | wrong destination view controller")
                return
            }

            guard let cell = sender as? VideoCell else {
                log.error("VideosViewController | wrong sender")
                return
            }

            guard let indexPath = self.collectionView?.indexPath(for: cell) else {
                log.error("VideosViewController | wrong indexPath")
                return
            }

            let video = self.resultsController?.object(at: indexPath)
            rateVc.video = video
        }
    }

    func configureCollectionCell(_ cell: UICollectionViewCell, indexPath: IndexPath) {
        cell.layer.cornerRadius = 2.0
        cell.layer.masksToBounds = true

        guard let videoCell = cell as? VideoCell else {
            log.error("VideoViewController | retrieved wrong cell (video cell)")
            return
        }

        let video = self.resultsController?.object(at: indexPath)
        videoCell.delegate = self
        videoCell.titleLabel.text = video?.name
        videoCell.imageView.loadFrom(video?.imageUrl, orShow: "Keine Vorschau verfügbar")
        videoCell.imageView.layer.masksToBounds = true
        videoCell.providerLabel.text = video?.providerText
        videoCell.tags.alignment = .center

        if let duration = video?.duration {
            videoCell.durationLabel.text = String(format: "%d:%02d", duration/60, duration % 60)
        } else {
            videoCell.durationLabel.text = nil
        }

        DispatchQueue.main.async {
            if let licenseName = video?.licenseName {
                videoCell.licenseButton.setTitle(licenseName, for: .normal)
                videoCell.licenseButton.isHidden = false
            } else {
                videoCell.licenseButton.isHidden = true
            }
        }

        videoCell.tags.removeAllTags()
        for tag in video?.tags?.components(separatedBy: ",") ?? [] {
            if tag.characters.count > 0 {
                videoCell.tags.addTag(tag)
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        guard let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        flowLayout.invalidateLayout()
    }

}


extension VideosViewController: VideoCellDelegate {

    func didSelect(cell: VideoCell) {
        if let indexPath = self.collectionView?.indexPath(for: cell), let video = self.resultsController?.object(at: indexPath) {
            FirebaseHelper.logVideoSelect(video: video)
        } else {
            log.error("VideosViewController | Failed to log video select")
        }

        self.performSegue(withIdentifier: "watchVideo", sender: cell)
    }

    func didDismiss(cell: VideoCell) {
        log.debug("VideosViewController | dismiss video")

        guard let indexPath = self.collectionView?.indexPath(for: cell) else {
            log.error("VideosViewController | didDismiss | wrong indexPath")
            return
        }

        guard let video = self.resultsController?.object(at: indexPath) else {
            log.error("VideosViewController | didDismiss | video not found")
            return
        }

        let now = Date() as NSDate
        let progress = 0.0
        let rating = -1.0

        log.verbose("rated video \(video.id) with \(rating) (progress: \(progress))")

        FirebaseHelper.logVideoDismiss(video: video)

        let _ = WatchedVideo.newEntity(forVideoId: video.id, withDate: now, progress: progress, rating: rating)
        CoreDataHelper.context.delete(video)
        CoreDataHelper.saveContext()

        self.collectionViewState = .loading
    }

    func didTapLicense(cell: VideoCell) {
        if let indexPath = self.collectionView?.indexPath(for: cell), let video = self.resultsController?.object(at: indexPath), let urlString = video.licenseUrl, let licenseUrl = URL(string: urlString) {
            let safariViewController = SFSafariViewController(url: licenseUrl)
            self.present(safariViewController, animated: true, completion: nil)
        } else {
            log.error("VideosViewController | Failed to show license")
        }
    }

}

extension VideosViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.contentChangeOperations.removeAll()
    }

    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        self.contentChangeOperations.append(ContentChangeOperation(type: type, indexSet: IndexSet(integer: sectionIndex)))
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        contentChangeOperations.append(ContentChangeOperation(type: type, indexPath: indexPath, newIndexPath: newIndexPath))
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView!.performBatchUpdates({
            let collectionView = self.collectionView!
            for change in self.contentChangeOperations {
                switch change.context {
                case .section:
                    switch change.type {
                    case .insert:
                        collectionView.insertSections(change.indexSet!)
                    case .delete:
                        collectionView.deleteSections(change.indexSet!)
                    case .move:
                        break
                    case .update:
                        break
                    }
                case .object:
                    switch change.type {
                    case .insert:
                        collectionView.insertItems(at: [change.newIndexPath!])
                    case .delete:
                        collectionView.deleteItems(at: [change.indexPath!])
                    case .update:
                        // No need to update a cell that has not been loaded.
                        collectionView.reloadItems(at: [change.indexPath!])
                        if let cell = collectionView.cellForItem(at: change.indexPath!) {
                            self.configureCollectionCell(cell, indexPath: change.indexPath!)
                        }
                    case .move:
                        collectionView.deleteItems(at: [change.indexPath!])
                        collectionView.insertItems(at: [change.newIndexPath!])
                    }
                }
            }
        }, completion: nil)
    }

}


// MARK: - UICollectionViewDataSource
extension VideosViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let sectionCount = self.resultsController?.sections?.count ?? 0
        return sectionCount == 0 ? 1 : sectionCount
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.resultsController?.sections?[section].numberOfObjects ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "videoCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        self.configureCollectionCell(cell, indexPath: indexPath)
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
fileprivate let padding: CGFloat = 20.0

extension VideosViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 0
        let width = collectionView.bounds.width - 2*padding
        let height = collectionView.bounds.height - 2*padding - tabBarHeight - statusBarHeight
        return CGSize(width: min(width, height), height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height ?? 0

        let cellSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: IndexPath(item: 0, section: section))
        let numberOfCellsInSection = CGFloat(self.resultsController?.sections?[section].numberOfObjects ?? 0)
        let viewWidth = self.collectionView?.frame.size.width ?? 0
        let horizontalPadding = max(0, (viewWidth - 2*padding - numberOfCellsInSection * cellSize.width) / 2)

        return UIEdgeInsets(top: statusBarHeight + padding,
                            left: padding + horizontalPadding,
                            bottom: tabBarHeight + padding,
                            right: padding + horizontalPadding)
    }


}

struct ContentChangeOperation {

    var context: FetchedResultsChangeContext
    var type: NSFetchedResultsChangeType
    var indexSet: IndexSet?
    var indexPath: IndexPath?
    var newIndexPath: IndexPath?

    init(type: NSFetchedResultsChangeType, indexSet: IndexSet) {
        self.context = .section
        self.type = type
        self.indexSet = indexSet
    }

    init(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?) {
        self.context = .object
        self.type = type
        self.indexPath = indexPath
        self.newIndexPath = newIndexPath
    }

}

enum FetchedResultsChangeContext {
    case section
    case object
}
