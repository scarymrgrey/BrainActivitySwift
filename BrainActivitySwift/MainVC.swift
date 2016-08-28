//
//  MainVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 26/05/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit
import Advance
enum MainVCScene {
    case Scene1
    case Scene2
    case Scene3
    case Scene4
}
class MainVC : UIViewController, CBManagerDelegate {
    //@IBOutlet weak var ViewForAnimation: AnimationView!
    
    //  MARK: = Local Variables =
    let notificationCenter = NSNotificationCenter.defaultCenter()
    var cBManager : CBManager!
    var battTimer : NSTimer!
    var plotsVC : PlotsVC?
    var selectedFreq : Float = 3
    var mainView : AnimatedSessionView!
    var currentTime = NSDate.timeIntervalSinceReferenceDate()
    let aniView = AnimationView()
    var headOutlineImageView : UIImageView!
    var scene2Timers = NSTimer()
    var currentScene : MainVCScene!
    //  MARK: VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //aniView.flashing = true
        //ViewForAnimation.addSubview(aniView)
        self.edgesForExtendedLayout = .None
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        mainView = self.view as! AnimatedSessionView
        mainView.flashing = true
        
        cBManager = CBManager()
        cBManager.delegate = self
        UIApplication.sharedApplication().idleTimerDisabled = true
        //cBManager.start()
        
        self.navigationItem.hidesBackButton = true
       
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        scene1Start()
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
        if segue.identifier == "showCurrentSessionStat"{
            let vc = (segue.destinationViewController as! StatisticsVC)
            vc.sessionId = userDefaults.stringForKey(UserDefaultsKeys.currentSessionId)
            print( vc.sessionId)
        }
    }
    // MARK: = methods
    func increaseCounter(){
        mainView.cnt += 0.5
        if currentScene == .Scene2 {
            if mainView.cnt >= 100{
                mainView.CenterTextLabel.hidden = false
                if scene2Timers.valid {
                    scene2Timers.invalidate()
                }
                NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(self.scene3Start), userInfo: nil, repeats: false)
            }
        }else if currentScene == .Scene4 {
            let thistime = NSDate.timeIntervalSinceReferenceDate()
            let timePast = currentTime.distanceTo(thistime)
            mainView.CenterTextLabel.text = timePast.toTimeString()
            if mainView.cnt >= 20 {
                self.performSegueWithIdentifier("showCurrentSessionStat", sender: nil)
                if scene2Timers.valid {
                    scene2Timers.invalidate()
                }
            }
        }
    }
    // MARK - VC SCENES
    
    func scene1Start(){
        currentScene = .Scene1
        mainView.startAnimation()
        let img = UIImage(named: "headOutline")?.imageWithRenderingMode(.AlwaysOriginal)
        headOutlineImageView = UIImageView()
        headOutlineImageView.image = img
        headOutlineImageView.tintColor = UIColor.whiteColor()
        headOutlineImageView.backgroundColor = UIColor.clearColor()
        headOutlineImageView.frame.size = CGSize(width: view.frame.width * 0.6, height: view.frame.height * 0.6)
        view.addSubview(headOutlineImageView)
        headOutlineImageView.translatesAutoresizingMaskIntoConstraints = false
        view.Constraints(forTarget: headOutlineImageView).CenterX(0).CenterY(0)
        mainView.visibleAnimation = false
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(self.scene2Start), userInfo: nil, repeats: false)
    }
    func scene2Start(){
        currentScene = .Scene2
        mainView.visibleAnimation = true
        headOutlineImageView.hidden = true
        mainView.drawCounter()
        mainView.redrawOutline(with: 0.0)
        scene2Timers = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(self.increaseCounter), userInfo: nil, repeats: true)
        
    }
    func scene3Start(){
        currentScene = .Scene3
        mainView.counterLayer.removeFromSuperlayer()
        mainView.outlineLayer.removeFromSuperlayer()
        mainView.CenterTextLabel.text = "WE BEGIN!"
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(self.scene4Start), userInfo: nil, repeats: false)
    }
    func scene4Start(){
        currentScene = .Scene4
        mainView.drawCounter()
        mainView.redrawOutline(with: 0.0)
        mainView.cnt = 0.0
        currentTime = NSDate.timeIntervalSinceReferenceDate()
        scene2Timers = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(self.increaseCounter), userInfo: nil, repeats: true)
    }
    
}
   