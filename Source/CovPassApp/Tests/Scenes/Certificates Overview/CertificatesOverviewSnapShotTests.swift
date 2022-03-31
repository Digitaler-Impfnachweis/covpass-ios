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
        let viewModel = self.viewModel(router: router, repository: VaccinationRepositoryMock())
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        verifyAsync(vc: navigationController)
    }

    private func viewModel(
        router: CertificatesOverviewRouterProtocol,
        repository: VaccinationRepositoryProtocol
    ) -> CertificatesOverviewViewModelProtocol {
        CertificatesOverviewViewModel(
            router: router,
            repository: repository,
            certLogic: DCCCertLogicMock(),
            boosterLogic: BoosterLogicMock(),
            userDefaults: UserDefaultsPersistence(),
            locale: .current
        )
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
        cert1.vaccinationCertificate.hcert.dgc.nam.fnt = "JOHN1"
        cert2.vaccinationCertificate.hcert.dgc.nam.fnt = "JOHN2"
        cert3.vaccinationCertificate.hcert.dgc.nam.fnt = "JOHN3"
        let certs = [cert1,
                     cert2,
                     cert3]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: router, repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        viewController.view.bounds = UIScreen.main.bounds
        RunLoop.current.run(for: 0.1)
        verifyView(vc: viewController)
    }
    
    func testCertificateOverviewCertificates_Vaccination() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.2)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
    
    func testCertificateOverviewCertificates_Vaccination_Partly() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.2)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
    
    func testCertificateOverviewCertificates_Recovery() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.2)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
    
    func testCertificateOverviewCertificates_Test() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.2)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
    
    func testCertificateOverviewCertificates_IsExpired() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.2)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
    
    func testCertificateOverviewCertificates_IsInvalid() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.invalid = true
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.2)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
}
