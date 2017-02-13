//
//  UserProfileViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 04/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import UIKit

class UserProfileViewController: UITableViewController {
    static let logoutIndexPath = IndexPath(row: 0, section: 1)

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == UserProfileViewController.logoutIndexPath {
            CoreDataHelper.saveContext() // to avoid merge conflicts
            UserProfileHelper.deleteToken()
            CoreDataHelper.deleteAll(Preference.self)
            CoreDataHelper.deleteAll(Video.self)
            CoreDataHelper.deleteAll(WatchedVideo.self)
            CoreDataHelper.saveContext()

            self.performSegue(withIdentifier: "logout", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
