//
//  ReissueConsentViewControllerSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import Foundation
import PromiseKit

class ReissueConsentViewControllerSnapShotTests: BaseSnapShotTests {
    func testDefault() {
        var token = CBORWebToken.mockVaccinationCertificate.extended()
        token.vaccinationCertificate.exp = .init() + 1
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
        var token = CBORWebToken.mockVaccinationCertificate.extended()
        token.vaccinationCertificate.exp = .init() + 1
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

    func testMultipleExpiryContext() {
        var token = CBORWebToken.mockVaccinationCertificate.mockVaccinationSetDate(.init() - 10000).extended()
        let token2 = CBORWebToken.mockVaccinationCertificate.doseNumber(1).extended()
        token.vaccinationCertificate.exp = .init() + 1
        let (_, resolver) = Promise<Void>.pending()
        let vm = ReissueConsentViewModel(router: ReissueConsentRouter(sceneCoordinator: SceneCoordinatorMock()),
                                         resolver: resolver,
                                         tokens: [token, token2],
                                         reissueRepository: CertificateReissueRepositoryMock(),
                                         vaccinationRepository: VaccinationRepositoryMock(),
                                         decoder: JSONDecoder(),
                                         locale: .current,
                                         context: .certificateExtension)
        let vc = ReissueConsentViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1000)
    }
}
