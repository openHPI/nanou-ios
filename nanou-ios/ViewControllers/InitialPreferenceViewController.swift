//
//  InitialPreferenceViewController.swift
//  nanou-ios
//
//  Created by Max Bothe on 03/01/17.
//  Copyright © 2017 Max Bothe. All rights reserved.
//

import UIKit
import SpriteKit
import SIFloatingCollection

class InitialPreferenceViewController: UIViewController {
    var delegate: LoginDelegate?

    @IBOutlet var sceneWrapperView: UIView!

    var floatingCollectionScene: BubblesScene!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true

        let skView = SKView(frame: UIScreen.main.bounds)
        skView.backgroundColor = SKColor.white
        self.sceneWrapperView.addSubview(skView)

        self.floatingCollectionScene = BubblesScene(size: skView.bounds.size)
        skView.presentScene(floatingCollectionScene)

        PreferenceHelper.syncPreferences().onSuccess { preferences in
            log.info("InitialPreferenceViewController | sync succeeded")
            for preference in preferences {
                let node = BubbleNode.instantiate(preference: preference)
                self.floatingCollectionScene.addChild(node!)
            }
            }.onFailure { error in
                log.warning("InitialPreferenceViewController | sync failed")
        }
    }

    @IBAction func commitSelection(_ sender: Any) {
        self.floatingCollectionScene.performCommitSelectionAnimation()
        self.dismiss(animated: true) {
            self.delegate?.didFinishLogin(true)
        }
    }

}
