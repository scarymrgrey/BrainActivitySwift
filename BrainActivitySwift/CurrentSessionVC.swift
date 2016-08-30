//
//  CUrrentSessionVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 04/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit

class CurrentSessioVC : UIViewController {
    @IBOutlet weak var ActivityTextLabel: UILabel!
    @IBOutlet weak var ActivityImageView: UIImageView!
    var ActivityType : ActivityTypeEnum!
    var ActivityText : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        let IV = UIImageView()
        IV.image = UIImage(named: ActivityType.rawValue)
        ActivityImageView = IV
        ActivityTextLabel.text = ActivityText

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //print(ActivityImageView.image!.imageAsset)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EmbedStatForCurrentSession"{
            let vc = (segue.destinationViewController as! StatisticsVC)
            vc.sessionId = userDefaults.stringForKey(UserDefaultsKeys.currentSessionId)
            vc.CurrentStatisticType = .CurrentSessionStat
            print( vc.sessionId)
        }
    }
}