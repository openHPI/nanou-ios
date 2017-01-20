//
//  SaveProcedure.swift
//  nanou-ios
//
//  Created by Max Bothe on 20/01/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import Foundation
import ProcedureKit

class SaveProcedure<T: BaseModel>: Procedure {
    let resource: BaseModelSpine<T>

    init(resource: BaseModelSpine<T>) {
        self.resource = resource
        super.init()
    }

    override func execute() {
        guard !isCancelled else { return }
        print("Hello World")
        SpineHelper.save(resource: resource)
        finish()
    }

}
