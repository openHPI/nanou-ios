//
//  CoreDataNetworkProcedure.swift
//  nanou-ios
//
//  Created by Max Bothe on 03/02/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import Foundation
import ProcedureKit

struct CoreDataPayloadResponse<T: BaseModel>: HTTPPayloadResponseProtocol {

    public static func == (lhs: CoreDataPayloadResponse<T>, rhs: CoreDataPayloadResponse<T>) -> Bool {
        guard let lhsPayload = lhs.payload, let rhsPayload = rhs.payload else { return false }
        return lhsPayload == rhsPayload
    }

    public var payload: Set<T>?
    public var response: HTTPURLResponse

    public init(payload: Set<T>?) {
        self.payload = payload
        let statusCode = payload == nil ? HTTPStatusCode.requestTimeout : HTTPStatusCode.ok
        let url = URL(string: Route.base)!
        self.response = HTTPURLResponse(url: url, statusCode: statusCode.rawValue, httpVersion: nil, headerFields: nil)!
    }
}

class CoreDataNetworkProcedure<T: BaseModel>: Procedure, NetworkOperation, OutputProcedure {
    typealias Output = CoreDataPayloadResponse<T>
    typealias SpineNetworkResult = ProcedureResult<Output>

    var output: Pending<SpineNetworkResult> {
        get {
            return stateLock.withCriticalScope {
                self.internalOutput
            }
        }
        set {
            stateLock.withCriticalScope {
                self.internalOutput = newValue
            }
        }
    }

    private let stateLock = NSLock()
    private var internalOutput: Pending<SpineNetworkResult> = .pending

    public var networkError: Error? {
        return errors.first
    }

}
