//
//  HistoryVideo.swift
//  nanou-ios
//
//  Created by Max Bothe on 14/02/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import CoreData
import Foundation
import Spine

class HistoryVideo: BaseModel {
}


class HistoryVideoSpine: BaseModelSpine<HistoryVideo> {

    var name: String?
    var date: NSDate?
    var progress: NSNumber?
    var streamUrl: URL?
    var imageUrl: URL?
    var providerName: String?
    var tags: String?

    override class var resourceType: ResourceType {
        return "history"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "name": Attribute(),
            "date": DateAttribute(),
            "progress": Attribute(),
            "streamUrl": URLAttribute().serializeAs("stream_url"),
            "imageUrl": URLAttribute().serializeAs("image_url"),
            "providerName": Attribute().serializeAs("provider_name"),
            "tags": Attribute(),
        ])
    }
}