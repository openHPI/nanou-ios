//
//  NotificationHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 06/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import Foundation
import LNRSimpleNotifications

public typealias NotificationHelperCompletionBlock = (Void) -> Void

class NotificationHelper {

    class func showNotificationFor(_ error: NanouError, completion: NotificationHelperCompletionBlock? = nil) {
        let bodyText = (completion != nil) ? "Tippe für einen neuen Versuch" : ""
        switch error {
        case .network:
            self.showDarkNotificaiton(title: "Keine Internetverbindung", body: bodyText, completion: completion)
        default:
            self.showDarkNotificaiton(title: "Etwas ist schief gelaufen", body: bodyText, completion: completion)
        }
    }

    class func showDarkNotificaiton(title: String, body: String, completion: NotificationHelperCompletionBlock?) {
        let notificationManager = LNRNotificationManager()
        notificationManager.notificationsPosition = LNRNotificationPosition.top
        notificationManager.notificationsBackgroundColor = UIColor(white: 0.25, alpha: 1.0)
        notificationManager.notificationsTitleTextColor = UIColor.white
        notificationManager.notificationsBodyTextColor = UIColor.white
        notificationManager.notificationsSeperatorColor = UIColor.clear
        notificationManager.notificationsDefaultDuration = LNRNotificationDuration.endless.rawValue
        notificationManager.showNotification(title: title, body: body, onTap: {
            _ = notificationManager.dismissActiveNotification(completion: completion)
        })
    }

}
