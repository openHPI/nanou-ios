//
//  WatchedVideo.swift
//  nanou-ios
//
//  Created by Max Bothe on 31/01/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import CoreData
import Foundation
import Spine

class WatchedVideo: BaseModel {

    func resource() -> WatchedVideoSpine {
        let video = WatchedVideoSpine()
        video.videoId = self.videoId
        video.date = self.date
        video.progress = NSNumber(value: self.progress)
        video.rating = NSNumber(value: self.rating)
        return video
    }

    class func newEntity(forVideoId videoId: String?, withDate date: NSDate, progress: Double, rating: Double) -> WatchedVideo {
        let entity = WatchedVideo(context: CoreDataHelper.context)
        entity.videoId = videoId
        entity.date = date
        entity.progress = progress
        entity.rating = rating
        return entity
    }

}


class WatchedVideoSpine: BaseModelSpine<WatchedVideo> {

    var videoId: String?
    var date: NSDate?
    var progress: NSNumber?
    var rating: NSNumber?

    override class var resourceType: ResourceType {
        return "watches"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "videoId": Attribute().serializeAs("video_id"),
            "date": DateAttribute(),
            "progress": Attribute(),
            "rating": Attribute(),
        ])
    }
}
