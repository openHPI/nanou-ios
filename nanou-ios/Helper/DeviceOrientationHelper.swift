//
//  DeviceOrientationHelper.swift
//  nanou-ios
//
//  Created by Max Bothe on 20/03/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return visibleViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }

    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return visibleViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
    }

    open override var shouldAutorotate: Bool {
        return visibleViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
}

extension UITabBarController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return selectedViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }

    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return selectedViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
    }

    open override var shouldAutorotate: Bool {
        return selectedViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
}
