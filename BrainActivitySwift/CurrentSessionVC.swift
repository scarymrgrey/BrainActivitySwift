//
//  CUrrentSessionVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 04/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit

class CurrentSessioVC : StatisticForCurrentSessionVC {
    @IBOutlet weak var ActivityTextLabel: UILabel!
    @IBOutlet weak var ActivityImageView: UIImageView!
    @IBOutlet weak var Table : UITableView!
    
    
    override  var TableView : UITableView! {
        get {
            return self.Table
        }
        set {
            self.Table = newValue
        }
        
    }
    override var numberOfSectionsWithoutInnerContent: Int! {
        get {
            return 1
        }
        set {}
    }
    var ActivityType : ActivityTypeEnum!
    var ActivityText : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ActivityImageView.image = UIImage(named: ActivityType.rawValue)
        ActivityTextLabel.text = ActivityText
        sessionId = userDefaults.stringForKey(UserDefaultsKeys.currentSessionId)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //print(ActivityImageView.image!.imageAsset)
    }
 
}
