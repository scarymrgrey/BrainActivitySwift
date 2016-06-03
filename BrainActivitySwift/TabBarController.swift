//
//  TabBarController.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 02/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit

class TabBarController:  UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        self.delegate = self
    }
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    
    }
    
    // UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
       print(String(viewController))
        //if viewController is ProfileVC {
            //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("NewSessionContentVCId")
            //self.performSegueWithIdentifier("ModalyAddNewSession", sender: nil)
            viewController.performSegueWithIdentifier("showAddNewSession", sender: nil)
           // viewController.performSegueWithIdentifier("showAddNewSession", sender: nil)
        //}
    }
}
