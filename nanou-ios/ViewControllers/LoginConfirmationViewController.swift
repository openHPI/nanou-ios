//
//  LoginConfirmationViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 24/11/16.
//  Copyright © 2016 Max Bothe. All rights reserved.
//

import UIKit
import CocoaLumberjack

class LoginConfirmationViewController: UIViewController, UIToolbarDelegate, UIWebViewDelegate {
    @IBOutlet var webview: UIWebView!

    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        URLSession.shared.reset {
            if let urlString = self.urlString {
                if let url = URL(string: Route.base + urlString) {
                    self.webview.loadRequest(URLRequest(url: url))
                } else {
                    DDLogError("Show LoginConfirmationViewController without valid url")
                }
            } else {
                DDLogError("Show LoginConfirmationViewController without url")
            }
        }
    }

    @IBAction func cancelConfirmation(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        if let webViewContent = webview.stringByEvaluatingJavaScript(from: "document.body.innerText") {
            if let status = convertToDictionary(text: webViewContent) {
                guard let authenticated = status["authenticated"] as? Bool else {
                    return
                }

                guard let token = status["token"] as? String else {
                    return
                }

                if authenticated {
                    // TODO: save token
                    self.performSegue(withIdentifier: "open", sender: nil)
                }
            }
        }
    }

}
