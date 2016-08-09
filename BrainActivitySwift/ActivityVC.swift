//
//  ContentViewController.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 02/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit


class ActivityVC: BatteryBarVC ,ProfilePages ,UICollectionViewDataSource,UICollectionViewDelegate{
    // MARK: - Variables
    var pageIndex : Int! = 0
    
    var selectedCell: Int!
    var activities = ["activity-biking",
                      "activity-cooking",
                      "activity-dating",
                      "activity-driving",
                      "activity-gaming",
                      "activity-meditation",
                      "activity-movies",
                      "activity-reading",
                      "activity-working",
                      "activity-other"
    ]
    
    // MARK: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //super.addBattBar()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showStartCurrentSession), name: Notifications.show_start_current_session, object: nil)
    }
    
    // MARK: - Actions
    // MARK : Notifications
    func showStartCurrentSession(){
        self.navigationController?.performSegueWithIdentifier("showCurrentSession", sender: nil)
    }
    // MARK: - Collection View
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ActivityCell
        for cl in collectionView.visibleCells() {
            let c = cl as! ActivityCell
            c.img.tintColor = UIColor.blackColor()
            c.imgCircle.image = UIImage(named: "circle")
        }
        cell.img.tintColor = UIColor.whiteColor()
        cell.imgCircle.image = UIImage(named: "circle-selected")
        let tabbar = self.tabBarController as! TabBarController
        tabbar.selectedActivityIndex = indexPath.row
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activities.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("activityCellId", forIndexPath: indexPath) as! ActivityCell
        cell.img.image = UIImage(named: activities[indexPath.row])!.imageWithRenderingMode(.AlwaysTemplate)
        cell.imgCircle.image = UIImage(named: "circle")
        cell.img.tintColor = UIColor.blackColor()
        return cell
    }
}
