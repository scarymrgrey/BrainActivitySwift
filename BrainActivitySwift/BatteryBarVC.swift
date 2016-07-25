//
//  BatteryBarVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 24/07/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation

class BatteryBarVC : UIViewController {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bar = UIView()
        //customView = MyCustomView(frame: CGRectZero(top: 0, left: 0, width: 200, height: 50)
        let batt = UIImageView()
        let textLabel = UILabel()
        textLabel.text = "Device not found"
        textLabel.textColor = UIColor.whiteColor()
        bar.addSubview(textLabel)
        batt.image = UIImage(named: "battery-green")
        
        bar.addSubview(batt)
        bar.backgroundColor = UIColor(red: 72/255, green: 73/255, blue: 78/255, alpha: 1)
        batt.translatesAutoresizingMaskIntoConstraints = false
        bar.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bar)
        self.view.Constraints(forTarget: bar).Leading(0).Bottom(0).Trailing(0).Height(20)
        bar.Constraints(forTarget: batt).AddComplex(from: NSLayoutAttribute.Trailing, to: NSLayoutAttribute.Trailing, value: -5).CenterY(0).Height(15).Width(30)
        bar.Constraints(forTarget: textLabel).CenterY(0).Height(10).Leading(5)
        //view.updateConstraints()
    }
}