//
//  LoginProviderViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 11/01/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import UIKit

struct LoginProvider {
    var name: String
    var url: String
}

class LoginProviderViewController: UICollectionViewController {
    var delegate: LoginDelegate?
    var loginProviders: [LoginProvider]?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateLoginProviders()
    }

    func updateLoginProviders() {
        NetworkHelper.loginProviders().onSuccess { providers in
            DispatchQueue.main.async {
                self.loginProviders = providers
                self.collectionView?.reloadSections(IndexSet(integer: 0))
            }
        }.onFailure { error in
            NotificationHelper.showNotificationFor(error) {
                self.updateLoginProviders()
            }
        }
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
            confirmationVC.delegate = self.delegate
        }
    }

}

// MARK: - UICollectionViewDataSource
extension LoginProviderViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.loginProviders?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoginCell", for: indexPath)
        let gradientLayer = CAGradientLayer.nanouGradientLayer(frame: cell.bounds, reverse: true)
        cell.layer.insertSublayer(gradientLayer, at: 0)
        cell.layer.cornerRadius = 2.0
        cell.layer.masksToBounds = true
        if let loginCell = cell as? LoginCell {
            if let loginProviderName = self.loginProviders?[indexPath.item].name {
                switch loginProviderName {
                case "openHPI":
                    loginCell.imageView.image = UIImage(named: "openhpi-logo")
                case "google":
                    loginCell.imageView.image = UIImage(named: "google-logo")
                case "facebook":
                    loginCell.imageView.image = UIImage(named: "facebook-logo")
                default:
                    loginCell.imageView.show(placeholder: loginProviderName)
                }
            } else {
                loginCell.imageView.image = nil
            }
        }
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
fileprivate let cellSize: CGSize = CGSize(width: 168, height: 68)

extension LoginProviderViewController: UICollectionViewDelegateFlowLayout {

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
        remainingHeight -= cellSize.height * CGFloat(loginProvidersCount) // cells
        remainingHeight -= self.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: 1) * CGFloat(min(loginProvidersCount - 1, 0)) // cell spacings
        let horizontalSectionInset = (collectionView.bounds.width - cellSize.width) / 2
        let verticalSectionInset = remainingHeight / 2
        return UIEdgeInsets(top: verticalSectionInset,
                            left: horizontalSectionInset,
                            bottom: verticalSectionInset,
                            right: horizontalSectionInset)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }

}
