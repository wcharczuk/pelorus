//
//  GogglesTests.swift
//  GogglesTests
//
//  Created by Will Charczuk on 11/11/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import UIKit
import XCTest

class PelorusTests: XCTestCase {
    
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
        
        var result = CompassUtil.CalculateBearingDifference(90.0, to: 310.0)
        XCTAssert(result == -140.0, "Difference should be -140 deg")
        
        result = CompassUtil.CalculateBearingDifference(45.0, to: 50.0)
        XCTAssert(result == 5.0, "Difference should be 5 deg")
        
        //-135
        //-45
    }
    
    func testFixedQueue() {
        
        //test basic enqueuing, peeking, dequeueing with a fixed length
        var queue = FixedQueue<Int>(maxLength: 5)
        for i : Int in 1...6 {
            queue.Enqueue(i)
        } // 1, 12, 123, 1234, 12345, 23456
        let peeked = queue.Peek()!
        XCTAssert(peeked == 2, "We should have pushed out 1 and be left with 2")
        let dequeued = queue.Dequeue()
        XCTAssert(peeked == dequeued, "Previous peek and the dequeued elem should be the same")
        let new_peeked = queue.Peek()
        XCTAssert(new_peeked == 3, "3 should be next")
        let new_dequeued = queue.Dequeue()
        XCTAssert(new_peeked == new_dequeued, "Previous peek and the dequeued elem should be the same")
        
        //reverse
        var reversed = queue.Reverse()
        var reversed_peeked = reversed.Peek()
        XCTAssert(reversed_peeked == 6, "After Reversing() the peeked element should be 6")
        
        //reduce
        var big_queue = FixedQueue<Int>()
        for i in 1 ... 100 {
            big_queue.Enqueue(i)
        }
        let big_queue_sum = big_queue.Reduce {
            (total, elem) -> Int? in nil != total ? total! + elem : elem
        }
        XCTAssert(5050 == big_queue_sum, "Google tells me this is the right answer.")
        
        //filter
        var filtered_big_queue = big_queue.Filter {
            elem in elem > 50
        }
        XCTAssert(50 == filtered_big_queue.Length, "50 ... 100 should be 50 numbers")
        
        //transform
        var transfomed_big_queue = big_queue.Transform {
            elem in elem * 2
        }
        
        var transformed_sum = transfomed_big_queue.Reduce {
            (total, elem) in nil != total ? total! + elem : elem
        }
        
        XCTAssert(10100 == transformed_sum, "Google tells me this is the right answer.")
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
