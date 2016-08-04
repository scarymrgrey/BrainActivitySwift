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
    var activityTimeLabel = UILabel()
    var LabelContainer = UIView()
    var containerHeight : CGFloat = 0.0
    override func updateConstraints() {
        super.updateConstraints()
        //upperContainer.translatesAutoresizingMaskIntoConstraints = false
        for item in [activityImageView,
                     resultsButton , activityLabel,activityTimeLabel,LabelContainer]{
                        item.translatesAutoresizingMaskIntoConstraints = false
        }
        LabelContainer.Constraints(forTarget: activityTimeLabel).Bottom(0)
        LabelContainer.Constraints(forTarget: activityLabel).Top(0)
        //clock image
        self.Constraints(forTarget: activityImageView).CenterY(0).Width(containerHeight * 0.7).Height(containerHeight * 0.7).Leading(10)
        self.addConstraint(NSLayoutConstraint(item: LabelContainer, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: activityImageView, attribute: NSLayoutAttribute.Trailing
            , multiplier: 1, constant: 20))
        self.Constraints(forTarget: LabelContainer).CenterY(0).Height(containerHeight*0.7)
        self.Constraints(forTarget: resultsButton).CenterY(0).Trailing(-20).Height(containerHeight*0.5).Width(containerHeight*0.5)
    }
    init(containerFrame : CGRect,timeString : String) {
        super.init(frame: containerFrame)
        containerHeight = containerFrame.height
        resultsButton.setImage(UIImage(named: "chart")?.imageWithRenderingMode(.AlwaysTemplate) , forState: .Normal)
        LabelContainer.addSubViews([activityLabel,activityTimeLabel])
        activityLabel.text = "Working"
        activityLabel.textColor = UIColor.whiteColor()
        activityTimeLabel.text = "01:55:56"
        activityTimeLabel.textColor = UIColor.whiteColor()
        activityImageView.tintColor = UIColor.whiteColor()
        resultsButton.tintColor = UIColor.whiteColor()
        let rightLine = CALayer()
        rightLine.frame = CGRectMake(containerHeight * 0.7 + 9, 0, 2,containerHeight)
        rightLine.backgroundColor = Colors.orange.CGColor
        activityImageView.layer.addSublayer(rightLine)
        self.addSubViews([activityImageView, resultsButton, LabelContainer])
        updateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
