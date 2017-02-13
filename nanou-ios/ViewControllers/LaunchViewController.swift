//
//  LaunchViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 23/11/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import UIKit


class LaunchViewController: UIViewController {

    @IBOutlet var buttonView: UIStackView!
    var gradientLayer: CALayer?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        self.gradientLayer = CAGradientLayer.nanouGradientLayer(frame: self.view.bounds)
        self.view.layer.insertSublayer(self.gradientLayer!, at: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.buttonView.alpha = 0.0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        unowned let unownedSelf = self
        let deadlineTime = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            unownedSelf.checkStatus()
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.buttonView.alpha = 0.0
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.gradientLayer?.frame = self.view.bounds
    }

    @IBAction func logout(segue: UIStoryboardSegue) {
    }

    func checkStatus() {
        // TODO: Improve check -> if token valid or has offline video content
        if UserProfileHelper.isLoggedIn {
            self.performSegue(withIdentifier: "open", sender: self)
        } else {
            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                            self.buttonView.alpha = 1.0
            }, completion: nil)
        }
    }

    @IBAction func testLogin(_ sender: Any) {
        NetworkHelper.testLogin().onSuccess { preferencesInitialized in
            let segueName = preferencesInitialized ? "open" : "setupPreferences"
            self.performSegue(withIdentifier: segueName, sender: self)
        }.onFailure { error in
            NotificationHelper.showNotificationFor(error)
        }
    }

    @IBAction func login(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let nvc = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = nvc.topViewController as! LoginProviderViewController
        vc.delegate = self

        self.present(nvc, animated: true, completion: nil)
    }

}

extension LaunchViewController: LoginDelegate {

    func didFinishLogin(_ success: Bool, preferencesInitialized: Bool) {
        if success {
            unowned let unownedSelf = self
            let deadlineTime = DispatchTime.now() + .milliseconds(500)
            let segueName = preferencesInitialized ? "open" : "setupPreferences"
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                unownedSelf.performSegue(withIdentifier: segueName, sender: unownedSelf)
            })
        }
    }

}
