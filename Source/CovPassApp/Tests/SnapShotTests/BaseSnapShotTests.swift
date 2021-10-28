//
//  BaseSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest
import FBSnapshotTestCase

class BaseSnapShotTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        fileNameOptions = .screenSize
    }
    
    func vertifyView(vc: UIViewController, record: Bool = false) {
        recordMode = record
        FBSnapshotVerifyViewController(vc,
                                       identifier: Locale.preferredLanguages[0] ,
                                       suffixes: NSOrderedSet(arrayLiteral: "_64"),
                                       perPixelTolerance: 0.1)
    }
    
    func verifyAsyc(vc: UIViewController,
                    wait: TimeInterval = 0.1,
                    record: Bool = false) {
        recordMode = record
        let expectationHere = expectation(description: "Some Expectation")
        vc.view.bounds = UIScreen.main.bounds
        DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
            self.vertifyView(vc: vc)
            expectationHere.fulfill()
        }
        self.waitForExpectations(timeout: 1.0 + wait, handler: nil)
    }
}
