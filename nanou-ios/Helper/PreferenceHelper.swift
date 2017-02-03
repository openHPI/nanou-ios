//
//  PreferenceHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 07/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import BrightFutures
import CoreData

struct PreferenceHelper: BaseModelHelper {

    static func sync() -> Future<[Preference], NanouError> {
        // contains also Xikolo provider method (get)
        return SpineHelper.findAll(type: PreferenceSpine.self).flatMap { spinePreferences -> Future<[Preference], NanouError> in
            return SpineModelHelper.syncObjectsFuture(objectsToUpdateRequest: Preference.fetchRequest(), spineObjects: spinePreferences, inject: nil, save: false)
        }
    }

}
