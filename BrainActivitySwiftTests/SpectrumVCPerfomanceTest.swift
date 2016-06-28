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
        not = NSNotification(name: "notifi", object: nil, userInfo: ["ch2" : [
            "data1" : 5,
            "data1_" : "4074748.076242105",
            "data2" : 10,
            "data2_" : "2918449.095536458",
            "data3" : 19,
            "data3_" : "1106198.598135648"],
            "ch1" : [
                "data1" : 5,
                "data1_" : "4074748.076242105",
                "data2" : 10,
                "data2_" : "2918449.095536458",
                "data3" : 19,
                "data3_" : "1106198.598135648"],
            "ch3" : [
                "data1" : 5,
                "data1_" : "4074748.076242105",
                "data2" : 10,
                "data2_" : "2918449.095536458",
                "data3" : 19,
                "data3_" : "1106198.598135648"],
            "ch4" : [
                "data1" : 5,
                "data1_" : "4074748.076242105",
                "data2" : 10,
                "data2_" : "2918449.095536458",
                "data3" : 19,
                "data3_" : "1106198.598135648"]])
        
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
//            for plot in plots {
//                self.specVC.numberForPlot(plot, field: 1, recordIndex: 0)
//            }
        }
    }

}
