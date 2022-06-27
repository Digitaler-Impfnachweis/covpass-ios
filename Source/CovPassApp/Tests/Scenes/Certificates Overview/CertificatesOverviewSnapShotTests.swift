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
            revocationRepository: CertificateRevocationRepositoryMock(),
            certLogic: DCCCertLogicMock(),
            boosterLogic: BoosterLogicMock(),
            userDefaults: UserDefaultsPersistence(),
            locale: .current,
            pdfExtractor: CertificateExtractorMock()
        )
    }
    
    func testCertificateOverviewCertificates() throws {
        let router = CertificatesOverviewRouterMock()
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert1: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert1.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert1.vaccinationCertificate.hcert.dgc.v!.first!.dt = try XCTUnwrap(Calendar.current.date(byAdding: .month, value: -16, to: Date()))!
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
        RunLoop.current.run(for: 0.5)
        verifyView(vc: viewController)
    }
    
    func test_Vaccination() throws {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = try! XCTUnwrap(Calendar.current.date(byAdding: .month, value: -16, to: Date()))!
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.3)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
    
    func test_vaccination_partly() throws {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = try XCTUnwrap(Calendar.current.date(byAdding: .month, value: -16, to: Date()))!
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.3)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
    
    func test_recovery() throws {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.fr = try XCTUnwrap(Calendar.current.date(byAdding: .month, value: -3, to: Date()))!
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.3)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
    
    func testCertificateOverviewCertificates_Test() throws {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = try XCTUnwrap(Calendar.current.date(byAdding: .hour, value: -8979, to: Date()))
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.3)
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
        RunLoop.current.run(for: 0.3)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
    
    func testCertificateOverviewCertificates_IsInvalid() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.invalid = true
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.5)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
    
    func testCertificateOverviewCertificates_IsRevoked() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.revoked = true
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.5)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
    
    
    func testJohnsonJohnson1OutOf1() throws {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.mp = MedicalProduct.johnsonjohnson.rawValue
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        cert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 1
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = try XCTUnwrap(Calendar.current.date(byAdding: .month, value: -16, to: Date()))
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.5)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
    
    func testJohnsonJohnson3OutOf1() throws {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.mp = MedicalProduct.johnsonjohnson.rawValue
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 3
        cert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 1
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -489, to: Date()))
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.5)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }

    func testDowngrade2OutOf1ToBasisImmunization() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.mp = MedicalProduct.biontech.rawValue
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 2
        cert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 1
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = Date()
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        secondCert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        secondCert.vaccinationCertificate.hcert.dgc.v!.first!.mp = MedicalProduct.johnsonjohnson.rawValue
        secondCert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        secondCert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 1
        secondCert.vaccinationCertificate.hcert.dgc.v!.first!.dt = Date()
        let certs = [cert, secondCert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.5)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }

    func testDowngrade2OutOf1ToBasisImmunizationAndRecoveryAsOldest() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.mp = MedicalProduct.biontech.rawValue
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 2
        cert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 1
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = Date()
        let recovery: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        recovery.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        recovery.vaccinationCertificate.hcert.dgc.r!.first!.fr = Date() - 100
        recovery.vaccinationCertificate.hcert.dgc.r!.first!.df = Date()
        recovery.vaccinationCertificate.hcert.dgc.r!.first!.du = Date()
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        secondCert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        secondCert.vaccinationCertificate.hcert.dgc.v!.first!.mp = MedicalProduct.johnsonjohnson.rawValue
        secondCert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        secondCert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 1
        secondCert.vaccinationCertificate.hcert.dgc.v!.first!.dt = Date()
        let certs = [cert,recovery,secondCert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.5)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
    
    func testDowngrade2OutOf1ToBasisImmunizationAndRecoveryAsNotOldest() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.mp = MedicalProduct.biontech.rawValue
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 2
        cert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 1
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = Date()
        let recovery: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        recovery.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        recovery.vaccinationCertificate.hcert.dgc.r!.first!.fr = Date() + 100
        recovery.vaccinationCertificate.hcert.dgc.r!.first!.df = Date()
        recovery.vaccinationCertificate.hcert.dgc.r!.first!.du = Date()
        let secondCert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        secondCert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        secondCert.vaccinationCertificate.hcert.dgc.v!.first!.mp = MedicalProduct.johnsonjohnson.rawValue
        secondCert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        secondCert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 1
        secondCert.vaccinationCertificate.hcert.dgc.v!.first!.dt = Date()
        let certs = [cert,recovery,secondCert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.5)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
    
    func test2Of2NotJJSoLessThan14Days_so_not_valid() throws {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.mp = MedicalProduct.biontech.rawValue
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 2
        cert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 2
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -10, to: Date()))
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let viewModel = self.viewModel(router: CertificatesOverviewRouterMock(), repository: vacinationRepoMock)
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        RunLoop.current.run(for: 0.5)
        verifyView(view: viewController.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))!)
    }
}
