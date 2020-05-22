//
//  EventFlagTests.swift
//  SemaphoreExampleTests
//
//  Created by k_terada on 2020/05/22.
//  Copyright © 2020 k2moons. All rights reserved.
//

import XCTest

class EventFlagBasicTests: XCTestCase {

    func testEventFlagByBinarySemaphore() throws {

        let semaphore  = DispatchSemaphore(value: 0)  // ⚠️ initialize binary semaphore with 0

        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")

        DispatchQueue.global(qos: .background).async {

            usleep(1000)

            print("✳️ Will send EventFlag just after now")

            semaphore.signal()

            print("✳️ Sent EventFlag")

            expectation1.fulfill()
        }

        semaphore.wait()

        print("✴️ Recieved EventFlag")

        expectation2.fulfill()

        wait(for: [expectation1, expectation2], timeout: 10.0)
    }
}
