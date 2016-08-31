//
//  StatisticForCurrentSessionVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 30/08/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation
var saveDict = [String:[NSNumber]]()
var limit : Int = 16
extension RangeReplaceableCollectionType where Generator.Element == NSNumber  {
    mutating func appendAndSaveIfNeeded(element: NSNumber, filename : String)
    {
        self.append(element)
        saveDict[filename]!.append(element)
        if saveDict[filename]!.count == limit {
            saveBuffer(filename)
            
        }
    }
    func saveBuffer(filename : String){
        
        let arrayToSave =  saveDict[filename]?.map{ number -> Float in
            Float(number)
        }
        if let arr = arrayToSave {
            dispatch_async(dispatch_get_main_queue()){
                binaryFileHelper.writeArrayToPlist(filename, array: arr )
            }
            saveDict[filename]!.removeAll()
        }
    }
}
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
    var dataForIndexKeyWasRead = [CPTPlot : Bool]()
    var dataForDataKeyWasRead = [CPTPlot:Bool]()
    var currentlySelectedPlot : CPTPlot!



    
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
        aniView.drawCounter()
        aniView.redrawOutline(with: 0.0)
        aniView.startAnimation()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(dataReceived), name: Notifications.data_received, object: nil)
    }
    
    // MARK: Notifications
    func dataReceived(notification : NSNotification){
        
        let notificationData = notification.userInfo
        for (i,plot) in plotToIndexPathDict.values.enumerate() {
            let filename = sessionId.fileNameForSessionFile(.Data, postfix: String(i))
            data[plot]!.appendAndSaveIfNeeded(notificationData!["ch\(i+1)"] as! NSNumber,filename: filename)
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

    override func manipulateWithData(plot : CPTPlot,field fieldEnum: UInt, recordIndexRange indexRange: NSRange) {
        let isIndex = fieldEnum == UInt(CPTScatterPlotField.X.rawValue)
        if isIndex {
            dataForIndexKeyWasRead[plot] = true
        }else {
            dataForDataKeyWasRead[plot] = true
        }
        if dataForIndexKeyWasRead[plot]!
            && dataForDataKeyWasRead[plot]! {
            data[plot]!.removeFirst(indexRange.length)
            
            //print("Data for plot \(plotIndex) was DELETED at currentIndex = \(currentIndex).")
            dataForIndexKeyWasRead[plot] = false
            dataForDataKeyWasRead[plot] = false
            lastIndexUpdated = indexRange.location + indexRange.length
        }
    }
}