//
//  SemaphoreExampleTests.swift
//  SemaphoreExampleTests
//
//  Created by k_terada on 2020/05/22.
//  Copyright © 2020 k2moons. All rights reserved.
//

import XCTest
@testable import SemaphoreExample

class ExcludByBinarySemaphoreOnSameQosTest: XCTestCase {

    /// 同じQOSで動作する２つのスレッドで、バイナリーセマフォの排他制御をテストします
    ///
    func testExcludByBinarySemaphoreOnSameQos() throws {

        let semaphore  = DispatchSemaphore(value: 1)  // make binary semaphore

        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")

        func for_thread_1() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()
            print("✴️ Thread 1")    // excluded by semaphore
            usleep(100)             // only thread_1 wait 100 usec
        }

        func for_thread_2() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()
            print("✳️ Thread 2")    // excluded by semaphore
        }

        // Thread 1
        DispatchQueue.global(qos: .background).async {
            for _ in 1..<10 {
                for_thread_1()
            }
            expectation1.fulfill()  // End of Thread 1
        }

        // Thread 2
        DispatchQueue.global(qos: .background).async {
            for _ in 1..<10 {
                for_thread_2()
            }
            expectation2.fulfill() // End of Thread 2
        }

        wait(for: [expectation1, expectation2], timeout: 10.0)
    }
}
