//
//  LaunchViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 23/11/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import UIKit

import Alamofire
import CocoaLumberjack
import LNRSimpleNotifications

struct LoginProvider {
    var name: String
    var url: String
}

class LaunchViewController: UICollectionViewController {
    var loginProviders: [LoginProvider]?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        self.view.layer.insertSublayer(CAGradientLayer.nanouGradientLayer(frame: self.view.bounds), at: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkUserStatus()
//        self.performSegue(withIdentifier: "open", sender: nil)
    }

    @IBAction func logout(segue: UIStoryboardSegue) {}

    func checkUserStatus() {
        Alamofire.request(Route.loginProviders).responseJSON { response in
            switch response.result {
            case .success(let data):
                if let json = data as? NSDictionary {
                    DDLogVerbose("Login Providers: \(json)")
                    if let data = json["data"] as? [String: String] {
                        let newLoginProviders = data.map { (key: String, value: String) -> LoginProvider in
                            return LoginProvider(name: key, url: value)
                        }
                        if self.loginProviders != nil {
                            self.loginProviders = newLoginProviders
                            self.collectionView?.reloadSections(IndexSet(integer: 1))
                        } else {
                            self.loginProviders = newLoginProviders
                            self.collectionView?.insertSections(IndexSet(integer: 1))
                        }
                    }
                } else {
                    DDLogError("Malformed JSON response or timeout")
                    self.showNetworkError()
                }
            case .failure(let error):
                DDLogError("Request failed with error: \(error)")
                self.showNetworkError()
            }
        }
    }

    func showNetworkError() {
        let notificationManager = LNRNotificationManager()
        notificationManager.notificationsPosition = LNRNotificationPosition.top
        notificationManager.notificationsBackgroundColor = UIColor(white: 0.25, alpha: 1.0)
        notificationManager.notificationsTitleTextColor = UIColor.white
        notificationManager.notificationsBodyTextColor = UIColor.white
        notificationManager.notificationsSeperatorColor = UIColor.clear
        notificationManager.notificationsDefaultDuration = LNRNotificationDuration.endless.rawValue
        notificationManager.showNotification(title: "No internet connection", body: "Tap to retry", onTap: { () in
            _ = notificationManager.dismissActiveNotification(completion: { () in
                DDLogInfo("Retry: check status")
                self.checkUserStatus()
            })
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sociallogin" {
            guard let confirmationVC = segue.destination as? LoginConfirmationViewController else {
                DDLogError("Wrong ViewController: Excepted LoginConfirmationViewController")
                return
            }

            guard let cell = sender as? LoginCell else {
                DDLogError("Wrong sender: Excepted LoginCell")
                return
            }

            guard let indexPath = self.collectionView?.indexPath(for: cell) else {
                DDLogError("Wrong indexPath: No indexPath for \(cell)")
                return
            }

            guard let loginProvider = self.loginProviders?[indexPath.item] else {
                DDLogError("No login provider at index \(indexPath.item)")
                return
            }

            confirmationVC.urlString = loginProvider.url
        }
    }

}


// MARK: - UICollectionViewDataSource
extension LaunchViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (self.loginProviders != nil) ? 2 : 1
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if let providers = self.loginProviders {
            return providers.count
        } else {
            DDLogWarn("Invalid login providers")
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogoCell", for: indexPath)
            cell.backgroundColor = UIColor.clear
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoginCell", for: indexPath)
        cell.backgroundColor = UIColor(white: 0.0, alpha: 0.15)
        cell.layer.cornerRadius = 2.0
        cell.layer.masksToBounds = true
        if let loginCell = cell as? LoginCell {
            loginCell.title.text = self.loginProviders?[indexPath.item].name
        }
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
fileprivate let horizontalSectionInsets: CGFloat = 20.0

extension LaunchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if self.loginProviders == nil {
            let indexPath = IndexPath(item: 0, section: section)
            let cellSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            let verticalSectionInset = (collectionView.bounds.height - cellSize.height) / 2
            return UIEdgeInsets(top: verticalSectionInset,
                                left: horizontalSectionInsets,
                                bottom: verticalSectionInset,
                                right: horizontalSectionInsets)
        }
        return UIEdgeInsets(top: 100.0, left: 20.0, bottom: 50.0, right: 20.0)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return horizontalSectionInsets
    }

}
