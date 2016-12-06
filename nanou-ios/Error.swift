//
//  Error.swift
//  nanou-ios
//
//  Created by Max Bothe on 05/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import Foundation

enum NanouError: Error {

    case coreData(Error)
    case invalidData
    case modelIncomplete
    case network(Error)
    case authenticationError

    case unknownError(Error)
    case totallyUnknownError

}
