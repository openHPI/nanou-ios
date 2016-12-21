//
//  BaseModelSpine.swift
//  nanou-ios
//
//  Created by Max Bothe on 07/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import Spine

class BaseModelSpine<T: BaseModel>: Resource {
    typealias cdType = T
}

class CompoundAttribute: Attribute {
}

class CompoundValue: NSObject {

    func saveToCoreData(_ model: BaseModel) {
        fatalError("Subclasses of CompoundValue need to implement saveToCoreData(model:).")
    }

}
