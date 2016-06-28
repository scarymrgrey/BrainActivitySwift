//
//  RawVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 21/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import UIKit
class RawVC: UIViewController , CPTPlotDataSource, CPTAxisDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var View1: CPTGraphHostingView!
    @IBOutlet weak var View2: CPTGraphHostingView!
    @IBOutlet weak var View3: CPTGraphHostingView!
    @IBOutlet weak var View4: CPTGraphHostingView!
    
    // MARK: Local Variables
    let RAW_SCOPE = 200000
    var data : [[Dictionary<String,AnyObject>]]!
    var dataFFT : [[Dictionary<String,AnyObject>]]!
    var graphDict = [UIView : CPTXYGraph]()
    var graphIndexDict = [CPTXYGraph : Int]()
    var currentRange : Int!
    var scopeRaw : Int!
    var currentIndex : Int!
    var viewIndexes = [UIView:Int]()
    var plotH = NSLayoutConstraint()
    var limit : Int = 4
    var currentChannel = 1
    var graphs = [CPTXYGraph]()
    // MARK: VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (SDiPhoneVersion.deviceVersion() == .iPhone6 || SDiPhoneVersion.deviceVersion() == .iPhone6Plus){
            limit = 2;
        }
        setDefaultValues()
        viewIndexes = [View1:0 , View2:1 , View3:2,View4:3]
        data = [[Dictionary<String,AnyObject>]](count: 4, repeatedValue: [Dictionary<String,AnyObject>]())
        dataFFT = [[Dictionary<String,AnyObject>]](count: 4, repeatedValue: [Dictionary<String,AnyObject>]())
        createPlots()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(dataReceived), name: Notifications.data_received, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(fftDataReceived), name: Notifications.fft_data_received, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(indiDataReceived), name: Notifications.indicators_data_received, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.plotH.constant = (UIScreen.mainScreen().bounds.size.height-160)/4
        self.view.layoutSubviews()
    }
   
    // MARK: Plot Helpers
    func setDefaultValues(){
        scopeRaw = RAW_SCOPE
        currentRange = 5*250
        currentIndex = 0
        currentChannel = 1
    }
    
    func createPlots(){
        for vw in [View1,View2,View3,View4]{
            self.createCorePlot(vw, color: UIColor.lightGrayColor())
        }
    }
    
    func createCorePlot( view2addGraph : UIView, color : UIColor ) { // Create graph from theme
        let newGraph = CPTXYGraph(frame: CGRectZero)
        let theme = CPTTheme(named: kCPTPlainWhiteTheme)
        newGraph.applyTheme(theme)
        graphDict[view2addGraph] = newGraph
        graphIndexDict[graphDict[view2addGraph]!] = viewIndexes[view2addGraph]
        let hostingView = view2addGraph as! CPTGraphHostingView
        hostingView.collapsesLayers = false // Setting to true reduces GPU memory usage,but can slow drawing/scrolling hostingView.hostedGraph = newGraph
        hostingView.hostedGraph = newGraph
        // Setup plot space
        let plotSpace = newGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.xRange = CPTPlotRange(location:  0.0,length: currentRange )
        plotSpace.yRange = CPTPlotRange(location: -(scopeRaw/2),length : scopeRaw)
        // Axes
        let axisSet = newGraph.axisSet as! CPTXYAxisSet
        let x = axisSet.xAxis!
        //x.majorIntervalLength = CPTDecimalFromDouble(125);
        //x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(10.0);
        //x.minorTicksPerInterval = 0;
        x.labelingPolicy = CPTAxisLabelingPolicy.None
        //[[newGraph plotAreaFrame] setPaddingLeft:30.0f];
        let y = axisSet.yAxis!
        y.majorIntervalLength = 10000
        y.minorTicksPerInterval = 0
        y.delegate = self
        // Create a blue plot area
        let boundLinePlot = CPTScatterPlot()
        let lineStyle = CPTMutableLineStyle()
        lineStyle.miterLimit = 1.0
        lineStyle.lineWidth = 1.0
        lineStyle.lineColor = CPTColor(CGColor: color.CGColor)
        boundLinePlot.dataLineStyle = lineStyle
        boundLinePlot.identifier = "Blue Plot"
        boundLinePlot.dataSource = self
        newGraph.plotAreaFrame!.borderLineStyle = nil
        newGraph.addPlot(boundLinePlot)
        newGraph.paddingLeft = 0.0
        newGraph.paddingTop = 0.0
        newGraph.paddingRight = 0.0
        newGraph.paddingBottom = 0.0
    }
    // MARK: Notifications
    func dataReceived(notification : NSNotification){
        
        let notificationData = notification.userInfo
        for i in 0...3 {
            data[i].append([ "index" : currentIndex , "data" : notificationData!["ch\(i+1)"]!])
            if currentIndex > currentRange {
                data[i].removeFirst()
            }
            //print("data[\(i)].count = \(data[i].count) ; currentIndex = \(currentIndex) ; currentRange = \(currentRange)")
        }
        if !(self.isViewLoaded() && self.view.window != nil){
            return
        }
    
        if currentIndex % limit == 0 {
            let r = currentIndex > currentRange
            for graph in self.graphDict.values{
                if r {
                    let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
                    plotSpace.xRange = CPTPlotRange(location : currentIndex-currentRange, length:currentRange)
                    plotSpace.yRange = CPTPlotRange(location : -(scopeRaw/2), length: scopeRaw)
                }
                graph.reloadData()
            }
        }
        currentIndex = currentIndex + 1
    }
    
    
    // MARK: Plot Data Source Methods
    
    func numberOfRecordsForPlot(plot : CPTPlot) -> UInt{
        return UInt(data[0].count)
    }
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
        let k = plot.graph as! CPTXYGraph
        let indexForData = graphIndexDict[k]
        let isX = fieldEnum == UInt(CPTScatterPlotField.X.rawValue)
        let key = isX ? "index" : "data"
        let num = data[indexForData!][Int(idx)][key]
        return num
    }
    // MARK: Axis Delegate Methods
    func axis(axis: CPTAxis, shouldUpdateAxisLabelsAtLocations locations: Set<NSNumber>) -> Bool {
        
        return false
    }
}
