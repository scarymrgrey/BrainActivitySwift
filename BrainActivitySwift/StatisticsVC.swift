//
//  StatisticsVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 25/07/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation
import Charts
class StatisticsVC: BatteryBarVC , ChartViewDelegate ,UITableViewDelegate , UITableViewDataSource ,CPTPlotDataSource{
    
    class SessionVM {
        var Time : String!
        var Id : String!
    }
    
    @IBOutlet weak var TableView: UITableView!
    var options : NSArray!
    var parties : [String]!
    var arrayForBool : [Bool]! = []
    var activityCellCount = 3
    var plotToFileNameDict = [CPTPlot:String]()
    var sessionId : String!
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
        arrayForBool = [Bool](count:3,repeatedValue : false)
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
        return 7
    }
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section <= activityCellCount {
            return UITableViewCell()
        }
        let cell = UITableViewCell()
        let innerView = CPTGraphHostingView()
        
        innerView.backgroundColor = UIColor.blueColor()
        cell.addSubview(innerView)
        cell.Constraints(forTarget: innerView).AspectFill()
        let filename = sessionId.fileNameForSessionFile(.Data, postfix: "0")
        createCorePlot(innerView, color: UIColor.whiteColor(),fileName: filename)
        return cell
    }
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    @objc func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
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
        case 1...activityCellCount:
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
        default:
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
            
            return headerView
        }
        
    }
    @objc func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 240
        }
        return 40
    }
    
    @objc func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    @objc func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section <= activityCellCount {
            return 0
        }
        if arrayForBool[indexPath.section-activityCellCount - 1]{
            return 100
        }
        return 0
    }
    // MARK : gesture Recognizers
    
    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        let indexPath  = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
        if (indexPath.row == 0) {
            var collapsed = arrayForBool[indexPath.section]
            collapsed       = !collapsed
            arrayForBool[indexPath.section] = collapsed
            //reload specific section animated
            let range = NSMakeRange(indexPath.section, 1)
            let sectionToReload = NSIndexSet(indexesInRange: range)
            TableView.reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Fade)
        }
    }
    
    // MARK: =CorePlot=
    func createCorePlot( view2addGraph : UIView, color : UIColor ,fileName : String) { // Create graph from theme
        let newGraph = CPTXYGraph(frame: CGRectZero)
        let theme = CPTTheme(named: kCPTPlainWhiteTheme)
        newGraph.applyTheme(theme)

        let hostingView = view2addGraph as! CPTGraphHostingView
        let bg = CPTColor(CGColor: Colors.dgray.CGColor)
        hostingView.collapsesLayers = false // Setting to true reduces GPU memory usage,but can slow drawing/scrolling hostingView.hostedGraph = newGraph
        hostingView.hostedGraph = newGraph
        // Setup plot space
        let plotSpace = newGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = false
        plotSpace.xRange = CPTPlotRange(location:  0.0,length: 1000 )
        plotSpace.yRange = CPTPlotRange(location: 0,length : 150000)
        // Axes
        let axisSet = newGraph.axisSet as! CPTXYAxisSet
        let x = axisSet.xAxis!
        //x.alternatingBandFills = [CPTFill(color: CPTColor(CGColor: Colors.lblue.CGColor)),CPTFill(color: CPTColor(CGColor:Colors.lgreen.CGColor))]
        //axisSet.yAxis!.hidden = true
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
        boundLinePlot.identifier = "plotID"
        boundLinePlot.dataSource = self
        plotToFileNameDict[boundLinePlot] = fileName
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
       
    }
    
    // MARK: Plot Data Source Methods
    
    func numberOfRecordsForPlot(plot : CPTPlot) -> UInt{
        return UInt(1000)
    }
    func numbersForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndexRange indexRange: NSRange) -> [AnyObject]? {
        print(plotToFileNameDict)
        let fileName = plotToFileNameDict[plot ]
       
        let isIndex = fieldEnum == UInt(CPTScatterPlotField.X.rawValue)
        var res = [NSNumber](count:1000,repeatedValue : NSNumber())
        if isIndex {
            for i in indexRange.toRange()! {
                res [i] = NSNumber(int: Int32(i))
            }
        }else{
            let arr = binaryFileHelper.readArrayFromPlist(fileName!)!
            for i in 0 ..< 1000 {
                res[i] = NSNumber(float: arr[i])
            }
        }
        //print("data for: \(indexRange) - index: \(plotIndex) - key:\(key)")
        return res
    }
    // MARK: Axis Delegate Methods
    func axis(axis: CPTAxis, shouldUpdateAxisLabelsAtLocations locations: Set<NSNumber>) -> Bool {
        return false
    }
}