//
//  CheckSituationViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import CovPassCommon

class CheckSituationViewControllerSnapShotTests: BaseSnapShotTests {
    
    func testInformation() {
        let certLogicMock = DCCCertLogicMock()
        let vaccinationRepositoryMock = VaccinationRepositoryMock()
        let vm = CheckSituationViewModel(context: .information,
                                         userDefaults: UserDefaultsPersistence(),
                                         router: nil,
                                         resolver: nil,
                                         offlineRevocationService: nil,
                                         repository: vaccinationRepositoryMock,
                                         certLogic: certLogicMock)
        let vc = CheckSituationViewController(viewModel: vm)
        verifyView(vc: vc)
    }
}
