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
        case 1...3:
            return createViewForActivityStat()
        default:
            return createTouchableViewForParameter(tableView,section: section)
        }
    }
    override func preparePlot(plot : CPTPlot, section : Int) {
        plotToFileNameDict[plot] = sessionId.fileNameForSessionFile(.Data, postfix: "0")
    }
}