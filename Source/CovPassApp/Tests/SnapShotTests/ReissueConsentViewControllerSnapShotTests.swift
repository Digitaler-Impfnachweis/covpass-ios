//
//  ReissueConsentViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import Foundation
@testable import CovPassApp
import CovPassCommon

class ReissueConsentViewControllerSnapShotTests: BaseSnapShotTests {

    func testDefault() {
        let token = CBORWebToken.mockVaccinationCertificate.extended()
        let (_, resolver) = Promise<Void>.pending()
        let vm = ReissueConsentViewModel(router: ReissueConsentRouter(sceneCoordinator: SceneCoordinatorMock()),
                                         resolver: resolver,
                                         tokens: [token],
                                         reissueRepository: CertificateReissueRepositoryMock(),
                                         vaccinationRepository: VaccinationRepositoryMock(),
                                         decoder: JSONDecoder(),
                                         locale: .current,
                                         context: .boosterRenewal)
        let vc = ReissueConsentViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1000)
    }
    
    func testDefaultExpiryContext() {
        let token = CBORWebToken.mockVaccinationCertificate.extended()
        let (_, resolver) = Promise<Void>.pending()
        let vm = ReissueConsentViewModel(router: ReissueConsentRouter(sceneCoordinator: SceneCoordinatorMock()),
                                         resolver: resolver,
                                         tokens: [token],
                                         reissueRepository: CertificateReissueRepositoryMock(),
                                         vaccinationRepository: VaccinationRepositoryMock(),
                                         decoder: JSONDecoder(),
                                         locale: .current,
                                         context: .certificateExtension)
        let vc = ReissueConsentViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1000)
    }
}
