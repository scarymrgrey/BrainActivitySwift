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
    var activitiesList = [ActivityTypeEnum.Biking,
                      .Cooking,
                      .Dating,
                      .Driving,
                      .Gaming,
                      .Meditation,
                      .Movies,
                      .Reading,
                      .Working,
                      .Other
    ]
    
    // MARK: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //super.addBattBar()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showStartCurrentSession), name: Notifications.show_start_current_session, object: nil)
    }
    
    // MARK: - Actions
    // MARK : Notifications
   func showStartCurrentSession(notification : NSNotification){
    
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
        tabbar.selectedActivity = activitiesList[indexPath.row]
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return activitiesList.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("activityCellId", forIndexPath: indexPath) as! ActivityCell
        cell.img.image = UIImage(named: activitiesList[indexPath.row].rawValue)!.imageWithRenderingMode(.AlwaysTemplate)
        cell.imgCircle.image = UIImage(named: "circle")
        cell.img.tintColor = UIColor.blackColor()
        return cell
    }
}
