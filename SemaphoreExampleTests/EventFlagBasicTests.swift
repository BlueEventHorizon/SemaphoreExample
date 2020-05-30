//
//  EventFlagTests.swift
//  SemaphoreExampleTests
//
//  Created by k_terada on 2020/05/22.
//  Copyright © 2020 k2terada. All rights reserved.
//

import XCTest

class EventFlagBasicTests: XCTestCase {

    /*
     ✳️ Start [18:37:25.837] [main]
     ✳️ Sent EventFlag [18:37:26.847] [com.apple.root.background-qos]
     ✴️ Recieved EventFlag [18:37:26.847] [main]
     */

    func testSingleEventFlag() throws {

        let semaphore  = DispatchSemaphore(value: 0)  // ⚠️ initialize binary semaphore with 0

        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")

        semLog.format("✳️ Start")

        DispatchQueue.global(qos: .background).async {

            usleep(1000_000)

            semaphore.signal()

            semLog.format("✳️ Sent EventFlag")

            expectation1.fulfill()
        }

        semaphore.wait()

        semLog.format("✴️ Recieved EventFlag")

        expectation2.fulfill()

        wait(for: [expectation1, expectation2], timeout: 10.0)
    }

    func testMultiEventFlag() throws {

        var semaphores = [(DispatchSemaphore)]()
        var expectations = [XCTestExpectation]()

        // Make Event Reciever Threads
        for counter in 0..<10 {
            let semaphore  = DispatchSemaphore(value: 0)  // ⚠️ initialize binary semaphore with 0
            let expectation = XCTestExpectation(description: "expectation \(counter)")
            semaphores.append((semaphore))
            expectations.append(expectation)

            DispatchQueue.global(qos: .background).async {
                semaphore.wait()
                semLog.normal("✴️ Recieved EventFlag(\(counter))")
                expectation.fulfill()
            }
        }

        for (index, semaphore) in semaphores.enumerated() {

            semLog.normal("✳️ Start to send EventFlag(\(index)) just after now")

            semaphore.signal()

            semLog.normal("✳️ Sent EventFlag(\(index))")

            usleep(100)
        }

        wait(for: expectations, timeout: 10.0)
    }

    /*
     ✳️ Start to send EventFlag(0) just after now
     ✳️ Sent EventFlag(0)
     ✴️ Recieved EventFlag(0)
     ✳️ Start to send EventFlag(1) just after now
     ✳️ Sent EventFlag(1)
     ✴️ Recieved EventFlag(1)
     ✳️ Start to send EventFlag(2) just after now
     ✳️ Sent EventFlag(2)
     ✴️ Recieved EventFlag(2)
     ✳️ Start to send EventFlag(3) just after now
     ✳️ Sent EventFlag(3)
     ✴️ Recieved EventFlag(3)
     ✳️ Start to send EventFlag(4) just after now
     ✳️ Sent EventFlag(4)
     ✴️ Recieved EventFlag(4)
     ✳️ Start to send EventFlag(5) just after now
     ✳️ Sent EventFlag(5)
     ✴️ Recieved EventFlag(5)
     ✳️ Start to send EventFlag(6) just after now
     ✳️ Sent EventFlag(6)
     ✴️ Recieved EventFlag(6)
     ✳️ Start to send EventFlag(7) just after now
     ✳️ Sent EventFlag(7)
     ✴️ Recieved EventFlag(7)
     ✳️ Start to send EventFlag(8) just after now
     ✳️ Sent EventFlag(8)
     ✴️ Recieved EventFlag(8)
     ✳️ Start to send EventFlag(9) just after now
     ✳️ Sent EventFlag(9)
     ✴️ Recieved EventFlag(9)
     */

    /// どちらも非同期に処理を行い、途中でEvent送信が始まるようなケースを考えます。
    /// この場合、取り残されるレシーバが発生するのがわかると思います。

