//
//  Preference.swift
//  nanou-ios
//
//  Created by Max Bothe on 07/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import CoreData
import Foundation
import Spine

class Preference: BaseModel {

    func resource() -> PreferenceSpine {
        let pref = PreferenceSpine()
        pref.id = self.id
        pref.name = self.name
        pref.weight = self.weight
        return pref
    }

}

class PreferenceSpine: BaseModelSpine<Preference> {

    var name: String?
    var weight: NSNumber?

    convenience init(preference: Preference) {
        self.init()
        self.id = preference.id
        self.name = preference.name
        self.weight = preference.weight
    }

    override class var resourceType: ResourceType {
        return "preferences"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "name": Attribute(),
            "weight": Attribute(),
        ])
    }
}
