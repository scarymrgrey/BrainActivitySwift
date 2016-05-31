//
//  MainVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 26/05/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit
class MainVC : UIViewController, CBManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cBManager = CBManager()
        cBManager.delegate = self
        cBManager.start()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func CB_dataUpdatedWithDictionary(data: [NSObject : AnyObject]!) {
        print("CBManager update")                            
    }
    
    

}
   