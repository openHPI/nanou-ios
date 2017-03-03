//
//  Routes.swift
//  nanou-ios
//
//  Created by Max Bothe on 23/11/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import Foundation

struct Route {
    #if DEBUG
    static let base = "http://localhost:8000/"
    #else
    static let base = "https://hpi.de/meinel/nanou/"
    #endif

    static let api = base + "api/"
    static let testLogin = api + "test-login/"
    static let combineAccounts = api + "combine/"
    static let authstatus = api + "auth-status/"
    static let loginProviders = api + "login-providers/"
    static let surveyLatest = api + "surveys/latest/"

    static func surveyComplete(withId id: String) -> String {
        return self.api + "surveys/\(id)/complete/"
    }

}
