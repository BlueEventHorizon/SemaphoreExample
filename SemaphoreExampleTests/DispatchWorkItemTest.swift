//
//  DispatchWorkItemTest.swift
//  SemaphoreExampleTests
//
//  Created by k_terada on 2020/05/25.
//  Copyright © 2020 k2moons. All rights reserved.
//

import XCTest

class DispatchWorkItemTest: XCTestCase {

    private var workItem: DispatchWorkItem?

    func testDispatchWorkItem() throws {

        let delayBySec = 5

        let expectation1 = XCTestExpectation(description: "expectation1")

        let executeLater = { () -> Void in
            semLog.normal("✳️ WorkItem Executed")
            expectation1.fulfill()
        }

        workItem = DispatchWorkItem(block: executeLater)

        if let workItem = workItem {

            let nanosec = DispatchTime.now().uptimeNanoseconds + UInt64(delayBySec * 1_000_000_000)
            let deadline = DispatchTime(uptimeNanoseconds: nanosec )
            DispatchQueue.main.asyncAfter(deadline: deadline, execute: workItem)
        }

        wait(for: [expectation1], timeout: 10.0)
    }

    func testDispatchWorkItemCancel() throws {

        let delayBySec = 5
        var executed = false

        let executeLater = { () -> Void in
            semLog.normal("✳️ WorkItem Executed")
            executed = true
        }

        workItem = DispatchWorkItem(block: executeLater)

        if let workItem = workItem {

            let nanosec = DispatchTime.now().uptimeNanoseconds + UInt64(delayBySec * 1_000_000_000)
            let deadline = DispatchTime(uptimeNanoseconds: nanosec )
            DispatchQueue.main.asyncAfter(deadline: deadline, execute: workItem)
        }

        workItem?.cancel()

        sleep(UInt32(delayBySec + 2))

        XCTAssertFalse(executed)
    }

    func testDispatchWorkItemLoop() throws {

        let delayBySec = 1

        let expectation1 = XCTestExpectation(description: "expectation1")

        for counter in 1...10 {

            workItem?.cancel()

            let executeLater = { () -> Void in
                semLog.normal("✳️ \(counter) WorkItem Executed")
                expectation1.fulfill()
            }

            workItem = DispatchWorkItem(block: executeLater)

            if let workItem = workItem {

                let nanosec = DispatchTime.now().uptimeNanoseconds + UInt64(delayBySec * 1_000_000_000)
                let deadline = DispatchTime(uptimeNanoseconds: nanosec )
                DispatchQueue.main.asyncAfter(deadline: deadline, execute: workItem)
            }

            usleep(100)
        }

        wait(for: [expectation1], timeout: 10.0)
    }
}
