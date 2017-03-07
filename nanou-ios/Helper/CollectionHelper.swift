//
//  CollectionHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 07/03/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {

    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
