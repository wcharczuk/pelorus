//
//  GogglesTests.swift
//  GogglesTests
//
//  Created by Will Charczuk on 11/11/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import UIKit
import XCTest

class GogglesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBearingDifference() {
        // This is an example of a functional test case.
        
        var bearing_from = 90;
        var bearing_to = 270;
        
        //310 - 
        
        var result = DistanceVector.CalculateBearingDifference(90.0, to: 310.0)
        XCTAssert(result == -140.0, "Difference should be -140 deg")
        
        result = DistanceVector.CalculateBearingDifference(45.0, to: 50.0)
        XCTAssert(result == 5.0, "Difference should be 5 deg")
        
        result = DistanceVector.CalculateBearingDifference(45.0, to: 50.0)
        XCTAssert(result == 135.0, "Difference should be 135 deg")
        
        result = DistanceVector.CalculateBearingDifference(45.0, to: 50.0)
        XCTAssert(result == -140.0, "Difference should be 140 deg")
        
        result = DistanceVector.CalculateBearingDifference(45.0, to: 50.0)
        XCTAssert(result == -48.0, "Difference should be 140 deg")
    }
    
    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    */
}
