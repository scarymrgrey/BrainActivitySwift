//
//  NewSessionContentVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 21/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit

class NewSessionContentVC : BaseContentVC {
    
    // MARK: = Outlets =
    @IBOutlet weak var Container: UIView!
    // MARK: = Local Variables =
    let VCIds = ["FirstVCId","SecondVCId","ThirdVCId"]
    // MARK: = VC LifeCycle =
    override func viewDidLoad() {
        super.viewDidLoad()
        for id in VCIds{
            controllers.append(getVCById(id))
        }
    }
    
    // MARK: = Actions =
    @IBAction func activityButtonAction(sender: AnyObject) {
        showVC(controllers[0])
    }
    @IBAction func metricsButtonAction(sender: AnyObject) {
        showVC(controllers[1])
    }
    @IBAction func moodButtonAction(sender: AnyObject) {
        showVC(controllers[2])
    }

    override func getContainer() -> UIView {
        return Container
    }
    override func getStoryboardViewControllersId() -> [String] {
        return VCIds
    }
    override func needSwipeGesture() -> Bool {
        return false
    }

}
