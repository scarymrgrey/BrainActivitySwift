//
//  AppDelegate.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 26/05/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper
import Fabric
import Crashlytics
let color_range_selected = UIColor(red: 242.0/255.0, green: 101.0/255.0 , blue: 34.0/255.0, alpha: 1)
var userDefaults = NSUserDefaults.standardUserDefaults()
let realm = try! Realm()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        userDefaults.removeObjectForKey(UserDefaultsKeys.currentSessionId)
        Fabric.with([Crashlytics.self()])
        logUser()
        return true
    }
    func logUser(){
        let userName = NSUserName()
        Crashlytics.sharedInstance().setUserIdentifier(userName)
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

