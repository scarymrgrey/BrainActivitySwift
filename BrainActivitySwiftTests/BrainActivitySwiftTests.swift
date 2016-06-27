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
    var rawVC : RawVC!
    var not : NSNotification!
    override func setUp() {
        super.setUp()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        rawVC = storyboard.instantiateViewControllerWithIdentifier("RawVCId") as! RawVC
        rawVC.loadView()
        rawVC.viewDidLoad()
        not = NSNotification(name: "notifi", object: nil, userInfo: [  "ch1" : "-123.40",
            "ch2" : "123.40",
            "ch3" : "-223.40",
            "ch4" : "444.40"])
        //let _ = rawVC.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformance_dataReceived() {
        self.measureBlock {
        self.rawVC.dataReceived(self.not)
        }
    }
    
    func testPerfomance_createPlots(){
        self.measureBlock {
            self.rawVC.createPlots()
        }
    }
    func testPerfomance_numberForPlot(){
        var plots = [CPTPlot]()
        for graph in self.rawVC.graphDict.values {
            let plot = CPTPlot()
            plot.graph = graph
            plots.append(plot)
        }
        self.rawVC.dataReceived(self.not)
        self.measureBlock {
            for plot in plots {
                self.rawVC.numberForPlot(plot, field: 1, recordIndex: 0)
            }
            
        }
    }
}
