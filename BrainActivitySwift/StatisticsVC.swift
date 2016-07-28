//
//  StatisticsVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 25/07/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation
import Charts
class StatisticsVC: BatteryBarVC , ChartViewDelegate{
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var chartView: PieChartView!
    @IBOutlet weak var statTableView: UITableView!
    @IBOutlet weak var CategoryTableView: UITableView!
    var options : NSArray!
    var parties : [String]!
    override func viewDidLoad() {
        super.viewDidLoad()
        ScrollView.contentSize = CGSizeMake(self.view.frame.width, 1000)
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
        let overallController = StatOverallController()
        statTableView.delegate = overallController
        statTableView.dataSource = overallController
        let categoryController = CategoryController()
        CategoryTableView.delegate = categoryController
        CategoryTableView.dataSource = categoryController
        setupPieChartView()
        chartView.delegate = self
        setDataForChart()
        
    }
    
    //MARK: Chart helpers
    func setupPieChartView()  {
        chartView.usePercentValuesEnabled = true
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.holeRadiusPercent = 0.58
        chartView.transparentCircleRadiusPercent = 0.61
        chartView.descriptionText = ""
        chartView.setExtraOffsets(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0)
        chartView.drawCenterTextEnabled = true
        let paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        paragraphStyle.alignment = NSTextAlignment.Center
        let centerText = NSMutableAttributedString(string: "1067:38:58\nSessions Time")
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
    func setDataForChart(){
        var mult = 10.0
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
    

    
}