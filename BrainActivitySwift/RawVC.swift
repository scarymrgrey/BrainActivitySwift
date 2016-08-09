
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
    var limit : Int = 16
    var currentChannel = 1
    var lastUpdatedIndexFor = [CPTPlot : NSNumber]()
    var graphs = [CPTXYGraph]()
    var dataForIndexKeyWasRead = [Bool](count : 4,repeatedValue : false)
    var dataForDataKeyWasRead = [Bool](count : 4,repeatedValue : false)
    // MARK: VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (SDiPhoneVersion.deviceVersion() == .iPhone6 || SDiPhoneVersion.deviceVersion() == .iPhone6Plus){
            limit = 4;
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
        lastUpdatedIndexFor[boundLinePlot] = 0
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
            data[i].append([ "index" : currentIndex , "data" : notificationData!["ch\(i+1)"] as! NSNumber])
            //print("Data for plot \(i) was ADDED at currentIndex = \(currentIndex).")
            //print("data[\(i)].count = \(data[i].count) ; currentIndex = \(currentIndex) ; currentRange = \(currentRange)")
        }
        if !(self.isViewLoaded() && self.view.window != nil){
            return
        }
        currentIndex = currentIndex + 1
        if (currentIndex % limit == 0) {
            let r = currentIndex > currentRange
            for graph in self.graphDict.values{
                if r {
                    let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
                    plotSpace.xRange = CPTPlotRange(location : currentIndex-currentRange, length:currentRange)
                    plotSpace.yRange = CPTPlotRange(location : -(scopeRaw/2), length: scopeRaw)
                }
                //let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0)
                //dispatch_sync(queue){
                let plot = graph.plotWithIdentifier("Blue Plot")!
                    plot.insertDataAtIndex(UInt(currentIndex-limit), numberOfRecords: UInt(limit))
               // }
                //print("call for :(\(currentIndex-limit):\(limit))")
            }
        }
    }
    
    // MARK: Plot Data Source Methods
 
    func numberOfRecordsForPlot(plot : CPTPlot) -> UInt{
        return UInt(currentIndex)
    }
    func numbersForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndexRange indexRange: NSRange) -> [AnyObject]? {
        if currentIndex == 0{
            return nil
        }
        
        let k = plot.graph as! CPTXYGraph
        let plotIndex = graphIndexDict[k]!
        
        let isIndex = fieldEnum == UInt(CPTScatterPlotField.X.rawValue)
        let key = isIndex ? "index" : "data"
        //print("data for: \(indexRange) - index: \(plotIndex) - key:\(key)")
        var res = [NSNumber](count:limit,repeatedValue : NSNumber())
        for i in 0..<limit {
            
            let num = data[plotIndex][i][key]!.copy() as! NSNumber
            res[i] = (num)
            
        }
        if isIndex {
            dataForIndexKeyWasRead[plotIndex] = true
        }else {
            dataForDataKeyWasRead[plotIndex] = true
        }
        if dataForIndexKeyWasRead[plotIndex]
            && dataForDataKeyWasRead[plotIndex] {
            var dataToWrite = [Float]()
            for i in 0..<limit {
                dataToWrite.append(data[plotIndex][i]["data"] as! Float)
            }
            dispatch_async(dispatch_get_main_queue()){
                binaryFileHelper.writeArrayToPlist("2.0",array: dataToWrite)
                print(binaryFileHelper.readArrayFromPlist("2.0")!)
            }
            data[plotIndex].removeFirst(limit)
            
            //print("Data for plot \(plotIndex) was DELETED at currentIndex = \(currentIndex).")
            dataForIndexKeyWasRead[plotIndex] = false
            dataForDataKeyWasRead[plotIndex] = false
            lastUpdatedIndexFor[plot] = indexRange.location + indexRange.length
        }
        return res
    }
    // MARK: Axis Delegate Methods
    func axis(axis: CPTAxis, shouldUpdateAxisLabelsAtLocations locations: Set<NSNumber>) -> Bool {
        return false
    }
    

}
