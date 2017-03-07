//
//  AVPlayerHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 07/03/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import Foundation
import AVFoundation

extension AVQueuePlayer {
    convenience init(contentUrl: URL) {
        let introOutroUrl = Bundle.main.url(forResource: "intro-outro", withExtension: "mp4")!
        let introItem = AVPlayerItem(url: introOutroUrl)
        let outroItem = AVPlayerItem(url: introOutroUrl)
        let contentItem = AVPlayerItem(url: contentUrl)
        self.init(items: [introItem, contentItem, outroItem])
    }
}
