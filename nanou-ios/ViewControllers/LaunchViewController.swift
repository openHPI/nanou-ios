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

        URLSession.shared.reset {
            self.checkStatus()
        }
    }

    @IBAction func logout(segue: UIStoryboardSegue) {
    }

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
            DispatchQueue.main.async {
                if self.loginProviders != nil {
                    self.loginProviders = providers
                    self.collectionView?.reloadSections(IndexSet(integer: 1))
                } else {
                    self.loginProviders = providers
                    self.collectionView?.insertSections(IndexSet(integer: 1))
                }
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
fileprivate let cellSize: CGSize = CGSize(width: 150, height: 50)

extension LaunchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let loginProvidersCount = self.loginProviders?.count ?? 0
        var remainingHeight = collectionView.bounds.height
        remainingHeight -= cellSize.height * CGFloat(loginProvidersCount + 1) // cells
        remainingHeight -= self.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: 1) * CGFloat(loginProvidersCount) // cell spacings
        if loginProvidersCount > 0 {
            remainingHeight -= 150.0
        }
        let horizontalSectionInset = (collectionView.bounds.width - cellSize.width) / 2
        if section == 0 {
            let topSectionInset = remainingHeight / 2
            let bottomSectionInset = loginProvidersCount > 0 ? 150.0 : topSectionInset
            return UIEdgeInsets(top: topSectionInset,
                                left: horizontalSectionInset,
                                bottom: bottomSectionInset,
                                right: horizontalSectionInset)
        }

        return UIEdgeInsets(top: 0, left: horizontalSectionInset, bottom: remainingHeight / 2, right: horizontalSectionInset)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }

}
