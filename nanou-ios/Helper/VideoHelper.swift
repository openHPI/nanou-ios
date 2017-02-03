//
//  VideoHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 25/01/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import BrightFutures
import CoreData

struct VideoHelper: BaseModelHelper {

    static func sync() -> Future<[Video], NanouError> {
        // contains also Xikolo provider method (get)
        return SpineHelper.findAll(type: VideoSpine.self).flatMap { spineVideos -> Future<[Video], NanouError> in
            return SpineModelHelper.syncObjectsFuture(objectsToUpdateRequest: Video.fetchRequest(), spineObjects: spineVideos, inject: nil, save: false)
        }
    }

}
