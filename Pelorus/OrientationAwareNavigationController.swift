//
//  OrientationAwareNavigationController.swift
//  Pelorus
//
//  Created by Will Charczuk on 12/29/24.
//  Copyright © 2024 Will Charczuk. All rights reserved.
//

import UIKit

class OrientationAwareNavigationController: UINavigationController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .all
    }

    override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? true
    }
}
