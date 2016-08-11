		//
//  BinaryFileHelper.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 06/08/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation


class BinaryFileHelper {
    func writeArrayToPlist(filename : String,array: [Float]) {
        if let fileUrl = createArrayPath(filename) {
            if !NSFileManager.defaultManager().fileExistsAtPath(fileUrl.path!) {
                NSFileManager.defaultManager().createFileAtPath(fileUrl.path!, contents: nil, attributes: nil)
            }
                if let fileHandle = NSFileHandle(forWritingAtPath: fileUrl.path!) {
                    fileHandle.seekToEndOfFile()
                    let nData = NSMutableData(capacity: 0)
                    nData?.appendBytes(array, length: array.count * sizeof(Float))
                    
                    fileHandle.writeData(nData!)
                    fileHandle.closeFile()
                }
                else {
                    print("Can't open fileHandle")
                }
        }
    }
    
    func readArrayFromPlist(filename : String) -> [Float]? {
        if let arrayPath = createArrayPath(filename) {
            let file: NSFileHandle? = NSFileHandle(forReadingAtPath: arrayPath.path!)
            
            if file == nil {
                print("File open failed")
            } else {
                
                let databuffer = file!.readDataToEndOfFile()
                var res = [Float](count: databuffer.length / sizeof(Float),repeatedValue : 0.0)
                databuffer.length
                file!.closeFile()
                databuffer.getBytes(&res)
                return res
            }
        }
        return nil
    }
    
    func createArrayPath (filename : String) -> NSURL? {
        let dir:NSURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.CachesDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last! as NSURL
        let fileurl =  dir.URLByAppendingPathComponent(filename)
        return fileurl
    }
}