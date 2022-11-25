//
//  BaseSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import iOSSnapshotTestCase
import iOSSnapshotTestCaseCore
import XCTest

class BaseSnapShotTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        fileNameOptions = .screenSize
    }

    func verifyView(vc: UIViewController, record: Bool = false) {
        recordMode = record
        FBSnapshotVerifyViewController(vc,
                                       identifier: Locale.preferredLanguages[0],
                                       suffixes: NSOrderedSet(arrayLiteral: "_64"),
                                       perPixelTolerance: 0.1)
    }

    func verifyView(view: UIView,
                    record: Bool = false,
                    height: CGFloat = UIScreen.main.bounds.height,
                    waitAfter: TimeInterval = 0.0,
                    perPixelTolerance: CGFloat = 0.1) {
        recordMode = record
        view.frame.size = CGSize(width: UIScreen.main.bounds.width, height: height)
        RunLoop.current.run(for: waitAfter)
        FBSnapshotVerifyView(view,
                             identifier: Locale.preferredLanguages[0],
                             suffixes: NSOrderedSet(arrayLiteral: "_64"),
                             perPixelTolerance: perPixelTolerance)
    }

    func verifyAsync(vc: UIViewController,
                     wait: TimeInterval = 0.1,
                     record: Bool = false) {
        recordMode = record
        let expectationHere = expectation(description: "Some Expectation")
        vc.view.bounds = UIScreen.main.bounds
        DispatchQueue.main.asyncAfter(deadline: .now() + wait) {
            self.verifyView(vc: vc, record: record)
            expectationHere.fulfill()
        }
        waitForExpectations(timeout: 1.0 + wait, handler: nil)
    }
}
