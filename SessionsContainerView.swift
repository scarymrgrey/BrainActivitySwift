//
//  SessionsContainerView.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 05/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit

class SessionsContainerView: UIView {
    var resultsButton : UIView!
    var upperContainer : UIView!
    var collectionView : UICollectionView!
    var clockImageView = UIImageView(image: UIImage(named: "clock-128"))
    var clockTimeLabel  = UILabel()
    var resultLabel  = UILabel()
    override func updateConstraints() {
        super.updateConstraints()
        //upperContainer.translatesAutoresizingMaskIntoConstraints = false
        clockImageView.translatesAutoresizingMaskIntoConstraints = false
        clockTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        //clock image
        self.addConstraint(NSLayoutConstraint(item: clockImageView, attribute: .CenterY, relatedBy: .Equal, toItem: upperContainer, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: clockImageView, attribute: .LeadingMargin, relatedBy: .Equal, toItem: upperContainer, attribute: .LeadingMargin, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: clockImageView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30))
        self.addConstraint(NSLayoutConstraint(item: clockImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30))
        
        self.Constraints(forTarget: clockTimeLabel).Related(to: clockImageView).CenterY(0).AddComplex(from: .Leading, to: .Trailing, value: 10).Height(20)
        
    }
    init(containerWidth : CGFloat) {
        super.init(frame: CGRectMake(0, 0, 0, 100))
        //section
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.grayColor().CGColor
        //uppercontainer
        upperContainer = UIView(frame: CGRectMake(0, 0, containerWidth,30))
        upperContainer.layer.borderWidth = 1
        upperContainer.layer.borderColor = UIColor.grayColor().CGColor
        upperContainer.addSubview(clockImageView)
        clockTimeLabel.text = "18:34:19"
        //self.addSubview(resultLabel)
        self.addSubview(upperContainer)
        self.addSubview(clockTimeLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
