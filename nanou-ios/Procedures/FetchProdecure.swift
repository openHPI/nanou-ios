//
//  FetchProdecure.swift
//  nanou-ios
//
//  Created by Max Bothe on 02/02/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import Foundation
import ProcedureKit
import CoreData
import BrightFutures

class FetchProcedure<T: BaseModelHelper>: CoreDataNetworkProcedure<T.Base> {
    let helper: T.Type

    init(helper: T.Type) {
        self.helper = helper
        super.init()
    }

    override func execute() {
        guard !isCancelled else { return }

        self.helper.sync().onSuccess { cdObjects in
            let http = CoreDataPayloadResponse(payload: Set(cdObjects))
            self.finish(withResult: .success(http))
        }.onFailure { nanouError in
            if case .api(let spineError) = nanouError, case .networkError = spineError {
                let payload: Set<T.Base>? = nil
                let http = CoreDataPayloadResponse(payload: payload)
                self.finish(withResult: .success(http))
            } else {
                self.finish(withResult: .failure(nanouError))
            }
        }
    }

}
