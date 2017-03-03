//
//  UserProfileViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 04/12/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import UIKit

struct UserProfileConfigItem {
    var reuseIdentifier: String
    var header: String?
    var footer: String?

    init(reuseIdentifier: String, header: String?, footer: String?) {
        self.reuseIdentifier = reuseIdentifier
        self.header = header
        self.footer = footer
    }

    init(reuseIdentifier: String) {
        self.init(reuseIdentifier: reuseIdentifier, header: nil, footer: nil)
    }

}

class UserProfileViewController: UITableViewController {
    static let surveyIndexPath = IndexPath(row: 0, section: 1)
    static let logoutIndexPath = IndexPath(row: 0, section: 2)

    static let config = [
        UserProfileConfigItem(reuseIdentifier: "preferencesCell"),
        UserProfileConfigItem(reuseIdentifier: "surveyCell", header: "Verbesserung", footer: "Die App ist noch ein Prototyp. Um zukünftig eine bestmögliche Nutzung bereitstellen zu können,  sammeln wir Daten über das Nutzungsverhalten in der App. "),
        UserProfileConfigItem(reuseIdentifier: "logoutCell"),
    ]

}


// MARK: - UITableViewDataSource
extension UserProfileViewController {

    override func numberOfSections(in: UITableView) -> Int {
        return UserProfileViewController.config.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return SurveyHelper.standard.latestSurveyURL != nil ? 1 : 0
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = UserProfileViewController.config[indexPath.section].reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return UserProfileViewController.config[section].header
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return UserProfileViewController.config[section].footer
    }

}

// MARK: - UITableViewDelegate
extension UserProfileViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == UserProfileViewController.surveyIndexPath {
            if let url = SurveyHelper.standard.latestSurveyURL {
                SurveyHelper.standard.showSurvey(with: url, on: self)
            }
        } else if indexPath == UserProfileViewController.logoutIndexPath {
            CoreDataHelper.saveContext() // to avoid merge conflicts
            UserProfileHelper.deleteToken()
            CoreDataHelper.deleteAll(Preference.self)
            CoreDataHelper.deleteAll(Video.self)
            CoreDataHelper.deleteAll(WatchedVideo.self)
            CoreDataHelper.deleteAll(HistoryVideo.self)
            CoreDataHelper.saveContext()

            SurveyHelper.standard.reset()

            self.performSegue(withIdentifier: "logout", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
