//
//  ContentViewController.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 02/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit


class ActivityVC: UIViewController ,ProfilePages ,UICollectionViewDataSource,UICollectionViewDelegate{
    // MARK: - Variables
    var pageIndex : Int! = 0

    
    // MARK: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    // MARK: - Collection View
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("activityCellId", forIndexPath: indexPath)
        return cell
    }
}
