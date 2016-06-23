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
    
    var data : [NSMutableArray]!
    var dataFFT : [NSMutableArray]!
    var plot : [UIView : CPTXYGraph]!
    var currentRange : Int!
    var scopeRaw : Int!
    var currentView : Int!
    // MARK: VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = [NSMutableArray](count: 4, repeatedValue: NSMutableArray())
        dataFFT = [NSMutableArray](count: 4, repeatedValue: NSMutableArray())
    }
    
    // MARK: Plot Helpers
    func reloadPlots() -> Bool {
        if self.view.viewWithTag(101) != nil
        {
            for i in 1...4 {
                self.view.viewWithTag(100 + i)!.removeFromSuperview()
            }
            return true
        }else {
            return false
        }
    }
    func createPlots(){
        let checkAndRemovePlotsViews : Void -> Bool = {
            if self.view.viewWithTag(101) != nil {
                for i in 1...4 {
                    self.view.viewWithTag(100 + i)!.removeFromSuperview()
                }
                return true
            }
            return false
        }
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
  
            
            self.create3CorePlot(View1, withColor: UIColor.darkGrayColor())
            self.create3CorePlot(View2, withColor: UIColor.darkGrayColor())
            self.create3CorePlot(View3, withColor: UIColor.darkGrayColor())
            self.create3CorePlot(View4, withColor: UIColor.darkGrayColor())
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
        plot[view2addGraph] = newGraph
        
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
        let boundLinePlot  = CPTScatterPlot()
        let lineStyle = CPTMutableLineStyle(style: CPTLineStyle())
        lineStyle.miterLimit        = 1.0
        lineStyle.lineWidth         = 2.0
        lineStyle.lineColor         = CPTColor(CGColor:UIColor.greenColor().CGColor)
        boundLinePlot.dataLineStyle = lineStyle
        boundLinePlot.identifier    = "Blue Plot"
        boundLinePlot.dataSource    = self
        boundLinePlot.delegate = self
        newGraph.addPlot(boundLinePlot)
        
        
        // Create a yellow plot area
        let boundLinePlot2  = CPTScatterPlot()
        let lineStyle2 = CPTMutableLineStyle(style: lineStyle)
        lineStyle2.miterLimit        = 1.0;
        lineStyle2.lineWidth         = 2.0;
        lineStyle2.lineColor         = CPTColor(CGColor:UIColor.orangeColor().CGColor)
        boundLinePlot2.dataLineStyle = lineStyle2;
        boundLinePlot2.identifier    = "Yellow Plot";
        boundLinePlot2.delegate = self
        boundLinePlot2.dataSource    = self
        newGraph.addPlot(boundLinePlot2)
        
        // Create a grey plot area
        let boundLinePlot3  = CPTScatterPlot()
        let lineStyle3 = CPTMutableLineStyle(style: lineStyle)
        lineStyle3.miterLimit        = 1.0
        lineStyle3.lineWidth         = 2.0
        lineStyle3.lineColor         = CPTColor(CGColor:UIColor.darkGrayColor().CGColor)
        boundLinePlot3.dataLineStyle = lineStyle3
        boundLinePlot3.identifier    = "Grey Plot"
        boundLinePlot3.dataSource    = self
        boundLinePlot3.delegate = self
        newGraph.addPlot(boundLinePlot3)
        
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
        plot[view2addGraph] = newGraph
        
        let hostingView = view2addGraph as! CPTGraphHostingView
        hostingView.collapsesLayers = false // Setting to true reduces GPU memory usage,but can slow drawing/scrolling hostingView.hostedGraph = newGraph
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
}