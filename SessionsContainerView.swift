//
//  SessionsContainerView.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 05/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit
class SessionsContainerView: UIView ,UICollectionViewDataSource{
    var resultsButton = UIButton()
    var upperContainer : UIView!
    var clockImageView = UIImageView(image: UIImage(named: "clock-128"))
    var clockTimeLabel  = UILabel()
    var resultLabel  = UILabel()
    var activityCollectionView : UICollectionView!
    override func updateConstraints() {
        super.updateConstraints()
        //upperContainer.translatesAutoresizingMaskIntoConstraints = false
        for item in [clockImageView,clockTimeLabel,
                     resultsButton,resultLabel,
                     activityCollectionView]{
            item.translatesAutoresizingMaskIntoConstraints = false
        }
        //clock image
        self.addConstraint(NSLayoutConstraint(item: clockImageView, attribute: .CenterY, relatedBy: .Equal, toItem: upperContainer, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: clockImageView, attribute: .LeadingMargin, relatedBy: .Equal, toItem: upperContainer, attribute: .LeadingMargin, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: clockImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30))
        self.addConstraint(NSLayoutConstraint(item: clockImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30))
        
        self.Constraints(forTarget: clockTimeLabel).Related(to: clockImageView).CenterY(0).AddComplex(from: .Leading, to: .Trailing, value: 10).Height(20)
        self.Constraints(forTarget: resultsButton).Related(to: upperContainer).CenterY(0).Trailing(0).Height(30).Width(30)
        self.Constraints(forTarget: resultLabel).Related(to: resultsButton).Height(20).Width(60).CenterY(0).AddComplex(from: .Trailing , to: .Leading, value: 10)
        self.Constraints(forTarget: activityCollectionView).Related(to: self).Trailing(0).Leading(0).Bottom(0)
        self.Constraints(forTarget: activityCollectionView).Related(to: upperContainer).AddComplex(from: .Top, to: .Bottom, value: 0)
    }
    init(containerFrame : CGRect,timeString : String) {
        super.init(frame: containerFrame)
        let sectionHeight = containerFrame.height
        //section
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.grayColor().CGColor
        //uppercontainer
        upperContainer = UIView(frame: CGRectMake(0, 0, containerFrame.width,containerFrame.height/3))

        clockTimeLabel.text = timeString
        resultsButton.setImage(UIImage(named: "diagram-icon"), forState: .Normal)

        resultLabel.text = "results"
        
        upperContainer.addSubViews([clockImageView,resultsButton,resultLabel])
        //bottomcontainer
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: sectionHeight/2, height: sectionHeight/2)
        activityCollectionView = UICollectionView(frame: CGRectMake(0, 0, 0, 0), collectionViewLayout: layout)
     
        activityCollectionView.dataSource = self
        activityCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "reusableCellId")
        activityCollectionView.backgroundColor = UIColor.whiteColor()
        self.addSubViews([upperContainer,clockTimeLabel,activityCollectionView])
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Collection View
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reusableCellId", forIndexPath: indexPath)
        //cell.backgroundView = UIImageView(image: UIImage(named: "unnamed"))
        return cell
    }
}
