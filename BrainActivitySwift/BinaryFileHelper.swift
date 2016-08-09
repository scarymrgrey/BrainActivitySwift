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
                var err:NSError?
                if let fileHandle = NSFileHandle(forWritingAtPath: fileUrl.path!) {
                    fileHandle.seekToEndOfFile()
                    
                    let data =  NSKeyedArchiver.archivedDataWithRootObject(array)
                    fileHandle.writeData(data)
                    fileHandle.closeFile()
                }
                else {
                    print("Can't open fileHandle \(err)")
                }
            
        }
    }
    
    func readArrayFromPlist(filename : String) -> [Float]? {
        if let arrayPath = createArrayPath(filename) {
            if let nsdataFromFile = NSFileManager.defaultManager().contentsAtPath(arrayPath.path!)  {
                return NSKeyedUnarchiver.unarchiveObjectWithData(nsdataFromFile) as? [Float]
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