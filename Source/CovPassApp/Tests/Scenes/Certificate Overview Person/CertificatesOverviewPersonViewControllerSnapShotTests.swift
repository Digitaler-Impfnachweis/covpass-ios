//
//  CertificatesOverviewPersonViewControllerSnapShotTests.swift
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

class CertificatesOverviewPersonViewControllerSnapShotTests: BaseSnapShotTests {
    let (_, resolver) = Promise<CertificateDetailSceneResult>.pending()
    private func viewModel(certificates: [ExtendedCBORWebToken],
                           router _: CertificatesOverviewPersonRouterMock = CertificatesOverviewPersonRouterMock(),
                           repository: VaccinationRepositoryMock = VaccinationRepositoryMock(),
                           boosterLogicMock: BoosterLogicMock = BoosterLogicMock()) -> CertificatesOverviewPersonViewModelProtocol {
        repository.certificates = certificates
        return CertificatesOverviewPersonViewModel(router: CertificatesOverviewPersonRouterMock(),
                                                   persistence: MockPersistence(),
                                                   repository: repository,
                                                   boosterLogic: boosterLogicMock,
                                                   certificates: certificates,
                                                   resolver: resolver)
    }

    func test_vaccination() throws {
        let cert1: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert1.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert1.vaccinationCertificate.hcert.dgc.v!.first!.dt = try XCTUnwrap(Calendar.current.date(byAdding: .month, value: -16, to: Date()))
        let certs = [cert1]
        let viewModel = viewModel(certificates: certs)
        let viewController = CertificatesOverviewPersonViewController(viewModel: viewModel)
        viewController.view.bounds = UIScreen.main.bounds
        verifyView(view: viewController.view)
    }

    func test_recovery() throws {
        let cert1: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert1.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert1.vaccinationCertificate.hcert.dgc.r!.first!.fr = try XCTUnwrap(Calendar.current.date(byAdding: .month, value: -3, to: Date()))
        let certs = [cert1]

        let viewModel = viewModel(certificates: certs)
        let viewController = CertificatesOverviewPersonViewController(viewModel: viewModel)
        viewController.view.bounds = UIScreen.main.bounds
        verifyView(view: viewController.view)
    }

    func test_test() {
        let cert1: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert1.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        let certs = [cert1]
        let viewModel = viewModel(certificates: certs)
        let viewController = CertificatesOverviewPersonViewController(viewModel: viewModel)
        viewController.view.bounds = UIScreen.main.bounds
        verifyView(view: viewController.view)
    }

    func test_vaccination_partly() throws {
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = try XCTUnwrap(Calendar.current.date(byAdding: .month, value: -16, to: Date()))
        let certs = [cert]
        let viewModel = viewModel(certificates: certs)
        let viewController = CertificatesOverviewPersonViewController(viewModel: viewModel)
        viewController.view.bounds = UIScreen.main.bounds
        verifyView(view: viewController.view)
    }

    func test_vaccination_2Of2NotJJSoLessThan14Days_so_not_valid() throws {
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.mp = MedicalProduct.biontech.rawValue
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 2
        cert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 2
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -10, to: Date()))
        let certs = [cert]
        let viewModel = viewModel(certificates: certs)
        let viewController = CertificatesOverviewPersonViewController(viewModel: viewModel)
        viewController.view.bounds = UIScreen.main.bounds
        verifyView(view: viewController.view)
    }

    func test_notification_more_than_one_certificate() throws {
        let boosterLogicMock = BoosterLogicMock()
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
        let certs = [cert, recovery, secondCert]
        var boosterCandidate = BoosterCandidate(certificate: recovery)
        boosterCandidate.state = .new
        boosterLogicMock.boosterCandidates = [boosterCandidate]
        let viewModel = viewModel(certificates: certs, boosterLogicMock: boosterLogicMock)
        let viewController = CertificatesOverviewPersonViewController(viewModel: viewModel)
        viewController.view.bounds = UIScreen.main.bounds
        verifyView(view: viewController.view)
    }

    func test_notification() throws {
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        let boosterLogicMock = BoosterLogicMock()
        var boosterCandidate = BoosterCandidate(certificate: cert)
        boosterCandidate.state = .new
        boosterLogicMock.boosterCandidates = [boosterCandidate]
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.mp = MedicalProduct.biontech.rawValue
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 2
        cert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 2
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -10, to: Date()))
        let certs = [cert]
        let viewModel = viewModel(certificates: certs, boosterLogicMock: boosterLogicMock)
        let viewController = CertificatesOverviewPersonViewController(viewModel: viewModel)
        viewController.view.bounds = UIScreen.main.bounds
        verifyView(view: viewController.view)
    }
}
