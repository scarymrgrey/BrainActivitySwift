//
//  StatisticsVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 25/07/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation
import Charts
class StatisticsVC: BatteryBarVC , ChartViewDelegate ,UITableViewDelegate , UITableViewDataSource{
    
    
    @IBOutlet weak var TableView: UITableView!
    var options : NSArray!
    var parties : [String]!
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
        
        
        // setupPieChartView()
        //chartView.delegate = self
        //setDataForChart()
    }
    //MARK: Chart helpers
    func setupPieChartView(chartView: PieChartView)  {
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
    func setDataForChart(chartView: PieChartView){
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
    
    // MARK : TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
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
        case 1...3:
            let overallCellView = UIView()
            let colorView = UIView()
            let imageView = UIImageView()
            imageView.image = UIImage(named: "activity-working")
            let label = UILabel()
            label.text = "test"
            label.textColor = UIColor.whiteColor()
            overallCellView.addSubViews([colorView,label,imageView])
            colorView.backgroundColor = Colors.violet
            colorView.translatesAutoresizingMaskIntoConstraints = false
            imageView.translatesAutoresizingMaskIntoConstraints = false
            label.translatesAutoresizingMaskIntoConstraints = false
            overallCellView.Constraints(forTarget: colorView).Top(0).Bottom(0).Leading(0).Width(10)
            overallCellView.Constraints(forTarget: label).CenterY(0)
            overallCellView.Constraints(forTarget: imageView).CenterY(0).Top(5).Bottom(-5)
            overallCellView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0.0))
            overallCellView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: label, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: -5.0))
            overallCellView.addConstraint(NSLayoutConstraint(item: colorView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: imageView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: -5.0))
            overallCellView.layer.borderWidth = 1
            overallCellView.layer.borderColor = Colors.gray.CGColor
            overallCellView.backgroundColor = Colors.dgray
            return overallCellView
        default:
            let headerView = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height))
            headerView.text = "Concentration/Attention"
            //print(tableView.frame.size.width)
            headerView.tag = section
            headerView.layer.borderWidth = 1
            
            //let headerTapped = UITapGestureRecognizer (target: self, action:#selector(SessionsVC.sectionHeaderTapped(_:)))
            // headerView.addGestureRecognizer(headerTapped)
            
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
        return 1
    }
    
    @objc func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 1
    }
    
    
}