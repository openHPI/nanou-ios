//
//  HistoryViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 14/02/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UITableViewController {
    var resultsController: NSFetchedResultsController<HistoryVideo>?
    var cellReuseIdentifier = "historyVideoCell"

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.syncHistory()
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
        historyCell.imageview.loadFrom(historyVideo?.imageUrl, orShow: "?")
        historyCell.imageview.layer.masksToBounds = true
        historyCell.imageview.layer.cornerRadius = 2.0
        historyCell.progressView.progress = Float(historyVideo?.progress ?? 0)
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
            self.tableView.insertRows(at: [indexPath!], with: .fade)
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
        return self.resultsController?.sections?[section].numberOfObjects ?? 0
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
