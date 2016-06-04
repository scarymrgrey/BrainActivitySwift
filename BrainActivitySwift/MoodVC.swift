//
//  MoodVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 03/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit

class MoodVC: UIViewController ,ProfilePages {
var pageIndex: Int! = 2
    override func viewWillAppear(animated: Bool) {
        let rootTabBar = self.tabBarController as! TabBarController
        rootTabBar.completedScene = .NewSession
    }
}
