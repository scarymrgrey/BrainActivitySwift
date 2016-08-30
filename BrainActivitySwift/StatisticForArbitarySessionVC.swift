//
//  StatisticForArbitarySessionVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 30/08/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation

class StatisticForArbitarySessionVC : StatisticsVC{
    @IBOutlet weak var Table : UITableView!
    var plotToFileNameDict = [CPTPlot:String]()
    override  var TableView : UITableView! {
        get {
            return self.Table
        }
        set {
            self.TableView = newValue
        }
    }
    // MARK: TableView delegates
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0:
            return createPieChart(tableView)
        case 1...activityCellCount:
            return createViewForActivityStat()
        default:
            return createTouchableViewForParameter(tableView,section: section)
        }
    }
    
    override func numbersForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndexRange indexRange: NSRange) -> [AnyObject]? {
        print(plotToFileNameDict)
        let fileName = plotToFileNameDict[plot]
        
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
    
    override func preparePlot(plot : CPTPlot, row : Int) {
        plotToFileNameDict[plot] = sessionId.fileNameForSessionFile(.Data, postfix: "0")
    }
}