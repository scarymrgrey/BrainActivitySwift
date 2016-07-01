//
//  BrainActivitySwiftTests.swift
//  BrainActivitySwiftTests
//
//  Created by Victor Gelmutdinov on 26/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import XCTest
import UIKit
@testable import BrainActivitySwift
class BrainActivitySwiftTests: XCTestCase {
    class FakeRawVC: RawVC {
        internal override func isViewLoaded() -> Bool{
            return true
        }
        class  FakeView: UIView {
            override var window: UIWindow? {
                get {
                    return UIWindow()
                }
            }
        }
        override var view: UIView! {
            get {
                return FakeView()
            }
            set {
                
            }
        }
    }
    
    var rawVC : FakeRawVC!
    var not : NSNotification!
    override func setUp() {
        super.setUp()
        rawVC = FakeRawVC()
        let fv1 = CPTGraphHostingView(frame: UIView().frame)
        let fv2 = CPTGraphHostingView(frame: UIView().frame)
        let fv3 = CPTGraphHostingView(frame: UIView().frame)
        let fv4 = CPTGraphHostingView(frame: UIView().frame)
        rawVC.View1 = fv1
        rawVC.View2 = fv2
        rawVC.View3 = fv3
        rawVC.View4 = fv4
        rawVC.loadView()
        rawVC.viewDidLoad()
        not = NSNotification(name: "notifi", object: nil, userInfo: [  "ch1" : NSNumber(float: -123.40),
            "ch2" :NSNumber(float: -123.40),
            "ch3" : NSNumber(float: -123.40),
            "ch4" : NSNumber(float: -123.40)])
        //let _ = rawVC.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformance_dataReceived() {
        self.measureBlock {
            for i in 0..<self.rawVC.limit*100 {
                self.rawVC.dataReceived(self.not)
               // StopWatch.getInfo("rawVC \(i)")
            }
        }
    }
    
    func testPerfomance_createPlots(){
        self.measureBlock {
            self.rawVC.createPlots()
        }
    }
//    func testPerfomance_numberForPlot_index(){
//        let plot = CPTPlot()
//        plot.graph = self.rawVC.graphDict.values.first
//        self.rawVC.dataReceived(self.not)
//        self.measureBlock {
//            for _ in 0..<self.rawVC.limit * 10 {
//                for i in 0...1 {
//                    self.rawVC.numbersForPlot(plot, field: UInt(i), recordIndexRange: NSMakeRange(0, self.rawVC.limit))
//                }
//            }
//        }
//    }
}
