//
//  SpectrumVCPerfomanceTest.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 28/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import XCTest
@testable import BrainActivitySwift
class SpectrumVCPerfomanceTest: XCTestCase {
    var specVC : SpectrumVC!
    var not : NSNotification!
    override func setUp() {
        super.setUp()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        specVC = storyboard.instantiateViewControllerWithIdentifier("SpectrumVCId") as! SpectrumVC
        specVC.loadView()
        specVC.viewDidLoad()
        not = NSNotification(name: "notifi", object: nil, userInfo: [  "ch1" : "-123.40",
            "ch2" : "123.40",
            "ch3" : "-223.40",
            "ch4" : "444.40"])
        for _ in 0...200{
            self.specVC.fftDataReceived(self.not)
        }
        //let _ = rawVC.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformance_dataReceived() {
        self.measureBlock {
            self.specVC.fftDataReceived(self.not)
        }
    }
    
    func testPerfomance_createPlots(){
        self.measureBlock {
            self.specVC.createPlots()
        }
    }
    func testPerfomance_numberForPlot_index(){
        let plot = CPTPlot()
        plot.graph = self.specVC.graphDict.values.first
        self.specVC.fftDataReceived(self.not)
        self.measureBlock {
            self.specVC.numberForPlot(plot, field: 0, recordIndex: 0)
        }
    }
    func testPerfomance_numberForPlot_data(){
        let plot = CPTPlot()
        plot.graph = self.specVC.graphDict.values.first
        self.measureBlock {
            self.specVC.numberForPlot(plot, field: 1, recordIndex: 0)
        }
    }
    func testPerfomance_numberForPlot_dataFor4Ch(){
        var plots = [CPTPlot]()
        for graph in self.specVC.graphDict.values {
            let plot = CPTPlot()
            plot.graph = graph
            plots.append(plot)
        }
        
        self.measureBlock {
            for plot in plots {
                self.specVC.numberForPlot(plot, field: 1, recordIndex: 0)
            }
        }
    }

}
