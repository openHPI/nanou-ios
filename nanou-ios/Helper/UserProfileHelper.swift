//
//  UserProfileHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 05/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import Foundation


class UserProfileHelper {
    static let tokenKey = "nanou-user-token"
    static let defaults = UserDefaults.standard

    class var isLoggedIn: Bool {
        return !self.token.isEmpty
    }

    class var token: String {
        return defaults.string(forKey: UserProfileHelper.tokenKey) ?? ""
    }

    class func storeToken(_ token: String) {
        defaults.set(token, forKey: UserProfileHelper.tokenKey)
        defaults.synchronize()
    }

    class func deleteToken() {
        defaults.removeObject(forKey: UserProfileHelper.tokenKey)
        defaults.synchronize()
    }

}
