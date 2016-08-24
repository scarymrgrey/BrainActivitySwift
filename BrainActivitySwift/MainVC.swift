//
//  MainVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 26/05/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit
class MainVC : UIViewController, CBManagerDelegate {
    //  MARK: = Local Variables =
    let notificationCenter = NSNotificationCenter.defaultCenter()
    var cBManager : CBManager!
    var battTimer : NSTimer!
    var plotsVC : PlotsVC?
    var selectedFreq : Float = 3
    var mainView : AnimatedSessionView!
    var currentTime = NSDate.timeIntervalSinceReferenceDate()
    //  MARK: VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView = self.view as! AnimatedSessionView
        cBManager = CBManager()
        cBManager.delegate = self
        UIApplication.sharedApplication().idleTimerDisabled = true
        //cBManager.start()
        self.navigationItem.hidesBackButton = true
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(self.increaseCounter), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK: = CB Manager Delegate
    func CB_fftDataUpdatedWithDictionary(data: [NSObject : AnyObject]!) {
        notificationCenter.postNotificationName(Notifications.fft_data_received,object : nil, userInfo: data)
    }
    func CB_indicatorsStateWithDictionary(data: [NSObject : AnyObject]!) {
        notificationCenter.postNotificationName(Notifications.indicators_data_received,object : nil, userInfo: data)
    }
    func CB_dataUpdatedWithDictionary(data: [NSObject : AnyObject]!) {
        notificationCenter.postNotificationName(Notifications.data_received,object : nil, userInfo: data)
        
    }
    func CB_changedStatus(status: CBManagerMessage, message statusMessage: String!) {
        
    }
    
    // MARK: Actions
    
    @IBAction func startTestAction(sender: UIButton) {
        if cBManager.hasStarted {
            if battTimer != nil {
                battTimer.invalidate()
                battTimer = nil
            }
            plotsVC?.SetDefaults()
            cBManager.stop()
            cBManager = CBManager()
            cBManager.delegate = self
        }else {
            cBManager.startTestSequenceWithDominantFrequence(selectedFreq)
        }
    }
    
    
    // MARK: = NAvigation =
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPlotSegue"{
            plotsVC = (segue.destinationViewController as! PlotsVC)
            plotsVC!.cBManager = cBManager
        }
    }
    // MARK: = methods
    func increaseCounter(){
        
        mainView.visibleCircle = true
        
        mainView.cnt += 0.5
    }
    
}
   