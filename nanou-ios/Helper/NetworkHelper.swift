//
//  NetworkHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 05/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import Foundation
import Alamofire
import BrightFutures

class NetworkHelper {
    static let headerUserPlatform = "User-Platform"
    static let headerUserPlatformValue = "iOS"

    static let httpAcceptHeader = "Accept"
    static let httpAcceptHeaderValue = "application/vnd.api+json, application/json"
    static let httpAuthHeader = "Authorization"
    static let httpAuthHeaderValuePrefix = "Token "

    class var requestHeaders: [String: String] {
        var headers = [
            NetworkHelper.httpAcceptHeader: NetworkHelper.httpAcceptHeaderValue,
            NetworkHelper.headerUserPlatform: NetworkHelper.headerUserPlatformValue,
        ]
        if UserProfileHelper.isLoggedIn {
            headers[NetworkHelper.httpAuthHeader] = NetworkHelper.httpAuthHeaderValuePrefix + UserProfileHelper.token
        }
        return headers
    }
}

// MARK: - test login
extension NetworkHelper {

    class func testLogin() -> Future<String, NanouError> {
        let promise = Promise<String, NanouError>()

        let uuid = UIDevice.current.identifierForVendor ?? UUID.init()
        let parameters: Parameters = ["vendorId": uuid]
        Alamofire.request(Route.testLogin, parameters: parameters, headers: NetworkHelper.requestHeaders).responseJSON { response in
            switch response.result {
            case .success(let data):
                guard let json = data as? NSDictionary else {
                    log.error("Request 'test-login' | malformed JSON response or timeout")
                    promise.failure(NanouError.invalidData)
                    return
                }
                log.verbose("Request 'test-login' | retrieved json: \(json)")

                guard let token = json["token"] as? String else {
                    log.error("Request 'test-login' | malformed JSON response for key 'token'")
                    promise.failure(NanouError.invalidData)
                    return
                }
                log.verbose("Request 'test-login' | retrieved authentication status: \(token)")

                promise.success(token)
            case .failure(let error):
                log.error("Request 'status' | Failed with error: \(error)")
                promise.failure(NanouError.network(error))
            }
        }

        return promise.future
    }

}

// MARK: - Status
extension NetworkHelper {

    class func status() -> Future<Bool, NanouError> {
        let promise = Promise<Bool, NanouError>()

        Alamofire.request(Route.authstatus, headers: NetworkHelper.requestHeaders).responseJSON { response in
            switch response.result {
            case .success(let data):
                guard let json = data as? NSDictionary else {
                    log.error("Request 'status' | malformed JSON response or timeout")
                    promise.failure(NanouError.invalidData)
                    return
                }
                log.verbose("Request 'status' | retrieved json: \(json)")

                guard let authStatus = json["authenticated"] as? Bool else {
                    log.error("Request 'status' | malformed JSON response")
                    promise.failure(NanouError.invalidData)
                    return
                }
                log.verbose("Request 'status' | retrieved authentication status: \(authStatus)")

                promise.success(authStatus)
            case .failure(let error):
                log.error("Request 'status' | Failed with error: \(error)")
                promise.failure(NanouError.network(error))
            }
        }

        return promise.future
    }

}

// MARK: - Login Providers
extension NetworkHelper {

    class func loginProviders() -> Future<[LoginProvider], NanouError> {
        let promise = Promise<[LoginProvider], NanouError>()

        Alamofire.request(Route.loginProviders, headers: NetworkHelper.requestHeaders).responseJSON { response in
            switch response.result {
            case .success(let data):
                guard let json = data as? NSDictionary else {
                    log.error("Request 'login providers' | malformed JSON response or timeout")
                    promise.failure(NanouError.invalidData)
                    return
                }
                log.verbose("Request 'login providers' | retrieved json: \(json)")

                guard let data = json["data"] as? [String: String] else {
                    log.error("Request 'login providers' | malformed JSON response")
                    promise.failure(NanouError.invalidData)
                    return
                }

                let providers = data.map { (name: String, url: String) -> LoginProvider in
                    return LoginProvider(name: name, url: url)
                }

                promise.success(providers)
            case .failure(let error):
                log.error("Request 'login providers' | Failed with error: \(error)")
                promise.failure(NanouError.network(error))
            }
        }

        return promise.future
    }

}
