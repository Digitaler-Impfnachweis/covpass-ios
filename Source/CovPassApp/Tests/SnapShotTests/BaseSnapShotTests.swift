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
        recordMode = false
        fileNameOptions = .screenSize
    }
    
    func vertifyView(vc: UIViewController) {
        FBSnapshotVerifyViewController(vc,
                                       identifier: Locale.preferredLanguages[0] ,
                                       suffixes: NSOrderedSet(arrayLiteral: "_64"),
                                       perPixelTolerance: 0.1)
    }
    
    func verifyAsyc(vc: UIViewController,
                    wait: TimeInterval = 0.1) {
        let expectationHere = expectation(description: "Some Expectation")
        vc.view.bounds = UIScreen.main.bounds
        DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
            self.vertifyView(vc: vc)
            expectationHere.fulfill()
        }
        self.waitForExpectations(timeout: 1.0 + wait, handler: nil)
    }
}
