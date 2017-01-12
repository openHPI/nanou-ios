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
    var gradientLayer: CALayer?

    override func viewDidLoad() {
        self.gradientLayer = CAGradientLayer.nanouGradientLayer(frame: self.view.bounds, reverse: true)
        self.view.layer.insertSublayer(self.gradientLayer!, at: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateLoginProviders()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.gradientLayer?.frame = self.view.bounds
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
