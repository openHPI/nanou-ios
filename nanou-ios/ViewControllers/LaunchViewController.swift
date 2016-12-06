//
//  LaunchViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 23/11/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import UIKit

import Alamofire

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

        self.checkStatus()
    }

    @IBAction func logout(segue: UIStoryboardSegue) {}

    func checkStatus() {
        NetworkHelper.status().onSuccess { authenticated in
            if authenticated {
                self.performSegue(withIdentifier: "open", sender: nil)
            } else {
                self.updateLoginProviders()
            }
        }.onFailure { error in
            NotificationHelper.showNotificationFor(error) {
                self.checkStatus()
            }
        }
    }

    func updateLoginProviders() {
        NetworkHelper.loginProviders().onSuccess { providers in
            if self.loginProviders != nil {
                self.loginProviders = providers
                self.collectionView?.reloadSections(IndexSet(integer: 1))
            } else {
                self.loginProviders = providers
                self.collectionView?.insertSections(IndexSet(integer: 1))
            }
        }.onFailure { error in
            NotificationHelper.showNotificationFor(error) {
                self.updateLoginProviders()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sociallogin" {
            guard let confirmationVC = segue.destination as? LoginConfirmationViewController else {
                log.error("Wrong ViewController: Excepted LoginConfirmationViewController")
                return
            }

            guard let cell = sender as? LoginCell else {
                log.error("Wrong sender: Excepted LoginCell")
                return
            }

            guard let indexPath = self.collectionView?.indexPath(for: cell) else {
                log.error("Wrong indexPath: No indexPath for \(cell)")
                return
            }

            guard let loginProvider = self.loginProviders?[indexPath.item] else {
                log.error("No login provider at index \(indexPath.item)")
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
            log.warning("Invalid login providers")
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
