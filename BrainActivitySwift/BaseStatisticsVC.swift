//
//  StatisticsVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 25/07/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation
import Charts
enum StatisticType {
    case CurrentSessionStat
    case CustomSessionStat
    case OverallSessionsStat
}
class StatisticsVC: BatteryBarVC , ChartViewDelegate ,UITableViewDelegate , UITableViewDataSource ,CPTPlotDataSource{
    
    class SessionVM {
        var Time : String!
        var Id : String!
    }
    
    var TableView: UITableView!
    var options : NSArray!
    var parties : [String]!
    var arrayForBool = [Int:Bool]()
    var numberOfSectionsWithoutInnerContent : Int!
    var currentIndex  = 0
    var data  = Dictionary<CPTPlot,[NSNumber]>()
    
    var CurrentStatisticType : StatisticType!
    var currentlyOpenedPlots = [CPTPlot]()
    var currentRange : Int!
    var scopeRaw : Int!
    var viewForSection = [Int:UITableViewCell]()
    var plotBySection = [Int:CPTPlot]()
    var sectionByPlot = [CPTPlot : Int]()
    var plotNeedToBeUpdated = [CPTPlot:Bool]()
    var lastUpdatedIndexFor = [CPTPlot : Int]()
    override func viewDidLoad() {
        super.viewDidLoad()
        options = [
            ["key":"toggleValues","label":"Toggle Y-Values"],
            ["key": "toggleXValues", "label": "Toggle X-Values"],
            ["key": "togglePercent", "label": "Toggle Percent"],
            ["key": "toggleHole", "label": "Toggle Hole"],
            ["key": "animateX", "label": "Animate X"],
            ["key": "animateY", "label": "Animate Y"],
            ["key": "animateXY", "label": "Animate XY"],
            ["key": "spin", "label": "Spin"],
            ["key": "drawCenter", "label": "Draw CenterText"],
            ["key": "saveToGallery", "label": "Save to Camera Roll"],
            ["key": "toggleData", "label": "Toggle Data"]
        ]
        parties = [
            "Party A", "Party B", "Party C", "Party D", "Party E", "Party F",
            "Party G", "Party H", "Party I", "Party J", "Party K", "Party L",
            "Party M", "Party N", "Party O", "Party P", "Party Q", "Party R",
            "Party S", "Party T", "Party U", "Party V", "Party W", "Party X",
            "Party Y", "Party Z"
        ]
        
        //statTableView.registerClass(StatTableViewCell.self, forCellReuseIdentifier: "statCell")
        
        TableView.delegate = self
        TableView.dataSource = self
        TableView.contentInset = UIEdgeInsetsZero
        // setupPieChartView()
        //chartView.delegate = self
        //setDataForChart()
    }
    //MARK: Chart helpers
    func setupPieChartView(chartView: PieChartView)  {
        chartView.usePercentValuesEnabled = true
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.holeRadiusPercent = 0.58
        chartView.transparentCircleRadiusPercent = 0
        chartView.descriptionText = ""
        chartView.setExtraOffsets(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0)
        chartView.drawCenterTextEnabled = true
        let paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        paragraphStyle.alignment = NSTextAlignment.Center
        let centerText = NSMutableAttributedString(string: "1067:38:58\n Sessions Time")
        centerText.setAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Light",size: 10.0)!,
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSParagraphStyleAttributeName : paragraphStyle], range: NSMakeRange(0, centerText.length))
        centerText.setAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Light",size: 8.0)!,
            NSForegroundColorAttributeName : UIColor.whiteColor()], range: NSMakeRange(10, centerText.length - 10))
        
        chartView.centerAttributedText = centerText
        
        chartView.drawHoleEnabled = true
        chartView.rotationAngle = 0.0
        chartView.rotationEnabled = true
        chartView.highlightPerTapEnabled = true
        //chartView.backgroundColor = Colors.gray
        chartView.holeColor = Colors.gray
        chartView.legend.enabled = false
    }
    func setDataForChart(chartView: PieChartView){
        let mult = 10.0
        let count = 8
        var yVals1 = [BarChartDataEntry]()
        
        // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
        for i in 0..<count
        {
            yVals1.append(BarChartDataEntry(value:Double(arc4random_uniform(UInt32(mult))) + mult/5,xIndex:i))
        }
        
        var xVals = [String]()
        
        for i in 0..<count
        {
            xVals.append(parties[i % parties.count])
        }
        
        let dataSet = PieChartDataSet(yVals:yVals1, label:"Election Results")
        dataSet.sliceSpace = 1.0;
        
        // add a lot of colors
        
        dataSet.colors = [Colors.lblue,Colors.lgreen,Colors.yellow,Colors.red,Colors.violet,Colors.orange]
        
        let data = PieChartData(xVals:xVals, dataSet:dataSet)
        
        chartView.drawSliceTextEnabled = false
        data.setDrawValues(false)
        chartView.data = data
        chartView.animate(xAxisDuration : 1.4 ,easingOption:ChartEasingOption.EaseOutBack)
        //chartView.highlightValues(nil)
    }
    
    // MARK : TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        preconditionFailure("This method must be overridden")
    }
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("cellForRowAtIndexPath() \(indexPath)" )
        if indexPath.section < numberOfSectionsWithoutInnerContent  {
            return UITableViewCell()
        }
        if arrayForBool[indexPath.section]! {
            
            if viewForSection[indexPath.section] == nil {
                let cell = tableView.dequeueReusableCellWithIdentifier("cellForStatisticPlot") as! PlotStatCell
                let plot = createCorePlot(cell.innerView)
                preparePlot(plot,section: indexPath.section)
                viewForSection[indexPath.section] = cell
            }
            return viewForSection[indexPath.section]!
        }
        return UITableViewCell()
    }
    func preparePlot(plot : CPTPlot,section : Int){
        print("preparePlot()" )
        plotBySection[section] = plot
        sectionByPlot[plot] = section
        plotNeedToBeUpdated[plot] = true
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("numberOfRowsInSection()" )
        return 1
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        preconditionFailure("This method must be overridden")
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        print("heightForHeaderInSection()" )
        if section == 0 {
            return 240
        }
        return 40
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        print("heightForHeaderInSection() \(indexPath)" )
        if indexPath.section < numberOfSectionsWithoutInnerContent {
            return 0
        }
        if let isSectionOpened = arrayForBool[indexPath.section] {
            if isSectionOpened{
                return 150
            }
        }else {
            arrayForBool[indexPath.section] = false
        }
        return 0
    }
    // MARK : gesture Recognizers
    
    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        print("sectionHeaderTapped()" )
        let section  = recognizer.view?.tag as Int!
        arrayForBool[section] = !(arrayForBool[section]!)
        
