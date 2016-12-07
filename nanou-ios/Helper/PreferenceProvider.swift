//
//  PreferenceProvider.swift
//  nanou-ios
//
//  Created by Max Bothe on 07/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import BrightFutures
import Foundation

class PreferenceProvider {

    class func getPreferences() -> Future<[PreferenceSpine], NanouError> {
        return SpineHelper.findAll(type: PreferenceSpine.self)
    }

}
