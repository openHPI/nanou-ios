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

    var providerText: String? {
        if let providerName = self.providerName {
            return "Content of \(providerName)"
        }
        return nil
    }

}


class VideoSpine: BaseModelSpine<Video> {

    var name: String?
    var downloadUrl: URL?
    var streamUrl: URL?
    var imageUrl: URL?
    var providerName: String?
    var tags: String?

    override class var resourceType: ResourceType {
        return "videos"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "name": Attribute(),
            "downloadUrl": URLAttribute().serializeAs("url"),
            "streamUrl": URLAttribute().serializeAs("stream_url"),
            "imageUrl": URLAttribute().serializeAs("image_url"),
            "providerName": Attribute().serializeAs("provider_name"),
            "tags": Attribute(),
        ])
    }
}
