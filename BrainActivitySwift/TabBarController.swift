                            
                            //
                            //  TabBarController.swift
                            //  BrainActivitySwift
                            //
                            //  Created by Victor Gelmutdinov on 02/06/16.
                            //  Copyright © 2016 Kirill Polunin. All rights reserved.
                            //
                            
                            import UIKit
                            import Lock
                            let binaryFileHelper = BinaryFileHelper()
                            
                            class TabBarController:  UITabBarController, UITabBarControllerDelegate {
                                enum Scenes {
                                    case Profile
                                    case NewSession
                                    case CurrentSession
                                    case Sessions
                                    case SessionResults
                                }
                                var IDToken : String!
                                var AccessToken : String!
                                var A0Controller :  A0LockViewController!
                                var completedScene = Scenes.Profile
                                var itemTag : Int!
                                var selectedActivityIndex : Int!
                                override func viewDidLoad() {
                                    userDefaults.setInteger(0, forKey: UserDefaultsKeys.currentTab)
                                    let customTheme = A0Theme()
                                    customTheme.registerImageWithName("logo",bundle: NSBundle.mainBundle(), forKey: A0ThemeIconImageName)
                                    customTheme.registerColor(UIColor.whiteColor(), forKey: A0ThemeIconBackgroundColor)
                                    customTheme.registerColor(color_range_selected, forKey: A0ThemeTitleTextColor)
                                    customTheme.registerColor(color_range_selected, forKey: A0ThemePrimaryButtonNormalColor)
                                    customTheme.registerColor(color_range_selected, forKey: A0ThemeSecondaryButtonTextColor)
                                    A0Theme.sharedInstance().registerTheme(customTheme)
                                    A0Controller = A0Lock.sharedLock().newLockViewController()
                                    A0Controller.closable = false
                                    //userDefaults.setValue(nil, forKey: UserDefaultsKeys.idToken)
                                    A0Controller.onAuthenticationBlock = { profile, token in
                                        userDefaults.setValue(token?.accessToken, forKey: UserDefaultsKeys.accessToken)
                                        userDefaults.setValue(token?.idToken, forKey: UserDefaultsKeys.idToken)
                                        self.A0Controller.dismissViewControllerAnimated(true, completion: nil)
                                        self.IDToken = token?.idToken
                                        self.AccessToken = token?.accessToken
                                        //self.context = Context(idToken: userDefaults.valueForKey(UserDefaultsKeys.idToken)! as! String, accessToken: userDefaults.valueForKey(UserDefaultsKeys.accessToken)! as!  String,URL : "http://cloudin.incoding.biz/Dispatcher/Push")
                                    }
                                    self.delegate = self
                                    for item in self.tabBar.items! {
                                        var image = item.image!.imageWithRenderingMode(.AlwaysOriginal)
                                        item.image = image
                                        image = item.selectedImage!.imageWithRenderingMode(.AlwaysOriginal)
                                        item.selectedImage = image
                                        
                                        item.setTitleTextAttributes([NSForegroundColorAttributeName: color_range_selected], forState: .Selected)
                                    }
                                    //self.tabBar.items![2].image = UIImage(named: "create-session")
                                    //self.tabBar.items![2].selectedImage = UIImage(named: "playbutton")
                                }
                                override func viewDidAppear(animated: Bool) {
                                    super.viewDidAppear(animated)
                                    if IDToken == nil {
                                        A0Lock.sharedLock().presentLockController(A0Controller, fromController: self)
                                    }
                                    
                                }
                                override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
                                    itemTag = item.tag
                                    if (item.tag == 2) && (userDefaults.valueForKey(UserDefaultsKeys.currentTab) as! Int == 2){
                                        if let activity = selectedActivityIndex {
                                            let req = CreateSessionCommand()
                                            req.On(success: { (resp : String)  in
                                                print(resp)
                                                dispatch_async(dispatch_get_main_queue()){
                                                    do {
                                                        try realm.write{
                                                            for i in 0...3 {
                                                                let entity = SessionFile()
                                                                entity.SessionId = resp
                                                                entity.FileName = resp.fileNameForSessionFile(.Data, postfix: String(i))
                                                                realm.add(entity)
                                                            }
                                                            
                                                        }
                                                    }catch {}
                       
                                                    userDefaults.setObject(resp, forKey: UserDefaultsKeys.sessionInfoId)
                                                    userDefaults.setInteger(activity, forKey: UserDefaultsKeys.sessionInfoCategory)
                                                    //userDefaults.synchronize()
                                                    
                                                    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.show_start_current_session,object : nil, userInfo: nil)
                                                    
                                                    self.tabBar.items![2].selectedImage = UIImage(named: "stop-session-selected")?.imageWithRenderingMode(.AlwaysOriginal)
                                                    
                                                }
                                                }, error: {})
                                        }
                                    }
                                    userDefaults.setInteger(item.tag, forKey: UserDefaultsKeys.currentTab)
                                }
                                
                                // MARK: - UITabBarControllerDelegate
                                func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
                                    
                                }
                            }
