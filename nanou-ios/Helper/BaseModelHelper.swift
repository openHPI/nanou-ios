//
//  BaseModelHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 02/02/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import Foundation
import BrightFutures

protocol BaseModelHelper {
    associatedtype Base: BaseModel

    static func sync() -> Future<[Base], NanouError>
}
