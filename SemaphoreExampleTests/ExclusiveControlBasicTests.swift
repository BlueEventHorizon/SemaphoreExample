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

    func testNoExclusiveControlInTwoThreadWithBinarySemaphoreAndSameQos() throws {

        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")

        func for_thread_1() {
            log.slow("✴️ Thread 1")     // excluded by semaphore
        }

        func for_thread_2() {
            log.slow("✳️ Thread 2")     // excluded by semaphore
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

    // Result of testNoExclusiveControlInTwoThreadWithBinarySemaphoreAndSameQos()

    /*
     ✳️✴️  ThreadT 1h [18:r2e3ad: 2 0[7.1638:20] [c3o:0m.appl7e..root63.0ba]c kgr[oucnd-qosom.]
     a✴️ ppThlree.adro ot1. [1b8ac:kgr23:o0u8n.0d2-5qo] [coms].a
     p✳️p Tlheread. 2 root[1.8ba:23ckg:r08o.und3-0qo0s]]
     ✴️[c omThr.eaapple.dro ot.b1ac [k18:23gr:0ou8nd.-5q5o0s]]
     ✳️ [co Tm.aphprealed .r2o ot.bac[k18g:r23:0ound8-qo.87s]7
     ✴️] Th [rcome.apapd le1.r o[o18t.:ba23c:kg09r.ou1n2d2-]q o[sc]om.
     ✳️ Tahprpealde.r 2 [o1o8:t2.3:bac0kg9.ro55und2]- q[coosm.a]p
     ✴️ pleThre.arod 1 o[t1.8:b23:0ack9.8gr2o2] un[d-qocos]m
     ✳️. aTpplhe.rroeoat.bd a2ck g[1ro8:2un3d-:q1os0].10
     ✴️0 ] [coTm.ahrpepaled .r1oo [t1.b8:ack2g3ro:10und.-370]qo s][co
     ✳️ Tm.harepapled. 2r oot.[1b8a:c23:k1g0rou.n7d53]- q[como.apsple]
     ✴️ .rThreoad o1t [1.ba8:c2kg3:r1o1.0u8n0]d-q [coosm.a]
     ✳️ Thrppeadle .2 [r18oo:23t.b:ack1gr1.4o35]und -[qcoosm]
     .✴️apple T.hroroet.adb a1ck g[r1oun8d-:qos23]:
     ✳️1 Threa1d .271 8[] 1[c8:om.23a:1p1pl.e.9ro1ot.4]b [ackcgroomu.apndple-.qors]o
     o✴️ tT.hbraecakgd 1 [1r8o:23:und-12.qo2s11]]
     [✳️co Thmr.appealde .2root [1.8b:ac2kg3:12rou.nd-3qo5s7] ]
     */

    /// Test exclusive control of binary semaphore with two threads running on same QOS
    func testExclusiveControlInTwoThreadWithBinarySemaphoreAndSameQos() throws {

        let semaphore  = DispatchSemaphore(value: 1)  // ⚠️ initialize binary semaphore with 1

        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")

        func for_thread_1() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()
            log.slow("✴️ Thread 1")     // excluded by semaphore
        }

        func for_thread_2() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()
            log.slow("✳️ Thread 2")     // excluded by semaphore
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

    // Result of testExclusiveControlInTwoThreadWithBinarySemaphoreAndSameQos()
    /*

     ✴️ Thread 1 [18:24:25.079] [com.apple.root.background-qos]
     ✳️ Thread 2 [18:24:25.090] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:24:25.106] [com.apple.root.background-qos]
     ✳️ Thread 2 [18:24:25.119] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:24:25.131] [com.apple.root.background-qos]
     ✳️ Thread 2 [18:24:25.140] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:24:25.162] [com.apple.root.background-qos]
     ✳️ Thread 2 [18:24:25.188] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:24:25.213] [com.apple.root.background-qos]
     ✳️ Thread 2 [18:24:25.228] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:24:25.258] [com.apple.root.background-qos]
     ✳️ Thread 2 [18:24:25.276] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:24:25.289] [com.apple.root.background-qos]
     ✳️ Thread 2 [18:24:25.315] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:24:25.332] [com.apple.root.background-qos]
     ✳️ Thread 2 [18:24:25.338] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:24:25.359] [com.apple.root.background-qos]
     ✳️ Thread 2 [18:24:25.372] [com.apple.root.background-qos]

     */

    /// Test exclusive control of many semaphore with two threads running on same QOS
    /// if wait(), there are enogh semaphore for each thred, so they doesn't need to wait
    func testExclusiveControlInTwoThreadWithManySemaphoreAndSameQos() throws {

        let semaphore  = DispatchSemaphore(value: 2)  // ⚠️ initialize binary semaphore with 2

        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")

        func for_thread_1() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()            // there are enogh semaphore for each thred, so they doesn't need to wait
            log.slow("✴️ Thread 1")    // excluded by semaphore
        }

        func for_thread_2() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()            // there are enogh semaphore for each thred, so they doesn't need to wait
            log.slow("✳️ Thread 2")     // excluded by semaphore
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

    // Result of testExclusiveControlInTwoThreadWithManySemaphoreAndSameQos()

    /*
     ✴️✳️  TThrhreaed a1 d [21 8[1:82:42:543:.5871] 3[.c8o7m1.a]p ple.root.back[cogrm.apple.root.backgroouunndd--qqooss]
     ]
     ✳️✴️  ThreThreada 2d  1[ 1[8:128:424:5:353..88886]6 ][ c[coom.mapple.r.ooatpp.blaeck.rgorooutn.dbac-kqgosr]ou
     ✳️n Tdhr-qeoasd]
     ✴️2 T h[re1a8d: 12 4[:18:24:53.907] [co5m3..9ap0p7l]e. r[ocoom.t.apbacplekg.rroooundt-.qbaosc]kg
     ✴️r oThread 1 [18:u24n:d5-q3o.9s]1
     ✳️ 4]T hre[acod 2m [18:24.:ap5p3l.e9.1ro7o]t. b[accokmgrou.nda-qppole.sr]o
     ✴️ot .Tbahrcekgardo 1un [d-q18os:]
     2✳️4: 5T3.h92rea4] d[ co2 m[.1a8:ppl24e.:5ro3ot.9.b27a]ck [grocuonmd.-qaops]
     ✴️ Threapdl e1 [.1r8oot.back:g24ro:5u3.9n3d1-]q [os]co
     ✳️ m.Tahrpeplad 2 e[1.8roo:24:5t3..939] b[acockgroundm.a-ppqos]
     ✴️le .Trohortead.b a1ckgro [1u8:nd24:-q5o3.9s62]]
     ✳️  [Tcohmr.eaapdp l2e .[ro18:2ot.bac4:k5gr3o.u96nd-8]q o[s]c
     o✴️ mThr.eaapd 1 [18p:le2.4ro:ot53.b.97ack3]gr [cooumnd-.qoasp]p
     l✳️e .rTohort.eabd a2c [k18gr:o24un:5d3.-q97o8]s]
     ✴️ Threa[d c1 [18:24:53.981] o[cmo.ma.pplapepl.ero.rootot..bbackacgrkound-qos]
     ✳️ Thgread 2 [r1ou8n:d-24q:o5s3]
     */

    /// Test exclusive control in 2 thread with binary semaphore and different qos
    func testExclusiveControlInTwoThreadWithBinarySemaphoreAndDifferentQos() throws {

        let semaphore  = DispatchSemaphore(value: 1)  // ⚠️ initialize binary semaphore with 1

        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")

        func for_thread_1() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()
            log.slow("✴️ Thread 1")    // excluded by semaphore
        }

        func for_thread_2() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()
            log.slow("✳️ Thread 2")     // excluded by semaphore
        }

        // Thread 1
        DispatchQueue.global(qos: .default).async {
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

    // Result of testExclusiveControlInTwoThreadWithBinarySemaphoreAndDifferentQos
    /*
     ✴️ Thread 1 [18:25:10.291] [com.apple.root.user-interactive-qos]
     ✳️ Thread 2 [18:25:10.304] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:25:10.321] [com.apple.root.user-interactive-qos]
     ✳️ Thread 2 [18:25:10.325] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:25:10.356] [com.apple.root.user-interactive-qos]
     ✳️ Thread 2 [18:25:10.362] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:25:10.378] [com.apple.root.user-interactive-qos]
     ✳️ Thread 2 [18:25:10.383] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:25:10.405] [com.apple.root.user-interactive-qos]
     ✳️ Thread 2 [18:25:10.410] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:25:10.420] [com.apple.root.user-interactive-qos]
     ✳️ Thread 2 [18:25:10.425] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:25:10.458] [com.apple.root.user-interactive-qos]
     ✳️ Thread 2 [18:25:10.464] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:25:10.483] [com.apple.root.user-interactive-qos]
     ✳️ Thread 2 [18:25:10.487] [com.apple.root.background-qos]
     ✴️ Thread 1 [18:25:10.522] [com.apple.root.user-interactive-qos]
     ✳️ Thread 2 [18:25:10.528] [com.apple.root.background-qos]
     */

    func testThreadWithoutSemaphoreWithDifferentQos() throws {

        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")

        func for_thread_1() {
            log.slow("✴️ Thread 1")    // excluded by semaphore
        }

        func for_thread_2() {
            log.slow("✳️ Thread 2")     // excluded by semaphore
        }

        // Thread 1
        DispatchQueue.global(qos: .background).async {
            for _ in 1..<10 {
                for_thread_1()
            }
            expectation1.fulfill()  // End of Thread 1
        }

        // Thread 2
        DispatchQueue.global(qos: .default).async {
            for _ in 1..<10 {
                for_thread_2()
            }
            expectation2.fulfill() // End of Thread 2
        }

        wait(for: [expectation1, expectation2], timeout: 10.0)
    }

    /*
     ✴️✳️  TThhrerade a2d [21:41:57.299 ] [c1om. ap[p2le1:.r4o1o:t.5d7efa.u3l0t-0q]os]
     ✳️ Thre ad[ 2c o[21:m41:.57.a3p05p] l[com.apple.root.dee.farult-qos]
     ✳️ Threaod o2 t[.2b1a:c41:57.310]k [cgorm.apple.root.defoauulnt-dqos]
     ✳️ Thre-aqd o2 s][
     2✴️ 1:41T:5h7.315] [corme.apple.root.defaulatd-q os1]
     ✳️[ 2Th1r:ea4d1 2: 5[7.21:41:57.319] 3[co1m.6a]pple .r[ocootm..deafapupllte-.qoros]o
     ✳️t Thread 2 [2.1b:41:57.324] [com.applaec.root.default-qosk]
     ✳️ Thread 2 [21:g41:57.328] [com.apple.root.defraoult-qos]
     ✳️ Threadu n2d -[q2o1s]:41
     ✴️:57.332] [c oTmh.arpple.reoot.defaaudl 1t- q[o2s1]:
     4✳️ T1hr:e5a7d .23 3[23]1: 4[1:57.c336] [com.apple.root.odmefa.ulat-ppqoles].
     root.background-qos]
     ✴️ Thread 1 [21:41:57.349] [com.apple.root.background-qos]
     ✴️ Thread 1 [21:41:57.357] [com.apple.root.background-qos]
     ✴️ Thread 1 [21:41:57.368] [com.apple.root.background-qos]
     ✴️ Thread 1 [21:41:57.374] [com.apple.root.background-qos]
     ✴️ Thread 1 [21:41:57.404] [com.apple.root.background-qos]
     ✴️ Thread 1 [21:41:57.420] [com.apple.root.background-qos]
     */
}
