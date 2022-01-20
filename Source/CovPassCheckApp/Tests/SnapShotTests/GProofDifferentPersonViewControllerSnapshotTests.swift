//
//  GProofDifferentPersonSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import XCTest
import CovPassUI
import CovPassCommon
import PromiseKit

class GProofDifferentPersonViewControllerSnapshotTests: BaseSnapShotTests {
    
    func testSameDob() {
        let gProofToken = CBORWebToken.mockVaccinationCertificate
        let testToken = CBORWebToken.mockTestCertificate
        let (_, resolver) = Promise<GProofResult>.pending()
        let vm = GProofDifferentPersonViewModel(gProofToken: gProofToken,
                                                testProofToken: testToken,
                                                resolver: resolver)
        let vc = GProofDifferentPersonViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testDifferentDob() {
        let gProofToken = CBORWebToken.mockVaccinationCertificate
        var testToken = CBORWebToken.mockTestCertificate
        testToken.hcert.dgc.dob = DateUtils.parseDate("1999-04-26T15:05:00")!
        let (_, resolver) = Promise<GProofResult>.pending()
        let vm = GProofDifferentPersonViewModel(gProofToken: gProofToken,
                                                testProofToken: testToken,
                                                resolver: resolver)
        let vc = GProofDifferentPersonViewController(viewModel: vm)
        verifyView(vc: vc)
    }
}
