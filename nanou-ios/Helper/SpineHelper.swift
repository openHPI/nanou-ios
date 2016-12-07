//
//  SpineHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 07/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import BrightFutures
import Spine
import SwiftyBeaver


class NanouClient: HTTPClient {
    var headers: [String: String] {
        return NetworkHelper.requestHeaders
    }

    override func buildRequest(_ method: String, url: URL, payload: Data?) -> URLRequest {
        let urlWithSlash = url.absoluteString.characters.last == "/" ? url : url.appendingPathComponent("/")

        var request = super.buildRequest(method, url: urlWithSlash, payload: payload)

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

}

struct SwiftyBeaverLogger: Logger {

    func log<T>(_ object: T, level: LogLevel) {
        switch level {
        case .error:
            SwiftyBeaver.error(object)
        case .warning:
            SwiftyBeaver.warning(object)
        case .info:
            SwiftyBeaver.info(object)
        case .debug:
            SwiftyBeaver.debug(object)
        default:
            SwiftyBeaver.verbose(object)
        }
    }

}

class SpineHelper {

    private static var spine: Spine = {
        #if DEBUG
            Spine.logger = SwiftyBeaverLogger()
            Spine.setLogLevel(.debug, forDomain: .networking)
            Spine.setLogLevel(.debug, forDomain: .serializing)
            Spine.setLogLevel(.debug, forDomain: .spine)
        #endif

        let spine = Spine(baseURL: NSURL(string: Route.api) as! URL, networkClient: NanouClient())  // tailor:disable

        spine.registerResource(PreferenceSpine.self)

        return spine
    }()

    static func findAll<T: Resource>(type: T.Type) -> Future<[T], NanouError> {
        return self.spine.findAll(type).map { resources, _, _ in
            return resources.map { $0 as! T }  // tailor:disable
        }.mapError(mapNanouError)
    }

    static func find<T: Resource>(query: Query<T>) -> Future<[T], NanouError> {
        return self.spine.find(query).map { resources, _, _ in
            return resources.map { $0 as! T }  // tailor:disable
        }.mapError(mapNanouError)
    }

    static func findOne<T: Resource>(id: String, ofType type: T.Type) -> Future<T, NanouError> {
        return self.spine.findOne(id, ofType: type).map { resource, _, _ in
            return resource
        }.mapError(mapNanouError)
    }

    static func findOne<T: Resource>(query: Query<T>) -> Future<T, NanouError> {
        return self.spine.findOne(query).map { resource, _, _ in
            return resource
        }.mapError(mapNanouError)
    }

    static func save<T: Resource>(resource: T) -> Future<T, NanouError> {
        return self.spine.save(resource).mapError(mapNanouError)
    }

    private static func mapNanouError(error: SpineError) -> NanouError {
        return NanouError.api(error)
    }

}
