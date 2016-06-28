//
//  SpectrumVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 21/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//
import UIKit
class SpectrumVC: UIViewController , CPTPlotDataSource, CPTAxisDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var View1: CPTGraphHostingView!
    @IBOutlet weak var View2: CPTGraphHostingView!
    @IBOutlet weak var View3: CPTGraphHostingView!
    @IBOutlet weak var View4: CPTGraphHostingView!
    
    // MARK: Local Variables
    let RAW_SCOPE = 200000
    var dataFFT : [[Dictionary<String,AnyObject>]]!
    var graphDict = [UIView : CPTXYGraph]()
    var graphIndexDict = [CPTXYGraph : Int]()
    var currentRange : Int!
    var scopeRaw : Int!
    var viewIndexes = [UIView:Int]()
    var plotH = NSLayoutConstraint()
    var limit : Int = 10
    var currentFFTIndex = 0
    var currentChannel = 1
    var graphs = [CPTXYGraph]()
    // MARK: VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (SDiPhoneVersion.deviceVersion() == .iPhone6 || SDiPhoneVersion.deviceVersion() == .iPhone6Plus){
            limit = 8;
        }
        setDefaultValues()
        viewIndexes = [View1:0 , View2:1 , View3:2,View4:3]
        
        dataFFT = [[Dictionary<String,AnyObject>]](count: 4, repeatedValue: [Dictionary<String,AnyObject>]())
        createPlots()
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(dataReceived), name: Notifications.data_received, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(fftDataReceived), name: Notifications.fft_data_received, object: nil)
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(indiDataReceived), name: Notifications.indicators_data_received, object: nil)
        
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
        currentFFTIndex = 0
        currentChannel = 1
    }
    
    func createPlots(){
        for vw in [View1,View2,View3,View4]{
            self.create3CorePlot(vw, withColor: UIColor.darkGrayColor())
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
    // MARK: Notifications
    func fftDataReceived(notification : NSNotification){
  
        
        let notificationData = notification.userInfo
        
        for i in 0...3 {
            dataFFT[i].append([ "index" : currentFFTIndex , "data" : notificationData!["ch\(i+1)"]!])
            if currentFFTIndex > 119 {
                dataFFT[i].removeFirst()
            }
            //print("data[\(i)].count = \(dataFFT[i].count) ; currentIndex = \(currentFFTIndex) ; currentRange = \(currentRange) ; notificationData[ch\(i+1)] = \(notificationData!["ch\(i+1)"]!)")
        }
        
       
        for graph in self.graphDict.values{
            if(currentFFTIndex > 119){
                let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
                plotSpace.xRange = CPTPlotRange(location: currentFFTIndex - 120, length:130)
            }
            graph.reloadData()
        }
        currentFFTIndex += 1
    }
    
    // MARK: Plot Data Source Methods
    
    func numberOfRecordsForPlot(plot : CPTPlot) -> UInt{
        return UInt(dataFFT.first!.count)
    }
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
        
        let k = plot.graph as! CPTXYGraph
        let indexForData = graphIndexDict[k]
        let isX = fieldEnum == UInt(CPTScatterPlotField.X.rawValue)
        let key = isX ? "index" : "data"
        
        let data = dataFFT[indexForData!][Int(idx)][key]!
        let dict = ["Blue Plot" : "1","Yellow Plot" : "2","Grey Plot" : "3"]
        let value = dict[plot.identifier as! String]!
        let d = data["signal"] as? UInt
        if (key == "data") && (d != nil) {
            return 0
        }
        if !isX{
            print("data[data\(value)]= \(data["data\(value)"] as? UInt)")
        }
        let num = isX ? data : data["data\(value)"] as! UInt
        return num
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
        axis.axisLabels = newLabels
        return false
    }
}
