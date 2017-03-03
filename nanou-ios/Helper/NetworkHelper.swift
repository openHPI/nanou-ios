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

    class func testLogin() -> Future<Bool, NanouError> {
        let promise = Promise<Bool, NanouError>()

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

                guard let authenticated = json["authenticated"] as? Bool else {
                    log.error("Login | missing authentication value")
                    return
                }


                if authenticated {
                    UserProfileHelper.storeToken(token)
                    if let prefInitialized = json["preferencesInitialized"] as? Bool {
                        promise.success(prefInitialized)
                    } else {
                        promise.failure(NanouError.totallyUnknownError)
                    }
                } else {
                    promise.failure(NanouError.totallyUnknownError)
                }

            case .failure(let error):
                log.error("Request 'test-login' | Failed with error: \(error)")
                promise.failure(NanouError.network(error))
            }
        }

        return promise.future
    }

    class func combineAccounts() {
        let uuid = UIDevice.current.identifierForVendor ?? UUID.init()
        let parameters: Parameters = ["vendorId": uuid]
        Alamofire.request(Route.combineAccounts, parameters: parameters, headers: NetworkHelper.requestHeaders).responseJSON { response in
            switch response.result {
            case .success(_):
                log.verbose("Request 'combine accounts' | success")
            case .failure(_):
                log.warning("Request 'combine accounts' | failed")
            }
        }
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

                guard let data = json["data"] as? [[String]] else {
                    log.error("Request 'login providers' | malformed JSON response")
                    promise.failure(NanouError.invalidData)
                    return
                }

                let providers = data.map { (d: [String]) -> LoginProvider in
                    return LoginProvider(name: d[0], url: d[1])
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

// MARK: - Survey
extension NetworkHelper {

    class func latestSurvey() -> Future<Survey?, NanouError> {
        let promise = Promise<Survey?, NanouError>()

        Alamofire.request(Route.surveyLatest, headers: NetworkHelper.requestHeaders).responseJSON { response in
            switch response.result {
            case .success(let data):
                guard let json = data as? NSDictionary else {
                    log.error("Request 'latest survey' | malformed JSON response or timeout")
                    promise.failure(NanouError.invalidData)
                    return
                }
                log.verbose("Request 'latest survey' | retrieved json: \(json)")

                guard let d = json["data"] as? [String: Any] else {
                    log.error("Request 'latest survey' | malformed JSON response")
                    promise.failure(NanouError.invalidData)
                    return
                }

                if
                    let fetchedId = d["id"] as? String,
                    let attributes = d["attributes"] as? [String: String],
                    let urlString = attributes["link"],
                    let fetchedUrl = URL(string: urlString) {
                    promise.success(Survey(id: fetchedId, url: fetchedUrl))
                } else {
                    promise.success(nil)
                }
            case .failure(let error):
                log.error("Request 'latest survey' | Failed with error: \(error)")
                promise.failure(NanouError.network(error))
            }
        }

        return promise.future
    }

    class func completeSurvey(withId surveyId: String) -> Future<Void, NanouError> {
        let promise = Promise<Void, NanouError>()

        Alamofire.request(Route.surveyComplete(withId: surveyId), method: .post, headers: NetworkHelper.requestHeaders).responseJSON { response in
            switch response.result {
            case .success(_):
                promise.success()
            case .failure(let error):
                log.error("Request 'complete survey' | Failed with error: \(error)")
                promise.failure(NanouError.network(error))
            }
        }

        return promise.future
    }

}