//        if arrayForBool[section]! {
//            currentlyOpenedPlots.append(plotBySection[section]!)
//        }else{
//            let closedPlotIndex = currentlyOpenedPlots.indexOf(plotBySection[section]!)
//            currentlyOpenedPlots.removeAtIndex(closedPlotIndex!)
//        }
        //reload specific section animated
        let range = NSMakeRange(section, 2)
        let sectionToReload = NSIndexSet(indexesInRange: range)
        TableView.reloadSections(sectionToReload, withRowAnimation: .Fade)
        
    }
    
    // MARK: =CorePlot=
    func createCorePlot( view2addGraph : UIView) -> CPTPlot { // Create graph from theme
        print("createCorePlot()")
        let newGraph = CPTXYGraph(frame: CGRectZero)
        let theme = CPTTheme(named: kCPTPlainWhiteTheme)
        newGraph.applyTheme(theme)
        
        let hostingView = view2addGraph as! CPTGraphHostingView
        let bg = CPTColor(CGColor: Colors.dgray.CGColor)
        hostingView.collapsesLayers = false // Setting to true reduces GPU memory usage,but can slow drawing/scrolling hostingView
        hostingView.hostedGraph = newGraph
        // Setup plot space
        let plotSpace = newGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = false
        plotSpace.xRange = CPTPlotRange(location:  0.0,length: currentRange )
        plotSpace.yRange = CPTPlotRange(location: 0,length : 150000)
        // Axes
        let axisSet = newGraph.axisSet as! CPTXYAxisSet
        let x = axisSet.xAxis!
        x.labelingPolicy = CPTAxisLabelingPolicy.None
        
        let y = axisSet.yAxis!
        y.majorIntervalLength = 10000
        y.minorTicksPerInterval = 0
        y.delegate = self
        
        // Create a blue plot area
        let boundLinePlot = CPTScatterPlot()
        let lineStyle = CPTMutableLineStyle()
        lineStyle.miterLimit = 1.0
        lineStyle.lineWidth = 1.0
        lineStyle.lineColor = CPTColor(CGColor: UIColor.whiteColor().CGColor)
        boundLinePlot.dataLineStyle = lineStyle
        boundLinePlot.identifier = "plotID"
        boundLinePlot.dataSource = self
        
        newGraph.plotAreaFrame!.borderLineStyle = nil
        newGraph.addPlot(boundLinePlot)
        newGraph.paddingLeft = 0.0
        newGraph.paddingTop = 0.0
        newGraph.paddingRight = 0.0
        newGraph.paddingBottom = 0.0
        newGraph.plotAreaFrame?.fill = CPTFill(color: bg)
        
        let areaColor = CPTColor(CGColor: Colors.orange.CGColor)
        let areaGradient = CPTGradient(beginningColor:CPTColor.clearColor() ,endingColor: areaColor)
        areaGradient.angle = -90
        
        let areaGradientFill = CPTFill(gradient:areaGradient)
        boundLinePlot.areaFill = areaGradientFill
        boundLinePlot.areaBaseValue = 0
        
        // red
        let bandRange = CPTPlotRange(location: 500, length: 400)
        let bandFill = CPTFill(color: CPTColor(CGColor: Colors.gray.CGColor))
        x.addBackgroundLimitBand(CPTLimitBand(range: bandRange,fill: bandFill))
        lastUpdatedIndexFor[boundLinePlot] = 0
        return boundLinePlot
    }
    
    // MARK: Plot Data Source Methods
    func numberOfRecordsForPlot(plot : CPTPlot) -> UInt{
        preconditionFailure("This method must be overridden")
    }
    func numbersForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndexRange indexRange: NSRange) -> [AnyObject]? {
        print("numbersForPlot()")
        if data[plot] == nil{
            return nil
        }
        let isIndex = fieldEnum == UInt(CPTScatterPlotField.X.rawValue)
        var res = [NSNumber]()
        if isIndex {
            for i in indexRange.toRange()! {
                res.append(NSNumber(int: Int32(i)))
            }
        }else{
            print(indexRange.length)
            print(data[plot]?.count)
            for i in 0..<indexRange.length {
                let num = data[plot]![i].copy() as! NSNumber
                res.append(num)
            }
            
        }
        //print("data for: \(indexRange) - index: \(plotIndex) - key:\(key)")
        manipulateWithData(plot,field: fieldEnum,recordIndexRange: indexRange)
        return res
    }
    func manipulateWithData(plot : CPTPlot,field fieldEnum: UInt,recordIndexRange indexRange: NSRange){
    }
    // MARK: - Create Cell Helpers
    internal func createViewForActivityStat() -> UIView{
        let overallCellView = UIView()
        let colorView = UIView()
        let imageView = UIImageView()
        let timeLabel = UILabel()
        // add left border to UILabel
        let leftLine = CALayer()
        leftLine.frame = CGRectMake(0, 0, 2,40)
        leftLine.backgroundColor = Colors.gray.CGColor
        timeLabel.layer.addSublayer(leftLine)
        timeLabel.text = "302:20:20"
        timeLabel.textAlignment = .Center
        timeLabel.textColor = UIColor.whiteColor()
        imageView.image = UIImage(named: "activity-working")?.imageWithRenderingMode(.AlwaysTemplate)
        imageView.tintColor = UIColor.whiteColor()
        let label = UILabel()
        label.text = "Working"
        label.textColor = UIColor.whiteColor()
        overallCellView.addSubViews([colorView,label,imageView,timeLabel])
        colorView.backgroundColor = Colors.violet
        colorView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        overallCellView.Constraints(forTarget: colorView).Top(0).Bottom(0).Leading(0).Width(10)
        overallCellView.Constraints(forTarget: label).CenterY(0)
        overallCellView.Constraints(forTarget: imageView).CenterY(0).Top(5).Bottom(-5)
        overallCellView.Constraints(forTarget: timeLabel).Top(0).Bottom(0).Trailing(0)
        overallCellView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0.0))
        overallCellView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: label, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: -5.0))
        overallCellView.addConstraint(NSLayoutConstraint(item: colorView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: -5.0))
        overallCellView.addConstraint(NSLayoutConstraint(item: timeLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: overallCellView, attribute: NSLayoutAttribute.Width, multiplier: 2.0/5.0, constant: 0.0))
        overallCellView.layer.borderWidth = 1
        overallCellView.layer.borderColor = Colors.gray.CGColor
        overallCellView.backgroundColor = Colors.dgray
        return overallCellView
    }
    internal func createTouchableViewForParameter(tableView : UITableView,section : Int) -> UIView{
        let headerView = UIView()
        let label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height))
        label.text = "Concentration/Attention"
        label.textAlignment = .Center
        label.textColor = Colors.gray
        //print(tableView.frame.size.width)
        label.tag = section
        label.layer.borderWidth = 1
        label.layer.borderColor = Colors.gray.CGColor
        headerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.Constraints(forTarget: label).Top(0).Bottom(0).Trailing(0).Leading(0)
        let headerTapped = UITapGestureRecognizer (target: self, action:#selector(StatisticsVC.sectionHeaderTapped(_:)))
        headerView.addGestureRecognizer(headerTapped)
        headerView.tag = section
        return headerView
    }
    internal func createPieChart(tableView : UITableView) -> UIView{
        let chartViewContainer = UIView()
        let chartView = PieChartView(frame: CGRectMake(0, 0, tableView.frame.size.width-40, tableView.frame.size.height-5))
        
        setupPieChartView(chartView)
        chartView.delegate = self
        setDataForChart(chartView)
        
        chartViewContainer.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartViewContainer.Constraints(forTarget: chartView).CenterX(0).CenterY(0).Top(10)
        chartViewContainer.addConstraint(NSLayoutConstraint(item: chartView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: chartView, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0.0))
        chartViewContainer.backgroundColor = Colors.gray
        return chartViewContainer
    }
}