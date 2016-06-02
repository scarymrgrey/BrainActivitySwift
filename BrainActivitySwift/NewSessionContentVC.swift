//
//  ProfileVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 31/05/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit
protocol ProfilePages {
    var pageIndex : Int! {
        get
    }
}
class NewSessionContentVC: UIViewController , UIPageViewControllerDataSource {
    
    // MARK: - Variables
    var pageViewController : UIPageViewController!
    var pageAtIndex : [Int : UIViewController!]! = [:]
    var pageIdAtIndex = ["FirstVCId","SecondVCId"]
    
    // MARK: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewControllerId") as! UIPageViewController
        pageViewController.dataSource = self
        let startVC = self.viewControllerAtIndex(0)
        let viewControllers :[UIViewController]? = [startVC!]
        pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        //let tabbarheigth = self.tabBarController?.tabBar.frame.height
        pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.width, self.view.frame.height - 80)
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }
    
    // MARK: - Actions
    
    // MARK: - PageVC delegates
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ProfilePages
        return self.viewControllerAtIndex(vc.pageIndex+1)
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ProfilePages
        
        return self.viewControllerAtIndex(vc.pageIndex-1)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageIdAtIndex.count
    }
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    //  MARK: - Pages helpers
    func viewControllerAtIndex(index : Int) -> UIViewController?{
        if index<0 || index >= pageIdAtIndex.count{
            return nil
        }
        
        if pageAtIndex[index] == nil {
            pageAtIndex[index] = self.storyboard?.instantiateViewControllerWithIdentifier(pageIdAtIndex[index])
        }
        return pageAtIndex[index]
    }
}
