//
//  HistoryHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 14/02/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import BrightFutures
import CoreData

struct HistoryHelper: BaseModelHelper {

    static func sync() -> Future<[HistoryVideo], NanouError> {
        // contains also Xikolo provider method (get)
        return SpineHelper.findAll(type: HistoryVideoSpine.self).flatMap { spineHistory -> Future<[HistoryVideo], NanouError> in
            return SpineModelHelper.syncObjectsFuture(objectsToUpdateRequest: HistoryVideo.fetchRequest(), spineObjects: spineHistory, inject: nil, save: false)
        }
    }

}
