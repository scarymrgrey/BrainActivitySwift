//
//  WrapperTests.swift
//  BrainActivitySwift
//
//  Created by Kirill Polunin on 23/11/2016.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import XCTest
@testable import BrainActivitySwift
class WrapperTests: XCTestCase {
    func XCTAssertNoThrowValidateValue<T>(@autoclosure expression: () throws -> T, _ message: String = "", _ validator: (T) -> Bool) {
        do {
            let result = try expression()
            XCTAssert(validator(result), "Value validation failed - \(message)")
        } catch let error {
            XCTFail("Caught error: \(error) - \(message)")
        }
    }
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_should_fail_when_attach_before_init() {
        let wrapper = SDKWrapper()
        XCTAssertThrowsError( try wrapper.attachDS({(a, b, c) in}))
    }
    
    func test_should_NOT_fail_when_attach_after_init() {
        let wrapper = SDKWrapper()
        wrapper.startSystem()
        do{
            try wrapper.attachDS({(a, b, c) in})
        }catch let error{
            XCTFail("Caught error: \(error)")
        }
    }
    
    func testPerformanceExample() {
        self.measureBlock {
        }
    }
}
