//
//  BaseSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
import iOSSnapshotTestCaseCore
import iOSSnapshotTestCase

class BaseSnapShotTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        fileNameOptions = .screenSize
    }

    func verifyView(vc: UIViewController, record: Bool = false) {
        recordMode = record
        FBSnapshotVerifyViewController(vc,
                                       identifier: Locale.preferredLanguages[0] ,
                                       suffixes: NSOrderedSet(arrayLiteral: "_64"),
                                       perPixelTolerance: 0.1)
    }

    /// Snapshots the view with a given height
    /// - Parameters:
    ///   - view: the view to snapshot
    ///   - record: record it or not
    ///   - height: height of the view with should be recorded. Default is the main screen height
    func verifyView(view: UIView, record: Bool = false, height: CGFloat = UIScreen.main.bounds.height) {
        recordMode = record
        view.frame.size = CGSize(width: UIScreen.main.bounds.width, height: height)
        FBSnapshotVerifyView(view,
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
            self.verifyView(vc: vc)
            expectationHere.fulfill()
        }
        self.waitForExpectations(timeout: 1.0 + wait, handler: nil)
    }
}
