//
//  PlotsVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 21/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit

class PlotsVC: BaseContentVC {
    
    // MARK: = Outlets =

    @IBOutlet weak var Container: UIView!
    // MARK: = Local Variables =
    //var cBManager : CBManager!
    let VCIds = ["RawVCId","SpectrumVCId","IndicatorsVCId"]
    // MARK: VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        for id in VCIds{
            controllers.append(getVCById(id))
        }
    }
    
    // MARK: VC HelperMethods
    func SetDefaults(){
    }
    
    // MARK: = Actions =
    @IBAction func segmentControlValueChanged(sender: UISegmentedControl) {
        showVC(controllers[sender.selectedSegmentIndex])
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
