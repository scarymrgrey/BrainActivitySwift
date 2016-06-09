//
//  SessionHeaderView.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 05/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit

class SessionHeaderView: UIView {
    private let trashButton = UIButton()
    let pic = UIImage(named: "unnamed")!
    internal var image : UIImageView!
    var moodLabel : UILabel!
    override func updateConstraints() {
        super.updateConstraints()

        trashButton.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        moodLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //trash button
        self.addConstraint(NSLayoutConstraint(item: trashButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: trashButton, attribute: .TrailingMargin, relatedBy: .Equal, toItem: self, attribute: .TrailingMargin, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: trashButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.frame.height))
        self.addConstraint(NSLayoutConstraint(item: trashButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.frame.height))
        
        //image
        Constraints(forTarget: image).CenterY(0).Height(self.frame.height).Width(self.frame.height).Leading(0)
        
        Constraints(forTarget: moodLabel).CenterY(0).CenterX(0).Height(40).Width(100)
    }
    init(dateText : String,moodText : String,frame : CGRect){
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        trashButton.setImage(UIImage(named: "icontrash"), forState: .Normal)
        moodLabel = UILabel(frame: frame)

        moodLabel.text = moodText
        image = UIImageView(image: pic)

        self.addSubViews([trashButton,moodLabel,image])
        self.updateConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
