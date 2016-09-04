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
    var sessionId: String!
    var plotToFileNameDict = [CPTPlot:String]()
    override  var TableView : UITableView! {
        get {
            return self.Table
        }
        set {
            //self.TableView = newValue
        }
    }
    override var numberOfSectionsWithoutInnerContent: Int {
        get {
            return 3
        }
        set {}
    }
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        for (i , plot) in plotBySection.values.enumerate() {
            let fileName = sessionId.fileNameForSessionFile(.Data, postfix: String(i))
            data[plot] = binaryFileHelper.readArrayFromPlist(fileName)
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
    // MARK: Coreplot datasource
    override func numberOfRecordsForPlot(plot : CPTPlot) -> UInt{
        //let res = (data[plot]?.count) ?? 0
        return UInt(currentIndex)
    }

}