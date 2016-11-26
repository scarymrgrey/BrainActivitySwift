//
//  CQRSTests.swift
//  BrainActivitySwift
//
//  Created by Kirill Polunin on 26/11/2016.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import XCTest
@testable import BrainActivitySwift
class CQRSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetSessionsQuery() {
         let expectation = expectationWithDescription("Alamofire")
        let context = Context(idToken: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2luY29kaW5nLmF1dGgwLmNvbS8iLCJzdWIiOiJnb29nbGUtb2F1dGgyfDExMzE4MTI2Mjg1OTg3NTA0MTIxMCIsImF1ZCI6IlVSYXdVVnFwRmxyT2Z2eVZPQ2JhcHVZNDFqeXJqdjVyIiwiZXhwIjoxNDgwMjAzMTc1LCJpYXQiOjE0ODAxNjcxNzV9.7W_1WL-hWDVnlijdEEGYNOArB4iorfYhNTV2VOEVwV4", accessToken: "xPcZ6BzPBkaLWHdj")
        let query = GetSessionsQuery(context: context)
        
        query.On(success: { (sessionResp : [GetSessionsQueryResponse]) in
            for sess in sessionResp {
                print(sess)
            }
            expectation.fulfill()
            // everething ok
        }) { () in
            XCTFail("something wrong")
        }
        waitForExpectationsWithTimeout(5) { (err) in
            print(err)
        }
    }
}
