//
//  Copyright © 2021 IBM. All rights reserved.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(VaccinationCommonTests.allTests),
    ]
}
#endif