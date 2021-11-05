//
//  CertificateOverviewSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassUI
@testable import CovPassCommon
import UIKit
import PromiseKit

class CertificateOverviewSnapShotTests: BaseSnapShotTests {

    func testCertificateOverviewDefault() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let sceneCoordinator = DefaultSceneCoordinator(window: window)
        let router = CertificatesOverviewRouter(sceneCoordinator: sceneCoordinator)
        let viewModel = CertificatesOverviewViewModel(
            router: router,
            repository: VaccinationRepositoryMock(),
            certLogic: DCCCertLogicMock(),
            boosterLogic: BoosterLogicMock(),
            userDefaults: UserDefaultsPersistence()
        )
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        verifyAsyc(vc: navigationController)
    }
    
    func testCertificateOverviewCertificates() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let sceneCoordinator = DefaultSceneCoordinator(window: window)
        let router = CertificatesOverviewRouter(sceneCoordinator: sceneCoordinator)
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert1: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert1.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        let cert2: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert2.vaccinationCertificate.hcert.dgc.nam.fn = "John 2"
        let cert3: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert3.vaccinationCertificate.hcert.dgc.nam.fn = "John 3"
        let certs = [cert1,
                     cert2,
                     cert3]
        vacinationRepoMock.certificates = certs
        let viewModel = CertificatesOverviewViewModel(
            router: router,
            repository: vacinationRepoMock,
            certLogic: DCCCertLogicMock(),
            boosterLogic: BoosterLogicMock(),
            userDefaults: UserDefaultsPersistence()
        )
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        viewController.view.bounds = UIScreen.main.bounds
        RunLoop.current.run(for: 0.1)
        verifyView(vc: viewController)
    }
}
