//
//  ExcludTests.swift
//  SemaphoreExampleTests
//
//  Created by k_terada on 2020/05/22.
//  Copyright © 2020 k2moons. All rights reserved.
//

import XCTest
@testable import SemaphoreExample

class ExclusiveControlBasicTests: XCTestCase {
    
    /// Test exclusive control of binary semaphore with two threads running on same QOS
    func testExclusiveControlForTwoThread() throws {

        let semaphore  = DispatchSemaphore(value: 1)  // ⚠️ initialize binary semaphore with 1

        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")

        func for_thread_1() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()
            print("✴️ Thread 1")    // excluded by semaphore
        }

        func for_thread_2() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()
            print("✳️ Thread 2")    // excluded by semaphore
            usleep(100)             // only thread_1 wait 100 usec
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

    func testExclusiveControlForTwoThreadNotBinarySemaphore() throws {

        let semaphore  = DispatchSemaphore(value: 2)  // ⚠️ initialize binary semaphore with 2

        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")

        func for_thread_1() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()
            print("✴️ Thread 1")    // excluded by semaphore

        }

        func for_thread_2() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()
            print("✳️ Thread 2")    // excluded by semaphore
            usleep(100)             // only thread_1 wait 100 usec
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

    func testExclusiveControlForMultiThread() throws {
        
        let semaphore  = DispatchSemaphore(value: 1)

        let expectation1 = XCTestExpectation(description: "expectation1")

        typealias TaskHandler = (() -> Void)
        var taskHandlers: [TaskHandler] = [TaskHandler]()
        
        func add(task: @escaping TaskHandler) {
            defer {
                semaphore.signal()
            }
            semaphore.wait()

            print("✴️ Append")
            taskHandlers.append(task)
        }
        
        func execAll() -> Int {
            defer {
                semaphore.signal()
            }
            semaphore.wait()
            
            let count = taskHandlers.count
            
            print("✳️ Start execution \(count)")

            for task in taskHandlers {
                task()
            }

            print("✳️ End execution")
            
            return count
        }
        
        DispatchQueue.global(qos: .background).async {

            var counter: Int = 0
            for _ in 1..<100 {
                let count = execAll()
                counter += count
                usleep(100)
            }
            //expectation1.fulfill()
        }

        DispatchQueue.global(qos: .background).async {

            for _ in 1..<100 {
                execAll()
                usleep(100)
            }
            //expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 10.0)
    }

    // MARK: - testExclusiveControlOnMultThread

        func testExclusiveControlOnMultThread() throws {
    
            let expectation1 = XCTestExpectation(description: "expectation1")
            let tokenExpiredValue: Int = 0
            var token: Int = tokenExpiredValue
    
            typealias TaskHandler = (() -> Void)
            var taskHandlers: [TaskHandler] = [TaskHandler]()
    
            func renewalToke() {
                token = Int.random(in: 1..<Int.max)
            }
    
            func expireToken() {
                let delayInt = DispatchTime.now().uptimeNanoseconds + UInt64.random(in: 100_000_000..<500_000_000)
                let delay = DispatchTime(uptimeNanoseconds: delayInt)
                DispatchQueue.global(qos: .background).asyncAfter(deadline: delay) {
                    token = tokenExpiredValue
                    expireToken()
                }
            }
    
            renewalToke()
            expireToken()
    
            DispatchQueue.global(qos: .background).async {
                for _ in 1..<1000 {
    
                }
                expectation1.fulfill()  // End of Thread 1
            }
    
            wait(for: [expectation1], timeout: 3600)
        }
}
