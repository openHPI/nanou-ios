//
//  PreferencesViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 07/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import UIKit
import CoreData

class PreferencesViewController: UITableViewController {

    var resultsController: NSFetchedResultsController<Preference>?
    var cellReuseIdentifier = "preferenceCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        let request: NSFetchRequest<Preference> = Preference.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        self.resultsController = CoreDataHelper.createResultsController(fetchRequest: request, sectionNameKeyPath: "name")
        self.resultsController?.delegate = self

        do {
            try resultsController?.performFetch()
        } catch {
            // TODO: Error handling.
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.syncPreferences()
    }

    func syncPreferences() {
        SyncHelper.standard.fetch(helper: PreferenceHelper.self)
    }

    func configureTableCell(cell: UITableViewCell, indexPath: IndexPath) {
        guard let preferenceCell = cell as? PreferenceCell else {
            log.error("PreferenceViewController | retrieved wrong cell")
            return
        }

        preferenceCell.delegate = self
        if let weight = self.resultsController?.object(at: indexPath).weight?.floatValue {
            preferenceCell.weightSlider.value = weight
        }
    }

}

extension PreferencesViewController: NSFetchedResultsControllerDelegate {

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
extension PreferencesViewController {

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

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return resultsController?.sections?[section].name
    }

}

extension PreferencesViewController: PreferenceCellDelegate {

    func cell(_ cell: PreferenceCell, didChangeValue value: Float) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            log.error("PreferenceViewController | could not find indexPath for cell")
            return
        }

        let preference = self.resultsController?.object(at: indexPath)
        let oldValue = preference?.weight
        preference?.weight = NSDecimalNumber(value: value)

        FirebaseHelper.logPreferenceChange(preference: preference, from: oldValue?.floatValue ?? -1.0, to: value)

        CoreDataHelper.saveContext()
    }

}
