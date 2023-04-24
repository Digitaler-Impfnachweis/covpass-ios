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
                    perPixelTolerance: CGFloat = 0.1,
                    overallTolerance: CGFloat = 0.0) {
        recordMode = record
        view.frame.size = CGSize(width: UIScreen.main.bounds.width, height: height)
        RunLoop.current.run(for: waitAfter)
        FBSnapshotVerifyView(view,
                             identifier: Locale.preferredLanguages[0],
                             suffixes: NSOrderedSet(arrayLiteral: "_64"),
                             perPixelTolerance: perPixelTolerance, overallTolerance: overallTolerance)
    }
}
