//
//  SyncHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 18/01/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import Foundation
import CoreData
import ProcedureKit


class SyncHelper {
    static let standard = SyncHelper()
    let queue = ProcedureQueue()

    func startObserving() {
        NotificationCenter.default.addObserver(self, selector: #selector(coreDataChange(note:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: CoreDataHelper.context)
        log.verbose("Start oberserving CoreData")
    }

    func stoppObserving() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: CoreDataHelper.context)
        log.verbose("Stop observing CoreData")
    }

    @objc func coreDataChange(note: Notification) {
        if let updated = note.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updated.count > 0 {
            for case let update as Preference in updated {
                let networksave = NetworkProcedure<SaveProcedure<Preference>> {
                    return SaveProcedure(resource: update.resource())
                }
                self.queue.add(operation: networksave)
            }
        }

        if let deleted = note.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, deleted.count > 0 {
            print("deleted: \(deleted)")
        }

        if let inserted = note.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserted.count > 0 {
            print("inserted: \(inserted)")
            for case let insert as WatchedVideo in inserted {
                let networksave = NetworkProcedure<SaveProcedure<WatchedVideo>> {
                    return SaveProcedure(resource: insert.resource())
                }
                let networkfetch = NetworkProcedure<FetchProcedure<VideoHelper>> {
                    return FetchProcedure(helper: VideoHelper.self)
                }
                networkfetch.add(dependency: networksave)
                self.queue.add(operation: networksave)
                self.queue.add(operation: networkfetch)
            }
        }
    }

    func fetch<T: BaseModelHelper>(helper: T.Type) {
        let networkfetch = NetworkProcedure<FetchProcedure<T>> {
            return FetchProcedure(helper: helper)
        }
        self.queue.add(operation: networkfetch)
    }

}
