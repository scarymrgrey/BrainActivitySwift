//
//  SessionsContainerView.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 05/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit
class SessionsContainerView: UIView {
    var resultsButton = UIButton()
    var activityImageView = UIImageView()
    var activityLabel = UILabel()
    var containerHeight : CGFloat = 0.0
    override func updateConstraints() {
        super.updateConstraints()
        //upperContainer.translatesAutoresizingMaskIntoConstraints = false
        for item in [activityImageView,
                     resultsButton , activityLabel]{
            item.translatesAutoresizingMaskIntoConstraints = false
        }
        //clock image
     self.Constraints(forTarget: activityImageView).CenterY(0).Width(containerHeight * 0.7).Height(containerHeight * 0.7).Leading(20)
        self.addConstraint(NSLayoutConstraint(item: activityLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: activityImageView, attribute: NSLayoutAttribute.Trailing
, multiplier: 1, constant: 20))
        self.Constraints(forTarget: activityLabel).CenterY(0)
        self.Constraints(forTarget: resultsButton).CenterY(0).Trailing(-20).Height(containerHeight*0.5).Width(containerHeight*0.5)
    }
    init(containerFrame : CGRect,timeString : String) {
        super.init(frame: containerFrame)
        containerHeight = containerFrame.height
        resultsButton.setImage(UIImage(named: "chart")?.imageWithRenderingMode(.AlwaysTemplate) , forState: .Normal)

        activityLabel.text = "Working"
        activityLabel.textColor = UIColor.whiteColor()
        activityImageView.tintColor = UIColor.whiteColor()
        resultsButton.tintColor = UIColor.whiteColor()
        
        self.addSubViews([activityImageView,resultsButton,activityLabel])
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
