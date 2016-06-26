//
//  BrainActivitySwiftTests.swift
//  BrainActivitySwiftTests
//
//  Created by Victor Gelmutdinov on 26/06/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import XCTest
import UIKit
@testable import BrainActivitySwift
class BrainActivitySwiftTests: XCTestCase {
    var rawVC : RawVC!
    override func setUp() {
        super.setUp()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        rawVC = storyboard.instantiateViewControllerWithIdentifier("RawVCId") as! RawVC
        rawVC.loadView()
        rawVC.viewDidLoad()
        //let _ = rawVC.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        
        let not = NSNotification(name: "notifi", object: nil, userInfo: [  "ch1" : "-123.40",
            "ch2" : "123.40",
            "ch3" : "-223.40",
            "ch4" : "444.40"])

        self.measureBlock {
        self.rawVC.dataReceived(not)
        }
    }
    
}
