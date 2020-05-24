//
//  ExcludTests.swift
//  SemaphoreExampleTests
//
//  Created by k_terada on 2020/05/22.
//  Copyright © 2020 k2terada. All rights reserved.
//

import XCTest

class ExclusiveControlBasicTests: XCTestCase {

    // MARK: -
    
    /*
     semLog.slow() shows the test log by sleeping for each character.
     so other log may interrupt the test log while sleeping.

     semLog.slow() runs on two *** global *** threads.

     [result]
     each semLog.slow() interrupt another semLog.slow()
     because there is no semaphore to avoid interrupt from other thread that uses same resource.
     in this case, same resource means print() function. and print() is not thread safe.
     FYI: some lebel of thread qos avoid any interrupt

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
    func testSleepingLogOnTwoGlobalThreadWithoutSemaphore() throws {

        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")

        func for_thread_1() {
            semLog.slow("✴️ Thread 1")     // excluded by semaphore
        }

        func for_thread_2() {
            semLog.slow("✳️ Thread 2")     // excluded by semaphore
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

    // MARK: -
    
    /*
     semLog.slow() shows the test log by sleeping for each character.
     so other log may interrupt the test log while sleeping.

     semLog.slow() runs on two *** main *** threads.

     [result]
     each semLog.slow() doesn't interrupt another semLog.slow()
     because two thread are same.
     we use queue for the two thread (actually it's one thread) to execute defferent timing.
     but it's serial execution, so they doesn't interrupt another task.

     ✴️ Thread 1 [23:31:22.714] [main]
     ✴️ Thread 1 [23:31:22.717] [main]
     ✴️ Thread 1 [23:31:22.719] [main]
     ✴️ Thread 1 [23:31:22.722] [main]
     ✴️ Thread 1 [23:31:22.724] [main]
     ✴️ Thread 1 [23:31:22.727] [main]
     ✴️ Thread 1 [23:31:22.729] [main]
     ✴️ Thread 1 [23:31:22.732] [main]
     ✴️ Thread 1 [23:31:22.734] [main]
     ✳️ Thread 2 [23:31:22.736] [main]
     ✳️ Thread 2 [23:31:22.739] [main]
     ✳️ Thread 2 [23:31:22.741] [main]
     ✳️ Thread 2 [23:31:22.743] [main]
     ✳️ Thread 2 [23:31:22.746] [main]
     ✳️ Thread 2 [23:31:22.749] [main]
     ✳️ Thread 2 [23:31:22.751] [main]
     ✳️ Thread 2 [23:31:22.754] [main]
     ✳️ Thread 2 [23:31:22.756] [main]
     */

    func testSleepingLogOnTwoMainThreadWithoutSemaphore() throws {

        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")

        func for_thread_1() {
            semLog.slow("✴️ Thread 1")     // excluded by semaphore
        }

        func for_thread_2() {
            semLog.slow("✳️ Thread 2")     // excluded by semaphore
        }

        // Thread 1
        DispatchQueue.main.async {
            for _ in 1..<10 {
                for_thread_1()
            }
            expectation1.fulfill()  // End of Thread 1
        }

        // Thread 2
        DispatchQueue.main.async {
            for _ in 1..<10 {
                for_thread_2()
            }
            expectation2.fulfill() // End of Thread 2
        }

        wait(for: [expectation1, expectation2], timeout: 10.0)
    }

    // MARK: -
    
    /*
     semLog.slow() shows the test log by sleeping for each character.
     so other log may interrupt the test log while sleeping.

     semLog.slow() runs on two *** global *** threads with binary semaphore.

     [FYI]
     semaphore has 1 rasource counter is called binary semaphore or mutex.

     [result]
     each semLog.slow() interrupt doesn't another semLog.slow()
     because there is semaphore to avoid interrupt from other thread that uses same resource.
     in this case, same resource means print() function. and print() is not thread safe.
     FYI: some lebel of thread qos avoid any interrupt

     ✴️ Thread 1 [23:36:04.091] [com.apple.root.background-qos]
     ✳️ Thread 2 [23:36:04.145] [com.apple.root.background-qos]
     ✴️ Thread 1 [23:36:04.197] [com.apple.root.background-qos]
     ✳️ Thread 2 [23:36:04.246] [com.apple.root.background-qos]
     ✴️ Thread 1 [23:36:04.296] [com.apple.root.background-qos]
     ✳️ Thread 2 [23:36:04.352] [com.apple.root.background-qos]
     ✴️ Thread 1 [23:36:04.404] [com.apple.root.background-qos]
     ✳️ Thread 2 [23:36:04.455] [com.apple.root.background-qos]
     ✴️ Thread 1 [23:36:04.502] [com.apple.root.background-qos]
     ✳️ Thread 2 [23:36:04.550] [com.apple.root.background-qos]
     ✴️ Thread 1 [23:36:04.650] [com.apple.root.background-qos]
     ✳️ Thread 2 [23:36:04.750] [com.apple.root.background-qos]
     ✴️ Thread 1 [23:36:04.854] [com.apple.root.background-qos]
     ✳️ Thread 2 [23:36:04.944] [com.apple.root.background-qos]
     ✴️ Thread 1 [23:36:05.005] [com.apple.root.background-qos]
     ✳️ Thread 2 [23:36:05.103] [com.apple.root.background-qos]
     ✴️ Thread 1 [23:36:05.198] [com.apple.root.background-qos]
     ✳️ Thread 2 [23:36:05.253] [com.apple.root.background-qos]

     */

