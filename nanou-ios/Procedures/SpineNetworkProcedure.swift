//
//  SpineNetworkProcedure.swift
//  nanou-ios
//
//  Created by Max Bothe on 01/02/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import Foundation
import ProcedureKit

struct SpinePayloadResponse<T: BaseModel>: HTTPPayloadResponseProtocol {

    public static func == (lhs: SpinePayloadResponse<T>, rhs: SpinePayloadResponse<T>) -> Bool {
        return lhs.payload == rhs.payload
    }

    public var payload: BaseModelSpine<T>?
    public var response: HTTPURLResponse

    public init(payload: BaseModelSpine<T>?) {
        self.payload = payload
        let statusCode = payload == nil ? HTTPStatusCode.requestTimeout : HTTPStatusCode.ok
        let url = URL(string: Route.base)!
        self.response = HTTPURLResponse(url: url, statusCode: statusCode.rawValue, httpVersion: nil, headerFields: nil)!
    }
}

class SpineNetworkProcedure<T: BaseModel>: Procedure, NetworkOperation, OutputProcedure {
    typealias Output = SpinePayloadResponse<T>
    typealias SpineNetworkResult = ProcedureResult<Output>

    var output: Pending<SpineNetworkResult> {
        get {
            return stateLock.withCriticalScope {
                self._output
            }
        }
        set {
            stateLock.withCriticalScope {
                self._output = newValue
            }
        }
    }

    private let stateLock = NSLock()
    private var _output: Pending<SpineNetworkResult> = .pending

    public var networkError: Error? {
        return errors.first
    }

}
