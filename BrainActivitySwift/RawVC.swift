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
    var data = [NSMutableArray]()
    var dataFFT = [NSMutableArray]()
    var graphDict = [UIView : CPTXYGraph]()
    var graphIndexDict = [CPTXYGraph : Int]()
    var currentRange : Int!
    var scopeRaw : Int!
    var currentView : Int!
    var currentIndex : Int!
    var viewIndexes = [UIView:Int]()
    var plotH = NSLayoutConstraint()
    var limit : Int = 10
    var currentFFTIndex = 0
    var currentChannel = 1
    var graphs = [CPTXYGraph]()
    var currentTime = NSDate.timeIntervalSinceReferenceDate()
    // MARK: VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (SDiPhoneVersion.deviceVersion() == .iPhone6 || SDiPhoneVersion.deviceVersion() == .iPhone6Plus){
            limit = 8;
        }
        setDefaultValues()
        viewIndexes = [View1:0 , View2:1 , View3:2,View4:3]
        data = [NSMutableArray](count: 4, repeatedValue: NSMutableArray())
        dataFFT = [NSMutableArray](count: 4, repeatedValue: NSMutableArray())
        createPlots()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(dataReceived), name: Notifications.data_received, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(fftDataReceived), name: Notifications.fft_data_received, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(indiDataReceived), name: Notifications.indicators_data_received, object: nil)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.plotH.constant = (UIScreen.mainScreen().bounds.size.height-160)/4
        self.view.layoutSubviews()
    }
    
    // MARK: Plot Helpers
    func setDefaultValues(){
        scopeRaw = RAW_SCOPE
        currentView = 1
        currentRange = 5*250
        currentIndex = 0
        currentFFTIndex = 0
        currentChannel = 1
        //_chooseCannelSegment.selectedSegmentIndex = currentChannel-1
//        self.fillLabels()
//        _chnlTitle1.layer.borderWidth = 2
//        _chnlTitle1.layer.borderColor = UIColor.darkGrayColor().CGColor
//        _chnlTitle1.layer.cornerRadius = 9
//        _chnlTitle2.layer.borderWidth = 2
//        _chnlTitle2.layer.borderColor = UIColor.darkGrayColor().CGColor
//        _chnlTitle2.layer.cornerRadius = 9
//        _chnlTitle3.layer.borderWidth = 2
//        _chnlTitle3.layer.borderColor = UIColor.darkGrayColor().CGColor
//        _chnlTitle3.layer.cornerRadius = 9
//        _chnlTitle4.layer.borderWidth = 2
//        _chnlTitle4.layer.borderColor = UIColor.darkGrayColor().CGColor
//        _chnlTitle4.layer.cornerRadius = 9
    }
    func checkAndRemovePlotsViews() -> Bool {
        if self.view.viewWithTag(101) != nil{
            for i in 1...4 {
                self.view.viewWithTag(100 + i)!.removeFromSuperview()
            }
            return true
        }
        return false
    }
    
    func addPlots(){
        for vw in [View1,View2,View3,View4]{
            self.createCorePlot(vw, color: UIColor.lightGrayColor())
        }
    }
    
    func add3Plots(){
        for vw in [View1,View2,View3,View4]{
            self.create3CorePlot(vw, withColor: UIColor.darkGrayColor())
        }
    }
    
    func createPlots(){
        if currentView == 1 {
            for vw in [View1,View2,View3,View4]{
                self.createCorePlot(vw, color: UIColor.lightGrayColor())
            }
            
            if !checkAndRemovePlotsViews() {
                for i in 1...4 {
                    let viewLine: UIView = UIView(frame: CGRectMake(self.view.frame.size.width/5 * CGFloat(i), 90, 1, self.view.frame.size.height-130))
                    viewLine.backgroundColor = UIColor.lightGrayColor()
                    viewLine.tag = 100 + i
                    view.addSubview(viewLine)
                }
            }
        }
        if currentView == 2 {
            checkAndRemovePlotsViews()
            add3Plots()
        }
        if currentView == 3 {
            checkAndRemovePlotsViews()
        }
    }
    
    func create3CorePlot(view2addGraph : UIView,withColor color: UIColor){
        // Create graph from theme
        let newGraph = CPTXYGraph(frame:CGRectZero)
        let theme      = CPTTheme(named:kCPTPlainWhiteTheme)
        newGraph.applyTheme(theme)
        graphDict[view2addGraph] = newGraph
        graphIndexDict[graphDict[view2addGraph]!] = viewIndexes[view2addGraph]
        let hostingView = view2addGraph as! CPTGraphHostingView;
        hostingView.collapsesLayers = false // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
        hostingView.hostedGraph     = newGraph;
        // Setup plot space
        let plotSpace = newGraph.defaultPlotSpace as! CPTXYPlotSpace;
        plotSpace.allowsUserInteraction = true
        plotSpace.xRange                = CPTPlotRange(location:0.0, length:130)
        plotSpace.yRange                = CPTPlotRange(location:-3.0, length:23.0)
        
        // Axes
        let axisSet = newGraph.axisSet as! CPTXYAxisSet
        let x       = axisSet.xAxis!
        x.majorIntervalLength = 10
        //x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(10.0);
        x.minorTicksPerInterval = 0
        x.labelingPolicy = CPTAxisLabelingPolicy.None
        
        newGraph.plotAreaFrame?.paddingLeft = 30.0
        
        let y = axisSet.yAxis!
        y.delegate = self
        
        let axisFormatter = NSNumberFormatter()
        axisFormatter.minimumIntegerDigits = 2
        axisFormatter.maximumFractionDigits = 0
        
        let textStyle = CPTMutableTextStyle(style: CPTTextStyle())
        textStyle.fontSize = 12
        textStyle.color = CPTColor.lightGrayColor()
        y.majorIntervalLength=5
        y.minorTickLineStyle = nil
        y.labelingPolicy = CPTAxisLabelingPolicy.FixedInterval
        y.labelTextStyle = textStyle
        y.labelFormatter = axisFormatter
        
        // Create a blue plot area
        let textColorsDict = ["Blue Plot":UIColor.greenColor().CGColor,
                              "Yellow Plot":UIColor.orangeColor().CGColor,
                              "Grey Plot":UIColor.darkGrayColor().CGColor]
        
        for key in textColorsDict.keys {
            let boundLinePlot  = CPTScatterPlot()
            let lineStyle = CPTMutableLineStyle(style: CPTLineStyle())
            lineStyle.miterLimit        = 1.0
            lineStyle.lineWidth         = 2.0
            lineStyle.lineColor         = CPTColor(CGColor:textColorsDict[key]!)
            boundLinePlot.dataLineStyle = lineStyle
            boundLinePlot.identifier    = key
            boundLinePlot.delegate = self
            boundLinePlot.dataSource    = self
            newGraph.addPlot(boundLinePlot)
        }
        
        newGraph.plotAreaFrame!.borderLineStyle = nil
        newGraph.paddingLeft = 0.0;
        newGraph.paddingTop = 2.0;
        newGraph.paddingRight = 0.0;
        newGraph.paddingBottom = 2.0;
    }
    func createCorePlot( view2addGraph : UIView, color : UIColor ) { // Create graph from theme
        let newGraph = CPTXYGraph(frame: CGRectZero)
        let theme = CPTTheme(named: kCPTPlainWhiteTheme)
        newGraph.applyTheme(theme)
        graphDict[view2addGraph] = newGraph
        graphs.append(newGraph)
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
            data[i].addObject([ "index" : currentIndex , "data" : notificationData!["ch\(i+1)"]!])
            if currentIndex > currentRange {
                data[i].removeObjectAtIndex(0)
            }
        }
        
        if currentView == 1 {
            if currentIndex % limit == 0 {
                if currentIndex > currentRange {
                    for graph in graphs{
                        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
                        
                        plotSpace.xRange = CPTPlotRange(location : NSNumber(integer: (currentIndex-currentRange)), length:currentRange)
                        plotSpace.yRange = CPTPlotRange(location : NSNumber(integer: (-(scopeRaw/2))), length: scopeRaw)
       
                        graph.reloadData()
                    }
                }
            }
        }
        currentIndex = currentIndex + 1
        let lastTime = currentTime
        currentTime = NSDate.timeIntervalSinceReferenceDate()
        let diff = currentTime - lastTime
        if diff > 0.1 {
            print(diff)
            print(currentIndex)
        }
    }
    
    func indiDataReceived(notification : NSNotification){
        
    }
    func fftDataReceived(notification : NSNotification){
        
    }
    
    // MARK: Plot Data Source Methods
    
    func numberOfRecordsForPlot(plot : CPTPlot) -> UInt{
        if self.currentView == 2 {
            return UInt(dataFFT[0].count)
        }
        if currentView == 1 {
            return UInt(data[0].count)
        }
        return 0
        
    }
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
        
        let k = plot.graph as! CPTXYGraph
        let indexForData = graphIndexDict[k]
        let isX = fieldEnum == UInt(CPTScatterPlotField.X.rawValue)
        let key = isX ? "index" : "data"
        if currentView == 1 {
            
            let num = data[indexForData!][Int(idx)][key]
            return num
        }
        if currentView == 2 {
            let data = dataFFT[indexForData!][Int(idx)][key]!
            if plot.identifier!.isEqual("Blue Plot") {
                
                if key == "data" && data!["signal"] != nil {
                    return 0
                }
                let num = isX ? data : data!["data1"]
                return num
            }
            if plot.identifier!.isEqual("Yellow Plot") {
                
                if key == "data" && data!["signal"] != nil {
                    return 0
                }
                let num = isX ? data : data!["data2"]
                return num
            }
            if plot.identifier!.isEqual("Grey Plot") {
                
                if key == "data" && data!["signal"] != nil {
                    return 0
                }
                let num = isX ? data : data!["data3"]
                return num
            }
        }
        return NSNumber(double: 0.0)
    }
    // MARK: Axis Delegate Methods
    func axis(axis: CPTAxis, shouldUpdateAxisLabelsAtLocations locations: Set<NSNumber>) -> Bool {
        var positiveStyle : CPTTextStyle!
        var negativeStyle : CPTTextStyle!
        var  positiveOnce : dispatch_once_t = 0
        var  negativeOnce : dispatch_once_t = 0

        let formatter = axis.labelFormatter
        let labelOffset = axis.labelOffset
        let zero = NSDecimalNumber.zero()
        var newLabels = Set<CPTAxisLabel>()
        for tickLocation in locations {
            let theLabelTextStyle : CPTTextStyle
            if currentView == 2 {
                if tickLocation.isGreaterThanOrEqualTo(zero) {
                    dispatch_once(&positiveOnce) {
                        let newStyle = axis.labelTextStyle!.mutableCopy() as! CPTMutableTextStyle
                        newStyle.color = CPTColor.lightGrayColor()
                        positiveStyle = newStyle as CPTTextStyle
                    }
                    theLabelTextStyle = positiveStyle
                } else {
                    dispatch_once(&negativeOnce, {
                        let newStyle = axis.labelTextStyle!.mutableCopy() as! CPTMutableTextStyle
                        newStyle.color = CPTColor.lightGrayColor()
                        negativeStyle = newStyle as CPTTextStyle
                    })
                    theLabelTextStyle = negativeStyle
                }
                let labelString = formatter!.stringForObjectValue(tickLocation)
                let newLabelLayer = CPTTextLayer(text:labelString, style:theLabelTextStyle)
                let newLabel = CPTAxisLabel(contentLayer : newLabelLayer)
                newLabel.tickLocation = tickLocation
                newLabel.offset = labelOffset
                newLabels.insert(newLabel)
            }
        }
        axis.axisLabels = newLabels
        return false
    }
}
