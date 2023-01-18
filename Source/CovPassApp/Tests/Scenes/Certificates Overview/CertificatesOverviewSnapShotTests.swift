//
//  CertificateOverviewSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import PromiseKit
import UIKit
import XCTest

class CertificateOverviewSnapShotTests: BaseSnapShotTests {
    private var userDefaults = UserDefaultsPersistence()

    func test_default() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let sceneCoordinator = DefaultSceneCoordinator(window: window)
        let router = CertificatesOverviewRouter(sceneCoordinator: sceneCoordinator)
        let viewModel = viewModel(router: router, repository: VaccinationRepositoryMock(), holderNeedsMask: true)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        verifyView(view: navigationController.view, waitAfter: 0.1)
    }

    private func viewModel(
        router: CertificatesOverviewRouterProtocol = CertificatesOverviewRouterMock(),
        boosterLogic: BoosterLogicMock = BoosterLogicMock(),
        repository: VaccinationRepositoryProtocol,
        holderNeedsMask: Bool,
        maskRulesAvailable: Bool = false
    ) -> CertificatesOverviewViewModelProtocol {
        let certificateHolderStatusModel = CertificateHolderStatusModelMock()
        certificateHolderStatusModel.areMaskRulesAvailable = maskRulesAvailable
        certificateHolderStatusModel.needsMask = holderNeedsMask
        return CertificatesOverviewViewModel(
            router: router,
            repository: repository,
            revocationRepository: CertificateRevocationRepositoryMock(),
            certLogic: DCCCertLogicMock(),
            boosterLogic: boosterLogic,
            userDefaults: UserDefaultsPersistence(),
            locale: .current,
            pdfExtractor: CertificateExtractorMock(),
            certificateHolderStatusModel: certificateHolderStatusModel
        )
    }

    func test_multiple_certificates() {
        let vacinationRepoMock = VaccinationRepositoryMock()
        let cert1: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert1.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        let cert2: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert2.vaccinationCertificate.hcert.dgc.nam.fn = "John 2"
        let cert3: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert3.vaccinationCertificate.hcert.dgc.nam.fn = "John 3"
        cert1.vaccinationCertificate.hcert.dgc.nam.fnt = "JOHN1"
        cert2.vaccinationCertificate.hcert.dgc.nam.fnt = "JOHN2"
        cert3.vaccinationCertificate.hcert.dgc.nam.fnt = "JOHN3"
        let certs = [cert1,
                     cert2,
                     cert3]
        vacinationRepoMock.certificates = certs
        let viewModel = viewModel(repository: vacinationRepoMock, holderNeedsMask: false, maskRulesAvailable: true)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.3)
    }

    func test_maskNeeded() {
        let vacinationRepoMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = viewModel(repository: vacinationRepoMock, holderNeedsMask: true, maskRulesAvailable: true)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.3)
    }

    func test_booster_notification_maskNeeded() {
        let vacinationRepoMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let certs = [cert]
        let boosterLogicMock = BoosterLogicMock()
        var boosterCandidate = BoosterCandidate(certificate: cert)
        boosterCandidate.state = .new
        boosterLogicMock.boosterCandidates = [boosterCandidate]
        vacinationRepoMock.certificates = certs
        let viewModel = viewModel(boosterLogic: boosterLogicMock, repository: vacinationRepoMock, holderNeedsMask: true, maskRulesAvailable: true)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.1)
    }

    func test_maskNotNeeded() {
        let vacinationRepoMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = viewModel(repository: vacinationRepoMock, holderNeedsMask: false, maskRulesAvailable: true)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.1)
    }

    func test_maskRulesNotAvailable() {
        let vacinationRepoMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = viewModel(repository: vacinationRepoMock, holderNeedsMask: false, maskRulesAvailable: false)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.1)
    }

    func test_IsInvalid() {
        let vacinationRepoMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.invalid = true
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = viewModel(repository: vacinationRepoMock, holderNeedsMask: false)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.3)
    }

    func test_IsRevoked() {
        let vacinationRepoMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.revoked = true
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = viewModel(repository: vacinationRepoMock, holderNeedsMask: false)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.1)
    }

    func test_notification_invalid() {
        let vacinationRepoMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.revoked = true
        let certs = [cert]
        let boosterLogicMock = BoosterLogicMock()
        var boosterCandidate = BoosterCandidate(certificate: cert)
        boosterCandidate.state = .new
        boosterLogicMock.boosterCandidates = [boosterCandidate]
        vacinationRepoMock.certificates = certs
        let viewModel = viewModel(boosterLogic: boosterLogicMock, repository: vacinationRepoMock, holderNeedsMask: false)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.1)
    }

    func test_isExpired_more_than_90_days() {
        let vacinationRepoMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .day, value: -90, to: Date())
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = viewModel(repository: vacinationRepoMock, holderNeedsMask: false)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 1.0)
    }

    func test_isExpired_less_than_90_days() {
        let vacinationRepoMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = viewModel(repository: vacinationRepoMock, holderNeedsMask: false)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 1.0)
    }

    func test_aboutToExpire_in_28_days() {
        let vacinationRepoMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .day, value: 6, to: Date())
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = viewModel(repository: vacinationRepoMock, holderNeedsMask: false, maskRulesAvailable: true)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 1.5)
    }
}
