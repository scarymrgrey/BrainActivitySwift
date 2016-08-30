//
//  StatisticForCurrentSessionVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 30/08/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation

class StatisticForCurrentSessionVC : StatisticsVC{
    
    @IBOutlet weak var Table : UITableView!
    
    override  var TableView : UITableView! {
        get {
            return self.Table
        }
        set {
            //self.TableView = newValue
        }
    }
    var dataForIndexKeyWasRead = [Bool](count : 4,repeatedValue : false)
    var dataForDataKeyWasRead = [Bool](count : 4,repeatedValue : false)
    var currentlySelectedPlot : CPTPlot!
    var currentRange : Int!
    var scopeRaw : Int!
    var currentIndex  = 0
    var data  = [[Dictionary<String,AnyObject>]](count: 4, repeatedValue: [Dictionary<String,AnyObject>]())
    var limit : Int = 16
    var lastIndexUpdated  = 0
    var plotToIndexPathDict = [Int:CPTPlot]()
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(dataReceived), name: Notifications.data_received, object: nil)
    }
    
    // MARK: Notifications
    func dataReceived(notification : NSNotification){
        
        let notificationData = notification.userInfo
        for i in 0...3 {
            data[i].append([ "index" : currentIndex , "data" : notificationData!["ch\(i+1)"] as! NSNumber])
        }
        if !(self.isViewLoaded() && self.view.window != nil){
            return
        }
        currentIndex = currentIndex + 1
        if (currentIndex % limit == 0) && currentlySelectedPlot != nil {
            let r = currentIndex > currentRange
                if r {
                    let plotSpace = currentlySelectedPlot.graph!.defaultPlotSpace as! CPTXYPlotSpace
                    plotSpace.xRange = CPTPlotRange(location : currentIndex-currentRange, length:currentRange)
                    plotSpace.yRange = CPTPlotRange(location : -(scopeRaw/2), length: scopeRaw)
                }
                currentlySelectedPlot.insertDataAtIndex(UInt(lastIndexUpdated), numberOfRecords: UInt(limit))
        }
    }
    
    override func preparePlot(plot : CPTPlot,row : Int) {
        plotToIndexPathDict[row] = plot
    }
    override func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        super.sectionHeaderTapped(recognizer)
        let indexPath  = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
        currentlySelectedPlot = plotToIndexPathDict[indexPath.row]!
        currentlySelectedPlot.insertDataAtIndex(UInt(lastIndexUpdated), numberOfRecords: UInt(limit))
    }
    
    // MARK:  TableView Delegates
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0:
            aniView = UINib(nibName: "AnimatedSessionView", bundle:nil).instantiateWithOwner(AnimatedSessionView.self,
                                                                                             options: nil)[0] as! AnimatedSessionView
            aniView.backgroundColor = Colors.orange
            return aniView
        default:
            return createTouchableViewForParameter(tableView,section: section)
        }
    }
    
    // MARK: Coreplot datasource 
    override func numberOfRecordsForPlot(plot : CPTPlot) -> UInt{
        return UInt(currentIndex)
    }
    override func numbersForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndexRange indexRange: NSRange) -> [AnyObject]? {
        if currentIndex == 0{
            return nil
        }

        let isIndex = fieldEnum == UInt(CPTScatterPlotField.X.rawValue)
        let key = isIndex ? "index" : "data"
        //print("data for: \(indexRange) - index: \(plotIndex) - key:\(key)")
        var res = [NSNumber](count:limit,repeatedValue : NSNumber())
        for i in 0..<limit {
            
            let num = data[0][i][key]!.copy() as! NSNumber
            res[i] = (num)
            
        }
        if isIndex {
            dataForIndexKeyWasRead[0] = true
        }else {
            dataForDataKeyWasRead[0] = true
        }
        if dataForIndexKeyWasRead[0]
            && dataForDataKeyWasRead[0] {
            var dataToWrite = [Float]()
            for i in 0..<limit {
                dataToWrite.append(data[0][i]["data"] as! Float)
            }
            dispatch_async(dispatch_get_main_queue()){
                let fileNameToWrite = self.sessionId.fileNameForSessionFile(.Data, postfix: String(0))
                let fileNameToWriteStress = self.sessionId.fileNameForSessionFile(.StressLevel, postfix: "")
                binaryFileHelper.writeArrayToPlist(fileNameToWrite,array: dataToWrite)
                binaryFileHelper.writeArrayToPlist(fileNameToWriteStress, array: [5.0])
                //print(binaryFileHelper.readArrayFromPlist(fileNameToWrite))
            }
            data[0].removeFirst(limit)
            
            //print("Data for plot \(plotIndex) was DELETED at currentIndex = \(currentIndex).")
            dataForIndexKeyWasRead[0] = false
            dataForDataKeyWasRead[0] = false
            lastIndexUpdated = indexRange.location + indexRange.length
        }
        return res
    }
}