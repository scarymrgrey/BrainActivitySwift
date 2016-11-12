//
//  StatisticForCurrentSessionVC.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 30/08/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation
import CorePlot
var saveDict = [String:[NSNumber]]()
var limit : Int = 16
extension RangeReplaceableCollectionType where Generator.Element == NSNumber  {
    mutating func appendAndSaveIfNeeded(element: NSNumber, filename : String)
    {
        self.append(element)
        if saveDict[filename] == nil {
            saveDict[filename] = [NSNumber]()
        }
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
class StatisticForCurrentSessionVC : StatisticsVC {
   
    var dataForIndexKeyWasRead = [CPTPlot : Bool]()
    var dataForDataKeyWasRead = [CPTPlot:Bool]()
    var sessionId : String!
    var aniView : AnimatedSessionView!
    override var numberOfSectionsWithoutInnerContent: Int! {
        get {
           return 1
        }
        set {
        }
    }
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
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        aniView.drawCounter()
        aniView.redrawOutline(with: 20.0)
        aniView.startAnimation()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(dataReceived), name: Notifications.data_received, object: nil)
    }

    // MARK: Notifications
    func dataReceived(notification : NSNotification){
        
        let notificationData = notification.userInfo
        for (i,plot) in plotBySection.values.enumerate() {
            plotNeedToBeUpdated[plot] = true
            let filename = sessionId.fileNameForSessionFile(.Data, postfix: String(i))
            if data[plot] == nil {
                data[plot] = [NSNumber]()
            }
            data[plot]!.appendAndSaveIfNeeded(notificationData!["ch\(i+1)"] as! NSNumber,filename: filename)
        }
        if !(self.isViewLoaded() && self.view.window != nil){
            return
        }
        currentIndex = currentIndex + 1
        if (currentIndex % limit == 0) && currentlyOpenedPlots.count > 0 {
            for plot in currentlyOpenedPlots {
                if currentIndex > currentRange {
                    let plotSpace = plot.graph!.defaultPlotSpace as! CPTXYPlotSpace
                    plotSpace.xRange = CPTPlotRange(location : currentIndex-currentRange, length:currentRange)
                    plotSpace.yRange = CPTPlotRange(location : -(scopeRaw/2), length: scopeRaw)
                }
                let range = NSMakeRange(lastUpdatedIndexFor[plot]!,data[plot]!.count)
                plot.reloadDataInIndexRange(range)
            }
        }
    }
    
    
    
    // MARK:  TableView Delegates
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
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
        //let res = (data[plot]?.count) ?? 0
        return UInt(currentIndex)
    }

    override func manipulateWithData(plot : CPTPlot,field fieldEnum: UInt, recordIndexRange indexRange: NSRange) {
        let isIndex = fieldEnum == UInt(CPTScatterPlotField.X.rawValue)
        if isIndex {
            dataForIndexKeyWasRead[plot] = true
        }else {
            dataForDataKeyWasRead[plot] = true
        }
        if (dataForIndexKeyWasRead[plot] != nil && dataForDataKeyWasRead[plot] != nil) && (dataForDataKeyWasRead[plot]! && dataForIndexKeyWasRead[plot]!) {
            data[plot]!.removeFirst(indexRange.length)
            dataForIndexKeyWasRead[plot] = false
            dataForDataKeyWasRead[plot] = false
            lastUpdatedIndexFor[plot] = indexRange.location + indexRange.length
        }
    }
}
