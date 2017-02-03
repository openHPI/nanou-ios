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

class VideosViewController: UICollectionViewController {
    var resultsController: NSFetchedResultsController<Video>?
    var cellReuseIdentifier = "videoCell"

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.syncVideos()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.syncVideos()
    }

    func syncVideos() {
        SyncHelper.standard.fetch(helper: VideoHelper.self)
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
        guard let videoCell = cell as? VideoCell else {
            log.error("VideoViewController | retrieved wrong cell")
            return
        }

        let video = self.resultsController?.object(at: indexPath)
        videoCell.delegate = self
        videoCell.layer.cornerRadius = 2.0
        videoCell.layer.masksToBounds = true
        videoCell.titleLabel.text = video?.name
        videoCell.imageView.loadFrom(video?.imageUrl, orShow: "No thumbnail available")
        videoCell.imageView.layer.masksToBounds = true
        videoCell.providerLabel.text = video?.providerText
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
        self.performSegue(withIdentifier: "watchVideo", sender: cell)
    }

    func didDismiss(cell: VideoCell) {
        log.debug("VideosViewController | dismiss video")
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
        return self.resultsController?.sections?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.resultsController?.sections?[section].numberOfObjects ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)
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
