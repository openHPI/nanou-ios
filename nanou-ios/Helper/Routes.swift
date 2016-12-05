//
//  Routes.swift
//  nanou-ios
//
//  Created by Max Bothe on 23/11/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import Foundation

struct Route {
    static let base = "http://localhost:8000"
    static let status = base + "/social/status/"
    static let loginProviders = base + "/social/login-providers/"
    static let api = base + "/api"
}
