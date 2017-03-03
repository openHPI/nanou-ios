//
//  SurveyHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 01/03/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import Foundation
import SafariServices

struct Survey {
    var id: String
    var url: URL
}


struct SurveyHelper {
    private let surveyAskForLatestSurveyBefore = "nanou-asked-before"
    private let surveyURLKey = "nanou-survey-url"
    private let surveyIdKey = "nanou-survey-id"

    static let standard = SurveyHelper()


    var askedForLatestBefore: Bool {
        return UserDefaults.standard.bool(forKey: self.surveyAskForLatestSurveyBefore)
    }

    func setAsked() {
        UserDefaults.standard.set(true, forKey: self.surveyAskForLatestSurveyBefore)
    }

    var latestSurveyURL: URL? {
        return UserDefaults.standard.url(forKey: self.surveyURLKey)
    }

    private var latestSurveyId: String? {
        return UserDefaults.standard.string(forKey: self.surveyIdKey)
    }

    func reset() {
        UserDefaults.standard.set(nil, forKey: self.surveyURLKey)
        UserDefaults.standard.set(nil, forKey: self.surveyIdKey)
        UserDefaults.standard.set(false, forKey: self.surveyAskForLatestSurveyBefore)
        UserDefaults.standard.synchronize()
    }

    func fetchLatestSurvey(_ completion: @escaping (Survey?) -> ()) {
        NetworkHelper.latestSurvey().onSuccess { survey in
            if let survey = survey {
                let currentSurveyURL = UserDefaults.standard.url(forKey: self.surveyURLKey)
                if currentSurveyURL == survey.url {
                    completion(nil)
                } else {
                    UserDefaults.standard.set(survey.url, forKey: self.surveyURLKey)
                    UserDefaults.standard.set(survey.id, forKey: self.surveyIdKey)
                    UserDefaults.standard.set(false, forKey: self.surveyAskForLatestSurveyBefore)
                    UserDefaults.standard.synchronize()
                    completion(survey)
                }
            } else {
                UserDefaults.standard.set(nil, forKey: self.surveyURLKey)
                UserDefaults.standard.set(nil, forKey: self.surveyIdKey)
                UserDefaults.standard.synchronize()
                completion(nil)
            }
        }.onFailure { error in
            log.error("SurveyHelper | error while fetching survey | \(error)")
        }
    }

    func showSurvey(with url: URL, on viewController: UIViewController) {
        if let surveyId = self.latestSurveyId {
            self.setAsked()

            let separater = (url.query != nil) ? "&" : "?"
            let uuid = UIDevice.current.identifierForVendor ?? UUID.init()
            let vendorParam = "vendor_id=\(uuid)"
            let urlString = "\(url.absoluteString)\(separater)\(vendorParam)"
            let urlWithVendor = URL(string: urlString)!
            let safariViewController = SFSafariViewController(url: urlWithVendor)
            viewController.present(safariViewController, animated: true) {
                NetworkHelper.completeSurvey(withId: surveyId).onSuccess(callback: {

                }).onFailure(callback: { error in
                    log.error("SurveyHelper | error while completing survey | \(error)")
                })
            }
        } else {
            log.error("SurveyHelper | unable to find surveyId")
        }
    }

}