    func testSleepingLogOnTwoGlobalThreadWithSemaphore() throws {

        let semaphore  = DispatchSemaphore(value: 1)  // ⚠️ initialize binary semaphore with 1

        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")

        func for_thread_1() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()
            semLog.slow("✴️ Thread 1")     // excluded by semaphore
        }

        func for_thread_2() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()
            semLog.slow("✳️ Thread 2")     // excluded by semaphore
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

    // MARK: -
    
    /*
     semLog.slow() shows the test log by sleeping for each character.
     so other log may interrupt the test log while sleeping.

     semLog.slow() runs on two *** global *** threads with semaphore that has 2 resources.

     [FYI]
     semaphore has 1 rasource counter is called binary semaphore or mutex.

     [result]
     each semLog.slow() interrupt another semLog.slow()
     because there are 2 semaphore, and each thread can get thier own semaphore.
     so there is no block
     
     ✳️✴️  ThTrheraedad 2  1[ 2[23:43:0:402:0.280.048]0 4][ co[cmo.ma.paplpepl.ero.orot.bota.cbkgraockungrdo-uqnods-q]o
     s✳️ ]T
     ✴️hr eTahdr e2ad [ 231:4 0:[2023:40:20.81.48]14]  [[cocomm.app.laep.proloet..broaoct.kbgacrkoungdr-qoos]
     ✴️ uThnrde-qaods]
     1✳️ Th re[ad23 2: 4[023:40:20:.2802.8524] ][ c[ocomm..aappppllee..rroot.obaoct.bkgraocunkgdr-qoousn]d
     -✳️qos]
     ✴️ Thread  1 [23T:hread4 20: 2[23:40:20.083.5]83 5[]c o[cm.oamp.plaep.proloe.tr.oboat.cbkagcrokugndro-quonsd]
     -q✳️ osT]h
     r✴️ea dT hr2e a[2d 31 [2:3:440:02:020..8845] [c4om5.]a ppl[ec.rooot.mb.aapckgprloune.d-qrooos]
     ✴️ Tht.rbeaacd k1gr [o2u3nd-qos:]4
     ✳️ 0:T2h0r.8e5a8] [com.appled. root.background-qos2]
     ✴️[ T23h:r4e0a:d 1 [232:040.862] :[2c0.om86.8a] [ppcloem..aropopt.lbea.crokotgr.obunad-cqkogsr]o
     u✳️n dT-qhorsea]d
      ✴️ 2T h[2r3ea:d40 1: [202.387:54]0 :[2c0om.8.a7p6p] l[ec.ormo.aopt.pble.roaockgrotun.bdac-kqos]g
     r✳️o Threuad 2nd -[2qos3:]
     4✴️ 0:20T.8h86] [comre.aapd 1p l[2e.r3o:o40t:.ba2c0.k8gr90] [ocoumn.adp-qpoles.]r
     ✳️ oTohrtea.bda c2k g[r2o3un:d4-q0o:s20].9
     */

    func testSleepingLogOnTwoGlobalThreadWithTwoSemaphore() throws {

        let semaphore  = DispatchSemaphore(value: 2)  // ⚠️ initialize binary semaphore with 2

        let expectation1 = XCTestExpectation(description: "expectation1")
        let expectation2 = XCTestExpectation(description: "expectation2")

        func for_thread_1() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()            // there are enogh semaphore for each thred, so they doesn't need to wait
            semLog.slow("✴️ Thread 1")    // excluded by semaphore
        }

        func for_thread_2() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()            // there are enogh semaphore for each thred, so they doesn't need to wait
            semLog.slow("✳️ Thread 2")     // excluded by semaphore
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

    
    
    
    
    
    
    // MARK: -
    
    /*
     semLog.slow() shows the test log by sleeping for each character.
     so other log may interrupt the test log while sleeping.

     semLog.slow() runs on two *** global *** threads with semaphore that has 2 resources.

     [FYI]
     semaphore has 1 rasource counter is called binary semaphore or mutex.

     [result]
     each semLog.slow() interrupt another semLog.slow()
     because there are 2 semaphore, and each thread can get thier own semaphore.
     so there is no block
 
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
            semLog.slow("✴️ Thread 1")    // excluded by semaphore
        }

        func for_thread_2() {
            defer {
                semaphore.signal()
            }
            semaphore.wait()
            semLog.slow("✳️ Thread 2")     // excluded by semaphore
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
            semLog.slow("✴️ Thread 1")    // excluded by semaphore
        }

        func for_thread_2() {
            semLog.slow("✳️ Thread 2")     // excluded by semaphore
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
