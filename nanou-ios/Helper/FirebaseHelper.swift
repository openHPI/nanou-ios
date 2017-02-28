//
//  FirebaseHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 28/02/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import Foundation
import Firebase


struct FirebaseHelper {
    enum FireBaseEvent: String {
        case appStart = "app_start"
        case appSuspend = "app_suspend"
        case preferenceChange = "preference_change"
        case videoFetch = "video_fetch"
        case videoSelect = "video_select"
        case videoDismiss = "video_dismiss"
        case videoPlaybackStart = "video_start"
        case videoPlaybackStop = "video_stop"
//        case videoPlaybackSeek = "video_seek"
        case videoGoBack = "video_go_back"
        case historyVideoPlaybackStart = "history_video_start"
        case historyVideoPlaybackStop = "history_video_stop"
    }

    static func logAppStart() {
        FIRAnalytics.logEvent(withName: FireBaseEvent.appStart.rawValue, parameters: [:])
    }

    static func logAppSuspend() {
        FIRAnalytics.logEvent(withName: FireBaseEvent.appSuspend.rawValue, parameters: [:])
    }

    static func logPreferenceChange(preference: Preference?, from: Float, to: Float) {
        FIRAnalytics.logEvent(withName: FireBaseEvent.preferenceChange.rawValue, parameters: [
            "preference_id": NSString(string: preference?.id ?? ""),
            "preference_name": NSString(string: preference?.name ?? ""),
            "preference_from": NSNumber(value: from),
            "preference_to": NSNumber(value: to),
        ])
    }

    static func logVideoFetch() {
        FIRAnalytics.logEvent(withName: FireBaseEvent.videoFetch.rawValue, parameters: [:])
    }

    static func logVideoSelect(video: Video?) {
        FIRAnalytics.logEvent(withName: FireBaseEvent.videoSelect.rawValue, parameters: [
            "video_id": NSString(string: video?.id ?? ""),
            "video_name": NSString(string: video?.name ?? ""),
        ])
    }

    static func logVideoDismiss(video: Video?) {
        FIRAnalytics.logEvent(withName: FireBaseEvent.videoDismiss.rawValue, parameters: [
            "video_id": NSString(string: video?.id ?? ""),
            "video_name": NSString(string: video?.name ?? ""),
        ])
    }

    static func logVideoPlaybackStart(video: Video?, at time: Double, automatic: Bool) {
        FIRAnalytics.logEvent(withName: FireBaseEvent.videoPlaybackStart.rawValue, parameters: [
            "video_id": NSString(string: video?.id ?? ""),
            "video_name": NSString(string: video?.name ?? ""),
            "video_time": NSNumber(value: time),
            "video_automatic": NSNumber(value: automatic),
        ])
    }

    static func logVideoPlaybackStop(video: Video?, at time: Double) {
        FIRAnalytics.logEvent(withName: FireBaseEvent.videoPlaybackStop.rawValue, parameters: [
            "video_id": NSString(string: video?.id ?? ""),
            "video_name": NSString(string: video?.name ?? ""),
            "video_time": NSNumber(value: time),
        ])
    }

//    static func logVideoPlaybackSeek(video: Video?, from: Double, to: Double) {
//        FIRAnalytics.logEvent(withName: FireBaseEvent.videoPlaybackSeek.rawValue, parameters: [
//            "video_id": NSString(string: video?.id ?? ""),
//            "video_name": NSString(string: video?.name ?? ""),
//            "video_from": NSNumber(value: from),
//            "video_to": NSNumber(value: to),
//        ])
//    }

    static func logVideoGoBack(video: Video?, time: Double) {
        FIRAnalytics.logEvent(withName: FireBaseEvent.videoGoBack.rawValue, parameters: [
            "video_id": NSString(string: video?.id ?? ""),
            "video_name": NSString(string: video?.name ?? ""),
            "video_time": NSNumber(value: time),
        ])
    }

    static func logHistoryVideoPlaybackStart(historyVideo: HistoryVideo?, at time: Double) {
        FIRAnalytics.logEvent(withName: FireBaseEvent.historyVideoPlaybackStart.rawValue, parameters: [
            "video_id": NSString(string: historyVideo?.id ?? ""),
            "video_name": NSString(string: historyVideo?.name ?? ""),
            "video_time": NSNumber(value: time),
        ])
    }

    static func logHistoryVideoPlaybackStop(historyVideo: HistoryVideo?, at time: Double) {
        FIRAnalytics.logEvent(withName: FireBaseEvent.historyVideoPlaybackStop.rawValue, parameters: [
            "video_id": NSString(string: historyVideo?.id ?? ""),
            "video_name": NSString(string: historyVideo?.name ?? ""),
            "video_time": NSNumber(value: time),
        ])
    }


}
