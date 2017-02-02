//
//  SaveProcedure.swift
//  nanou-ios
//
//  Created by Max Bothe on 20/01/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import Foundation
import ProcedureKit

class SaveProcedure<T: BaseModel>: SpineNetworkProcedure<T> {
    let resource: BaseModelSpine<T>

    init(resource: BaseModelSpine<T>) {
        self.resource = resource
        super.init()
    }

    override func execute() {
        guard !isCancelled else { return }
        SpineHelper.save(resource: resource).onSuccess { spineObject in
            let http = SpinePayloadResponse(payload: spineObject)
            self.finish(withResult: .success(http))
        }.onFailure { nanouError in
            if case .api(let spineError) = nanouError, case .networkError = spineError {
                let payload: BaseModelSpine<T>? = nil
                let http = SpinePayloadResponse(payload: payload)
                self.finish(withResult: .success(http))
            } else {
                self.finish(withResult: .failure(nanouError))
            }
        }
    }

}
