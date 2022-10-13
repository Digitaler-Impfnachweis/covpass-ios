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
import XCTest

class CertificateOverviewSnapShotTests: BaseSnapShotTests {
    
    private var userDefaults = UserDefaultsPersistence()
    
    func test_default() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let sceneCoordinator = DefaultSceneCoordinator(window: window)
        let router = CertificatesOverviewRouter(sceneCoordinator: sceneCoordinator)
        let viewModel = self.viewModel(router: router, repository: VaccinationRepositoryMock(), holderNeedsMask: true)
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
        var certificateHolderStatusModel: CertificateHolderStatusModelMock = CertificateHolderStatusModelMock()
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
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
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
        let viewModel = self.viewModel(repository: vacinationRepoMock, holderNeedsMask: false, maskRulesAvailable: true)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        userDefaults.stateSelection = "SH"
        verifyView(view: viewController.view, waitAfter: 0.1)
    }
    
    func test_anyToken_holder_maskNeeded_isFullyImmunized() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(repository: vacinationRepoMock, holderNeedsMask: true)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.3)
    }
    
    func test_booster_notification_holder_maskNeeded_isFullyImmunized() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let certs = [cert]
        let boosterLogicMock = BoosterLogicMock()
        var boosterCandidate: BoosterCandidate = BoosterCandidate(certificate: cert)
        boosterCandidate.state = .new
        boosterLogicMock.boosterCandidates = [boosterCandidate]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(boosterLogic: boosterLogicMock, repository: vacinationRepoMock, holderNeedsMask: true)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.1)
    }
    
    func test_anyToken_holder_maskNotNeeded_isFullyImmunized() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(repository: vacinationRepoMock, holderNeedsMask: false, maskRulesAvailable: true)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        userDefaults.stateSelection = "SH"
        verifyView(view: viewController.view, waitAfter: 0.1)
    }
    
    func test_anyToken_holder_maskNeeded_isNotFullyImmunized() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(repository: vacinationRepoMock, holderNeedsMask: true)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.1)
    }
    
    func test_anyToken_holder_maskNotNeeded_isNotFullyImmunized() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(repository: vacinationRepoMock, holderNeedsMask: false, maskRulesAvailable: true)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        userDefaults.stateSelection = "SH"
        verifyView(view: viewController.view, waitAfter: 0.1)
    }
    
    func test_IsExpired() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        cert.wasExpiryAlertShown = true
        cert.reissueProcessNewBadgeAlreadySeen = true
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(repository: vacinationRepoMock, holderNeedsMask: false)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.1)
    }
    
    func test_IsInvalid() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.invalid = true
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(repository: vacinationRepoMock, holderNeedsMask: false)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.1)
    }
    
    func test_IsRevoked() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.revoked = true
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(repository: vacinationRepoMock, holderNeedsMask: false)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.1)
    }
    
    func test_notification_invalid() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.revoked = true
        let certs = [cert]
        let boosterLogicMock = BoosterLogicMock()
        var boosterCandidate: BoosterCandidate = BoosterCandidate(certificate: cert)
        boosterCandidate.state = .new
        boosterLogicMock.boosterCandidates = [boosterCandidate]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(boosterLogic: boosterLogicMock, repository: vacinationRepoMock, holderNeedsMask: false)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.1)
    }
    
    func test_notification_IsExpired() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(repository: vacinationRepoMock, holderNeedsMask: false)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        verifyView(view: viewController.view, waitAfter: 0.1)
    }
    
    func test_notification_aboutToExpired() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .day, value: 6, to: Date())
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(repository: vacinationRepoMock, holderNeedsMask: false, maskRulesAvailable: true)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        userDefaults.stateSelection = "SH"
        verifyView(view: viewController.view, waitAfter: 1.3)
    }
}
