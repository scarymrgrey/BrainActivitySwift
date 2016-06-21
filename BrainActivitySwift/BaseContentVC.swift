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
class BaseContentVC: UIViewController , UIPageViewControllerDataSource {

    // MARK: - Variables
    var pageContainer: UIView!
    var pageViewController : UIPageViewController!
    var pageAtIndex : [Int : UIViewController!]! = [:]
    var pageIdAtIndex = [String]()
    var currentPosition  = 0
    var controllers = [ UIViewController]()
    // MARK: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        pageContainer = getContainer()
        pageIdAtIndex = getStoryboardViewControllersId()
        pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewControllerId") as! UIPageViewController
        if needSwipeGesture() {
             pageViewController.dataSource = self
        }
        let startVC = self.viewControllerAtIndex(0)
        let viewControllers :[UIViewController]? = [startVC!]
        pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        //let topbarheight = self.navigationController?.navigationBar.frame.height
       // let tabbarheigth = self.tabBarController?.tabBar.frame.height
        pageViewController.view.frame = CGRectMake(0, 0, pageContainer.frame.width, pageContainer.frame.height)
        self.addChildViewController(pageViewController)
        self.pageContainer.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
      
    }
    func getContainer() -> UIView{
        return pageContainer
    }
    func getStoryboardViewControllersId() -> [String]{
        return []
    }
    func needSwipeGesture() -> Bool{
        return true
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
        return 0
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

    func showVC(controller : UIViewController){
        
        let dir : UIPageViewControllerNavigationDirection!
        let destPosition = controllers.indexOf(controller)
        if currentPosition < destPosition {
            dir = .Forward
        }else if currentPosition > destPosition {
            dir = .Reverse
        }else {
            return
        }
        currentPosition = destPosition!
        pageViewController.setViewControllers([controller],direction : dir ,animated: true,completion: nil)
    }
    func getVCById(id : String) -> UIViewController{
        return (storyboard?.instantiateViewControllerWithIdentifier(id))!
    }
}
