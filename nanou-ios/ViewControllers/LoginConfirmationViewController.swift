//
//  LoginConfirmationViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 24/11/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import UIKit

class LoginConfirmationViewController: UIViewController, UIWebViewDelegate {
    var delegate: LoginDelegate?

    @IBOutlet var webview: UIWebView!

    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        URLSession.shared.reset {
            if let urlString = self.urlString {
                if let url = URL(string: urlString) {
                    self.webview.loadRequest(URLRequest(url: url))
                } else {
                    log.error("Show LoginConfirmationViewController without valid url")
                }
            } else {
                log.error("Show LoginConfirmationViewController without url")
            }
        }
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        if let webViewContent = webview.stringByEvaluatingJavaScript(from: "document.body.innerText") {
            if let status = convertToDictionary(text: webViewContent) {
                guard let authenticated = status["authenticated"] as? Bool else {
                    log.error("Login | missing authentication value")
                    return
                }

                guard let token = status["token"] as? String else {
                    log.error("Login | missing token")
                    return
                }

                if authenticated {
                    UserProfileHelper.storeToken(token)
                    if let prefInitialized = status["preferencesInitialized"] as? Bool, prefInitialized == true {
                        self.dismiss(animated: true) {
                            self.delegate?.didFinishLogin(true)
                        }
                    } else {
                        self.performSegue(withIdentifier: "setupPreferences", sender: nil)
                    }
                } else {
                    log.error("Login | user could not authenticate")
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setupPreferences" {
            let prefVc = segue.destination as! InitialPreferenceViewController
            prefVc.delegate = self.delegate
        }
    }

}
