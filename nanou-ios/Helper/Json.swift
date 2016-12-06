//
//  Json.swift
//  nanou-ios
//
//  Created by Max Bothe on 04/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import Foundation

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            log.info("Unable to serialize String to Json: \(text)")
        }
    }
    return nil
}
