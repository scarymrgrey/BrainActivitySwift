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
    let pic = UIImage(named: "plus")!
    internal var image : UIImageView!
    var moodLabel : UILabel!
    override func updateConstraints() {
        super.updateConstraints()

        trashButton.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        moodLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //trash button
        Constraints(forTarget: trashButton).CenterY(0).Trailing(-5).Height(self.frame.height/2).Width(self.frame.height/2)
        
        //image
        Constraints(forTarget: image).CenterY(0).Height(self.frame.height/2).Width(self.frame.height/2).Leading(5)
        
        Constraints(forTarget: moodLabel).CenterY(0).CenterX(0).Height(40).Width(100)
    }
    init(dateText : String,moodText : String,frame : CGRect){
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        trashButton.setImage(UIImage(named: "trashcan"), forState: .Normal)
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
