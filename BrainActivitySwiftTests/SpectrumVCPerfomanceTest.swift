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
    class FakeSpectrumVC: SpectrumVC {
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
    var specVC : FakeSpectrumVC!
    var not : NSNotification!
    override func setUp() {
        super.setUp()

        specVC = FakeSpectrumVC()

        let fv1 = CPTGraphHostingView(frame: UIView().frame)
        let fv2 = CPTGraphHostingView(frame: UIView().frame)
        let fv3 = CPTGraphHostingView(frame: UIView().frame)
        let fv4 = CPTGraphHostingView(frame: UIView().frame)
        specVC.View1 = fv1
        specVC.View2 = fv2
        specVC.View3 = fv3
        specVC.View4 = fv4
        
        specVC.view = UIView()
        
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
            for _ in 0...100 {
                self.specVC.fftDataReceived(self.not)
            }
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
        plot.identifier = "Yellow Plot"
        self.measureBlock {
            self.specVC.numberForPlot(plot, field: 0, recordIndex: 0)
        }
    }
    func testPerfomance_numberForPlot_data(){
        let plot = CPTPlot()
        plot.graph = self.specVC.graphDict.values.first
        plot.identifier = "Yellow Plot"
        self.measureBlock {
            self.specVC.numberForPlot(plot, field: 1, recordIndex: 0)
        }
    }
    func testPerfomance_numberForPlot_dataFor4Ch(){
        var plots = [CPTPlot]()
        for graph in self.specVC.graphDict.values {
            let plot = CPTPlot()
            plot.graph = graph
            plot.identifier = "Yellow Plot"
            plots.append(plot)
        }
        self.measureBlock {
            for _ in 0...10000{
                for plot in plots {
                    self.specVC.numberForPlot(plot, field: 1, recordIndex: 1)
                }
            }
        }
    }

}
