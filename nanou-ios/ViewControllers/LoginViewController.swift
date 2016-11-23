//
//  LoginViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 23/11/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import UIKit
import Alamofire
import CocoaLumberjack


struct LoginProvider {
    var name: String
    var url: String
}

class LoginViewController: UICollectionViewController {
    var loginProviders: [LoginProvider]?

    override func viewDidLoad() {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.bounds
        let orange = UIColor(red: 241.0/255.0, green: 133.0/255.0, blue: 63.0/255.0, alpha: 1.0)
        let pink = UIColor(red: 233.0/255.0, green: 68.0/255.0, blue: 117.0/255.0, alpha: 1.0)
        gradient.colors = [orange.cgColor, pink.cgColor]
        self.view.layer.insertSublayer(gradient, at: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Alamofire.request(Route.status).responseJSON { response in
            if let json = response.result.value as? NSDictionary {
                DDLogInfo("JSON: \(json)")
                if let data = json["data"] as? [String: String] {
                    self.loginProviders = data.map { (key: String, value: String) -> LoginProvider in
                        return LoginProvider(name: key, url: value)
                    }
                    self.collectionView?.insertSections(IndexSet(integer: 1))
                }
            }
        }
    }

}


// MARK: - UICollectionViewDataSource
extension LoginViewController {

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

fileprivate let horizontalSectionInsets: CGFloat = 20.0

extension LoginViewController: UICollectionViewDelegateFlowLayout {

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
