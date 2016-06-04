
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
    var itemTag : Int!
    override func viewDidLoad() {
        self.delegate = self
        self.tabBar.items![2].image = UIImage(named: "Add2")
        //self.tabBar.items![2].selectedImage = UIImage(named: "playbutton")
    }
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        itemTag = item.tag
        
    }
    
    // MARK: - UITabBarControllerDelegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if (itemTag == 2){
            if completedScene == .Profile {
                viewController.performSegueWithIdentifier("showAddNewSession", sender: nil)
            }else if completedScene == .NewSession{
                viewController.performSegueWithIdentifier("showCurrentSession", sender: nil)
            }else if completedScene == .CurrentSession{
                viewController.performSegueWithIdentifier("showCurrentSession", sender: nil)
            }
        }
       
    }
}
