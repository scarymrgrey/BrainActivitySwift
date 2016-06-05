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
    var collectionView : UICollectionView!
    var clockImage : UIImage!
    var clockTimeLabel : UILabel!
    var resultLabel : UILabel!
    override func updateConstraints() {
        super.updateConstraints()
//        addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50.0))
//        addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 200.0))
//        
//        addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0))
//        addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
//        addConstraint(NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
//        addConstraint(NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: self, attr
    }
    init() {
        super.init(frame: CGRectMake(0, 0, 0, 100))
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.grayColor().CGColor
        resultLabel = UILabel(frame: CGRectMake(0,0,50,25))
        resultLabel.text = "hello"
        resultLabel.textColor = UIColor.greenColor()
        self.addSubview(resultLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
