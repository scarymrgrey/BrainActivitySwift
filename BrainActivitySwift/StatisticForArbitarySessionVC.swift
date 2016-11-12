//
//  StatisticForArbitarySessionVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 30/08/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation
import CorePlot
class StatisticForArbitarySessionVC : StatisticsVC{
    @IBOutlet weak var Table : UITableView!
    var sessionId: String!
    var plotToFileNameDict = [CPTPlot:String]()
    var plotNumber = 0
    
    override  var TableView : UITableView! {
        get {
            return self.Table
        }
        set {
            self.Table = newValue
        }
    }
    override var numberOfSectionsWithoutInnerContent: Int! {
        get {
            return 4
        }
        set {}
    }
    // MARK: VC Lifecycle
    // MARK: Helpers
    func setDefaultValues(){
        scopeRaw = 200000
        currentRange = 5*250
        currentIndex = 0
    }
    // MARK: VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaultValues()
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
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 8
    }
    override func preparePlot(plot: CPTPlot, section: Int) {
        super.preparePlot(plot, section: section)
        let fileName = sessionId.fileNameForSessionFile(.Data, postfix: String(plotNumber))
        data[plot] = binaryFileHelper.readArrayFromPlist(fileName)
        plotNumber += 1
    }
    // MARK: Coreplot datasource
    override func numberOfRecordsForPlot(plot : CPTPlot) -> UInt{
        let res = (data[plot]?.count) ?? 0
        return UInt(res)
    }
}
