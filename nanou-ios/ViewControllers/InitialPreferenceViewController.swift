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

    var skView: SKView!
    var floatingCollectionScene: BubblesScene!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true

        self.skView = SKView(frame: UIScreen.main.bounds)
        self.skView.backgroundColor = SKColor.white
        self.sceneWrapperView.addSubview(self.skView)

        self.floatingCollectionScene = BubblesScene(size: skView.bounds.size)
        self.skView.presentScene(floatingCollectionScene)

        PreferenceHelper.sync().onSuccess { preferences in
            log.info("InitialPreferenceViewController | sync succeeded")
            for preference in preferences {
                let node = BubbleNode.instantiate(preference: preference)
                self.floatingCollectionScene.addChild(node!)
            }
        }.onFailure { error in
            log.warning("InitialPreferenceViewController | sync failed")
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.skView.frame = self.view.bounds
        self.floatingCollectionScene.size = self.view.bounds.size
    }

    @IBAction func commitSelection(_ sender: Any) {
        self.floatingCollectionScene.performCommitSelectionAnimation()
        let nodes = self.floatingCollectionScene.indexesOfSelectedNodes().map { index in
            return self.floatingCollectionScene.floatingNodeAtIndex(index)
        }
        for case let node as BubbleNode in nodes {
            node.preference?.weight = 1.0
        }
        CoreDataHelper.saveContext()
        self.performSegue(withIdentifier: "open", sender: self)
    }

}
