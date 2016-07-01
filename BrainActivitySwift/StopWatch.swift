//
//  File.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 28/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation

class StopWatch {
    static var currentTime = NSDate.timeIntervalSinceReferenceDate()
    static func setNow(){
        currentTime = NSDate.timeIntervalSinceReferenceDate()
    }
    static func getInfo(desc : String){
        let time = NSDate.timeIntervalSinceReferenceDate()
        let past = time - currentTime
        print("\(1/past) Hz : delay \(past) - \(desc)")
        currentTime = time
    }
}