    func testMultiEventFlagInThreads() throws {

        var semaphores = [(DispatchSemaphore)]()
        //var expectations = [XCTestExpectation]()

        DispatchQueue.global(qos: .background).async {

            // Make Event Reciever Threads
            for counter in 0..<10 {

                usleep(UInt32.random(in: 10...100))

                let semaphore  = DispatchSemaphore(value: 0)  // ⚠️ initialize binary semaphore with 0
                //let expectation = XCTestExpectation(description: "expectation \(counter)")
                semaphores.append((semaphore))
                //expectations.append(expectation)

                semLog.normal("✴️ Make Reciever Thread EventFlag(\(counter))")

                DispatchQueue.global(qos: .background).async {
                    semaphore.wait()
                    semLog.normal("✴️ Recieved EventFlag(\(counter))")
                    //expectation.fulfill()
                }
            }

        }

        usleep(1000)
        print("semaphores.count = \(semaphores.count)")

        DispatchQueue.global(qos: .background).async {

            for (index, semaphore) in semaphores.enumerated() {

                semLog.normal("✳️ Start to send EventFlag(\(index)) just after now")

                semaphore.signal()

                semLog.normal("✳️ Sent EventFlag(\(index))")
            }
        }

        sleep(2)

        //wait(for: expectations, timeout: 10.0)
    }

    /*
     ✴️ Make Reciever Thread EventFlag(0)
     ✴️ Make Reciever Thread EventFlag(1)
     ✴️ Make Reciever Thread EventFlag(2)
     semaphores.count = 3
     ✳️ Start to send EventFlag(0) just after now
     ✴️ Recieved EventFlag(0)
     ✳️ Sent EventFlag(0)
     ✴️ Make Reciever Thread EventFlag(3)
     ✳️ Start to send EventFlag(1) just after now
     ✳️ Sent EventFlag(1)
     ✴️ Recieved EventFlag(1)
     ✳️ Start to send EventFlag(2) just after now
     ✳️ Sent EventFlag(2)
     ✴️ Recieved EventFlag(2)
     ✴️ Make Reciever Thread EventFlag(4)
     ✴️ Make Reciever Thread EventFlag(5)
     ✴️ Make Reciever Thread EventFlag(6)
     ✴️ Make Reciever Thread EventFlag(7)
     ✴️ Make Reciever Thread EventFlag(8)
     ✴️ Make Reciever Thread EventFlag(9)
     */

    func testMultiEventFlagInThreads_WithEnableFlag() throws {

        var recieverEnableFlag = true
        var semaphores = [(DispatchSemaphore)]()
        //var expectations = [XCTestExpectation]()

        DispatchQueue.global(qos: .default).async {

            // Make Event Reciever Threads
            for counter in 0..<10 {

                //usleep(UInt32.random(in: 10...100))
                usleep(20)

                guard recieverEnableFlag else { return }

                let semaphore  = DispatchSemaphore(value: 0)  // ⚠️ initialize binary semaphore with 0
                //let expectation = XCTestExpectation(description: "expectation \(counter)")
                semaphores.append((semaphore))
                //expectations.append(expectation)

                semLog.normal("✴️ Make Reciever Thread EventFlag(\(counter))")

                DispatchQueue.global(qos: .background).async {
                    semaphore.wait()
                    semLog.normal("✴️ Recieved EventFlag(\(counter))")
                    //expectation.fulfill()
                }
            }

        }

        usleep(150)

        DispatchQueue.global(qos: .default).async {

            print("semaphores.count = \(semaphores.count)")
            recieverEnableFlag = false

            for (index, semaphore) in semaphores.enumerated() {

                semLog.normal("✳️ Start to send EventFlag(\(index)) just after now")

                semaphore.signal()

                semLog.normal("✳️ Sent EventFlag(\(index))")
            }
        }

        sleep(2)

        //wait(for: expectations, timeout: 10.0)
    }

    /*
     semaphores.count = 0
     ✴️ Make Reciever Thread EventFlag(0)
     */
}
