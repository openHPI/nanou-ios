//
//  NanouPlayer.swift
//  nanou-ios
//
//  Created by Max Bothe on 07/03/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import Foundation
import AVFoundation

class NanouPlayer: AVQueuePlayer {
    var isLastItem: Bool {
        return self.currentItem == self.items().last
    }

    var progress: Double {
        if let currentItem = self.currentItem {
            let itemCount = self.items().count
            if itemCount == 1 {  // outro playing (so almost done)
                return 1.0
            } else if itemCount == 2 {  // main content playing
                if currentItem.currentTime().isValid, currentItem.duration.isValid, currentItem.duration.seconds > 0 {
                    return currentItem.currentTime().seconds / currentItem.duration.seconds
                } else {  // time invalid
                    return -1.0
                }
            } else {  // intro playing
                return 0.0
            }
        } else {  // all videos parts finished
            return 1.0
        }
    }

    convenience init(contentUrl: URL) {
        // play audio when device is muted
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)

        // add intro and outro video
        let introOutroUrl = Bundle.main.url(forResource: "intro-outro", withExtension: "mp4")!
        let introItem = AVPlayerItem(url: introOutroUrl)
        let outroItem = AVPlayerItem(url: introOutroUrl)
        let contentItem = AVPlayerItem(url: contentUrl)
        self.init(items: [introItem, contentItem, outroItem])
    }
}
