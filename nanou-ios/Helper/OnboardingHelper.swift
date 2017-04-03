//
//  OnboardingHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 03/04/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import UIKit
import Onboard


class NanouOnboardingViewController: OnboardingViewController {

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}

class NanouOnboardingContentViewController: OnboardingContentViewController {

    convenience init(body: String, image: UIImage, buttonText: String, action: (() -> ())?) {
        self.init(title: nil, body: body, image: image, buttonText: buttonText, action: action)
        self.bodyLabel.textColor = UIColor.black
        self.bodyLabel.font = UIFont.systemFont(ofSize: 17.0)
        self.actionButton.setTitleColor(UIColor.black, for: .normal)
        self.actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)

        self.underIconPadding = -10.0
    }
}


struct OnboardingHelper {
    private static let onboardingShownBefore = "nanou-onboarding-shown-1.0.0"
    private static var onboardingViewController: UIViewController?

    static var shouldShowOnboarding: Bool {
        return !UserDefaults.standard.bool(forKey: OnboardingHelper.onboardingShownBefore)
    }

    static func showOnboarding(in viewController: UIViewController) {
        let page1 = NanouOnboardingContentViewController(body: "Interessen wählen", image: UIImage(named: "OnboardingPage1")!, buttonText: "Weiter", action: nil)
        page1.movesToNextViewController = true

        let page2 = NanouOnboardingContentViewController(body: "Ein Video wird vorgeschlagen.", image: UIImage(named: "OnboardingPage2")!, buttonText: "Weiter", action: nil)
        page2.movesToNextViewController = true

        let page3 = NanouOnboardingContentViewController(body: "Video auswählen, wenn es gefällt", image: UIImage(named: "OnboardingPage3")!, buttonText: "Weiter", action: nil)
        page3.movesToNextViewController = true

        let page4 = NanouOnboardingContentViewController(body: "Video ansehen und bewerten. Das verbessert die nächsten Vorschläge.", image: UIImage(named: "OnboardingPage5")!, buttonText: "Weiter", action: nil)
        page4.movesToNextViewController = true

        let page5 = NanouOnboardingContentViewController(body: "Ein neues Video wird vorgeschlagen.", image: UIImage(named: "OnboardingPage2")!, buttonText: "Weiter", action: nil)
        page5.movesToNextViewController = true

        let page6 = NanouOnboardingContentViewController(body: "Falls das Video nicht gefällt, einfach wegklicken. Es wird später wieder vorgeschlagen.", image: UIImage(named: "OnboardingPage4")!, buttonText: "Fertig", action: {
            OnboardingHelper.onboardingViewController?.dismiss(animated: true, completion: nil)
        })

        let backgroundImage = UIImage.onboardingGradient(frame: viewController.view.frame)!
        let onboardingViewController = NanouOnboardingViewController(backgroundImage: backgroundImage, contents: [page1, page2, page3, page4, page5, page6])!
        onboardingViewController.shouldFadeTransitions = true
        onboardingViewController.fadePageControlOnLastPage = true
        onboardingViewController.fadeSkipButtonOnLastPage = true
        onboardingViewController.shouldMaskBackground = false

        onboardingViewController.view.backgroundColor = UIColor.white
        onboardingViewController.pageControl.currentPageIndicatorTintColor = UIColor.darkGray
        onboardingViewController.pageControl.pageIndicatorTintColor = UIColor.lightGray

        OnboardingHelper.onboardingViewController = onboardingViewController
        viewController.present(onboardingViewController, animated: true, completion: {
            UserDefaults.standard.set(true, forKey: OnboardingHelper.onboardingShownBefore)
            UserDefaults.standard.synchronize()
        })
    }

}
