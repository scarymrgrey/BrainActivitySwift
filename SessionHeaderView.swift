//
//  SessionHeaderView.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 05/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit

class SessionHeaderView: UIButton {
    private let trashButton = UIButton()
   
    override func updateConstraints() {
        super.updateConstraints()
        //trash button
        
        self.addConstraint(NSLayoutConstraint(item: trashButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: trashButton, attribute: .TrailingMargin, relatedBy: .Equal, toItem: self, attribute: .TrailingMargin, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: trashButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40))
        self.addConstraint(NSLayoutConstraint(item: trashButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40))
    }
    init(dateLabel : String,moodLabel : String){
        super.init(frame: CGRectMake(0, 0, 50,50))
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.setTitle(dateLabel, forState: .Normal)
        self.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        trashButton.setImage(UIImage(named: "icontrash"), forState: .Normal)
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(trashButton)


        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
