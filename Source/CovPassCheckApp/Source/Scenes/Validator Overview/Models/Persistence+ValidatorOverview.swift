//
//  Persistence+ValidatorOverview.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

private let keyValidatorOverviewScanType = "keyValidatorOverviewScanType"
private let keyValidatorOverviewBoosterAsTest = "keyValidatorOverviewBoosterAsTest"

extension Persistence {
    var validatorOverviewScanType: ScanType? {
        get {
            guard let value = try? fetch(keyValidatorOverviewScanType) as? Int else {
                return nil
            }
            return ScanType(rawValue: value)
        }
        set {
            try? store(keyValidatorOverviewScanType, value: newValue?.rawValue as Any)
        }
    }

    var validatorOverviewBoosterAsTest: Bool {
        get {
            let value = try? fetch(keyValidatorOverviewBoosterAsTest) as? Bool
            return value ?? false
        }
        set {
            try? store(keyValidatorOverviewBoosterAsTest, value: newValue as Any)
        }
    }
}
