//
//  Video.swift
//  nanou-ios
//
//  Created by Max Bothe on 24/01/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import CoreData
import Foundation
import Spine

class Video: BaseModel {
}


class VideoSpine: BaseModelSpine<Video> {

    var name: String?
    var downloadUrl: URL?
    var streamUrl: URL?

    override class var resourceType: ResourceType {
        return "videos"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "name": Attribute(),
            "url": URLAttribute().serializeAs("url"),
            "streamUrl": URLAttribute().serializeAs("stream_url"),
        ])
    }
}
