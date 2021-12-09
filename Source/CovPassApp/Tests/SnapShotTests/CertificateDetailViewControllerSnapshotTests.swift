//
//  CertificateDetailViewControllerSnapshotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import XCTest
import PromiseKit


class CertificateDetailViewControllerSnapshotTests: BaseSnapShotTests {

    func testCertificateDetailViewController() {
        let (_, resolver) = Promise<CertificateDetailSceneResult>.pending()
        let bl = BoosterLogic.init(certLogic: DCCCertLogicMock(), userDefaults: MockPersistence())
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(), repository: VaccinationRepositoryMock(), boosterLogic: bl, certificates: [try! ExtendedCBORWebToken.mock()], resolvable: resolver)
        let vc = CertificateDetailViewController(viewModel: vm)

        verifyView(view: vc.view, height: 1100)
    }
    
    func testCertificateDetail_Vaccination() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let bl = BoosterLogic.init(certLogic: DCCCertLogicMock(),
                                   userDefaults: MockPersistence())
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(),
                                            repository: VaccinationRepositoryMock(),
                                            boosterLogic: bl,
                                            certificates: certs,
                                            resolvable: nil)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1100)
    }
    
    func testCertificateDetail_Vaccination_From() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = DateUtils.isoDateFormatter.date(from: "2022-01-01")!
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let bl = BoosterLogic.init(certLogic: DCCCertLogicMock(),
                                   userDefaults: MockPersistence())
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(),
                                            repository: VaccinationRepositoryMock(),
                                            boosterLogic: bl,
                                            certificates: certs,
                                            resolvable: nil)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1100)
    }
    
    func testCertificateDetail_Partly() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let bl = BoosterLogic.init(certLogic: DCCCertLogicMock(),
                                   userDefaults: MockPersistence())
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(),
                                            repository: VaccinationRepositoryMock(),
                                            boosterLogic: bl,
                                            certificates: certs,
                                            resolvable: nil)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1100)
    }
    
    func testCertificateDetail_Recovery() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let bl = BoosterLogic.init(certLogic: DCCCertLogicMock(),
                                   userDefaults: MockPersistence())
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(),
                                            repository: VaccinationRepositoryMock(),
                                            boosterLogic: bl,
                                            certificates: certs,
                                            resolvable: nil)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1100)
    }
    
    func testCertificateDetail_Recovery_From() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.df = Date().addingTimeInterval(1000)
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let bl = BoosterLogic.init(certLogic: DCCCertLogicMock(),
                                   userDefaults: MockPersistence())
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(),
                                            repository: VaccinationRepositoryMock(),
                                            boosterLogic: bl,
                                            certificates: certs,
                                            resolvable: nil)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1100)
    }
    
    func testCertificateDetail_test() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let bl = BoosterLogic.init(certLogic: DCCCertLogicMock(),
                                   userDefaults: MockPersistence())
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(),
                                            repository: VaccinationRepositoryMock(),
                                            boosterLogic: bl,
                                            certificates: certs,
                                            resolvable: nil)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1100)
    }
    
    func testCertificateDetail_IsExpired() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let bl = BoosterLogic.init(certLogic: DCCCertLogicMock(),
                                   userDefaults: MockPersistence())
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(),
                                            repository: VaccinationRepositoryMock(),
                                            boosterLogic: bl,
                                            certificates: certs,
                                            resolvable: nil)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1100)
    }
    
    func testCertificateDetail_IsInvalid() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.invalid = true
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let bl = BoosterLogic.init(certLogic: DCCCertLogicMock(),
                                   userDefaults: MockPersistence())
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(),
                                            repository: VaccinationRepositoryMock(),
                                            boosterLogic: bl,
                                            certificates: certs,
                                            resolvable: nil)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1100)
    }
    
    func testCertificateDetail_AllTypes_Selected_Vaccination() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        
        // Invalid
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.invalid = true
        cert.vaccinationQRCodeData = " "

        // Test
        var cert2: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert2.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert2.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert2.vaccinationQRCodeData = "2"

        // Is Expired
        var cert3: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert3.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert3.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert3.vaccinationCertificate.exp = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        cert3.vaccinationQRCodeData = "3"

        // Recovery
        var cert4: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert4.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert4.vaccinationQRCodeData = "4"

        // Vaccination Partly
        var cert5: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert5.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert5.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        cert5.vaccinationQRCodeData = "5"

        // Vaccination
        var cert6: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert6.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert6.vaccinationQRCodeData = "6"

        let certs = [cert, cert2, cert3, cert4, cert5, cert6]
        vacinationRepoMock.certificates = certs
        let bl = BoosterLogic.init(certLogic: DCCCertLogicMock(),
                                   userDefaults: MockPersistence())
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(),
                                            repository: VaccinationRepositoryMock(),
                                            boosterLogic: bl,
                                            certificates: certs,
                                            resolvable: nil)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
    
    func testCertificateDetail_AllTypes_Selected_Recovery() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        
        // Invalid
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.invalid = true
        cert.vaccinationQRCodeData = " "

        // Test
        var cert2: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert2.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert2.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert2.vaccinationQRCodeData = "2"

        // Is Expired
        var cert3: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert3.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert3.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert3.vaccinationCertificate.exp = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        cert3.vaccinationQRCodeData = "3"

        // Recovery
        var cert4: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert4.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert4.vaccinationQRCodeData = "4"

        // Vaccination Partly
        var cert5: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert5.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert5.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        cert5.vaccinationQRCodeData = "5"

        let certs = [cert, cert2, cert3, cert4, cert5]
        vacinationRepoMock.certificates = certs
        let bl = BoosterLogic.init(certLogic: DCCCertLogicMock(),
                                   userDefaults: MockPersistence())
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(),
                                            repository: VaccinationRepositoryMock(),
                                            boosterLogic: bl,
                                            certificates: certs,
                                            resolvable: nil)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
    
    func testCertificateDetail_AllTypes_Selected_Vaccination_Partly() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        
        // Invalid
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.invalid = true
        cert.vaccinationQRCodeData = " "

        // Test
        var cert2: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert2.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert2.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert2.vaccinationQRCodeData = "2"

        // Is Expired
        var cert3: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert3.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert3.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert3.vaccinationCertificate.exp = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        cert3.vaccinationQRCodeData = "3"

        // Vaccination Partly
        var cert5: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert5.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert5.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        cert5.vaccinationQRCodeData = "5"

        let certs = [cert, cert2, cert3, cert5]
        vacinationRepoMock.certificates = certs
        let bl = BoosterLogic.init(certLogic: DCCCertLogicMock(),
                                   userDefaults: MockPersistence())
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(),
                                            repository: VaccinationRepositoryMock(),
                                            boosterLogic: bl,
                                            certificates: certs,
                                            resolvable: nil)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
    
    func testCertificateDetail_AllTypes_Selected_Invalid() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        
        // Invalid
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.invalid = true
        cert.vaccinationQRCodeData = " "

        // Test
        var cert2: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert2.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert2.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert2.vaccinationQRCodeData = "2"

        // Is Expired
        var cert3: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert3.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert3.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert3.vaccinationCertificate.exp = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        cert3.vaccinationQRCodeData = "3"

        
        let certs = [cert, cert2, cert3]
        vacinationRepoMock.certificates = certs
        let bl = BoosterLogic.init(certLogic: DCCCertLogicMock(),
                                   userDefaults: MockPersistence())
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(),
                                            repository: VaccinationRepositoryMock(),
                                            boosterLogic: bl,
                                            certificates: certs,
                                            resolvable: nil)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
}

struct CertificateDetailRouterMock: CertificateDetailRouterProtocol {
    func showCertificate(for token: ExtendedCBORWebToken) -> Promise<Void> {
        .value
    }
    
    func showDetail(for certificate: ExtendedCBORWebToken) -> Promise<CertificateDetailSceneResult> {
        .value(.addNewCertificate)
    }

    func showWebview(_ url: URL) {
        
    }

    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
}
