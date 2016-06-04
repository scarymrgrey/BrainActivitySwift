//
//  TabBarController.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 02/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit

class TabBarController:  UITabBarController, UITabBarControllerDelegate {
    enum Scenes {
        case Profile
        case NewSession
        case CurrentSession
        case Sessions
        case SessionResults
    }
    var completedScene = Scenes.Profile
    override func viewDidLoad() {
        self.delegate = self
        for item in self.tabBar.items!{
            print(item)
        }
    }
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        
    }
    
    // UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        if completedScene == .Profile {
            let img = UIImage(named: "playbutton")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            self.tabBarItem.image = img
            viewController.performSegueWithIdentifier("showAddNewSession", sender: nil)
        }else if completedScene == .NewSession{
            viewController.performSegueWithIdentifier("showCurrentSession", sender: nil)
        }else if completedScene == .CurrentSession{
            viewController.performSegueWithIdentifier("showCurrentSession", sender: nil)
        }
    }
}
