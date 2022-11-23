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
    
    private var cert1OutOf1JohnsonJohnson: ExtendedCBORWebToken!
    private var cert2OutOf1Vaccinatio: ExtendedCBORWebToken!
    private var certRecoveryOldestInChain: ExtendedCBORWebToken!
    private var certificateHolderStatusModel: CertificateHolderStatusModelMock!
    private let (_, resolver) = Promise<CertificateDetailSceneResult>.pending()
    private var persistence: UserDefaultsPersistence!
    
    override func setUpWithError() throws {
        persistence = UserDefaultsPersistence()
        cert1OutOf1JohnsonJohnson = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("1")
            .seriesOfDoses(1)
            .doseNumber(1)
            .mockVaccinationSetDate(DateUtils.parseDate("2021-01-26T15:05:00")!)
            .medicalProduct(.johnsonjohnson)
            .extended(vaccinationQRCodeData: "1")
        cert2OutOf1Vaccinatio = CBORWebToken
            .mockVaccinationCertificate
            .mockVaccinationUVCI("2")
            .seriesOfDoses(1)
            .doseNumber(2)
            .mockVaccinationSetDate(DateUtils.parseDate("2021-04-26T15:05:00")!)
            .medicalProduct(.astrazeneca)
            .extended(vaccinationQRCodeData: "2")
        certRecoveryOldestInChain = CBORWebToken
            .mockRecoveryCertificate
            .mockRecoveryUVCI("3")
            .recoveryTestDate(DateUtils.parseDate("2020-12-26T15:05:00")!)
            .extended(vaccinationQRCodeData: "3")
        certificateHolderStatusModel = .init()
    }
    
    override func tearDownWithError() throws {
        persistence = nil
        cert1OutOf1JohnsonJohnson = nil
        cert2OutOf1Vaccinatio = nil
        certRecoveryOldestInChain = nil
        certificateHolderStatusModel = nil
    }
    
    func configureSut(certs: [ExtendedCBORWebToken],
                      bl: BoosterLogicProtocol = BoosterLogic(certLogic: DCCCertLogicMock(),
                                                              userDefaults: MockPersistence())) -> CertificateDetailViewModel {
        persistence.stateSelection = "SH"
        let bl = bl
        let vm = CertificateDetailViewModel(router: CertificateDetailRouterMock(),
                                            repository: VaccinationRepositoryMock(),
                                            boosterLogic: bl,
                                            certificates: certs,
                                            resolvable: resolver,
                                            certificateHolderStatusModel: certificateHolderStatusModel,
                                            userDefaults: persistence)
        return vm!
    }
    
    func testCertificateDetailViewController() {
        let certs: [ExtendedCBORWebToken] = [try! ExtendedCBORWebToken.mock()]
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
    
    func testCertificateDetail_Vaccination() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken
            .mockVaccinationCertificate
            .doseNumber(4)
            .extended()
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        certificateHolderStatusModel.holderIsFullyImmunized = true
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }

    func testCertificateDetail_Vaccination_From() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = DateUtils.isoDateFormatter.date(from: "2022-01-01")!
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
    
    func testCertificateDetail_Partly() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        let certs = [cert]
        certificateHolderStatusModel.needsMask = true
        vacinationRepoMock.certificates = certs
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
    
    func testCertificateDetail_Recovery() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
    
    func testCertificateDetail_Recovery_From() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.r!.first!.df =  DateUtils.parseDate("2025-04-26T15:05:00")!
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
    
    func testCertificateDetail_test() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
    
    func testCertificateDetail_IsExpired() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .year, value: -2, to: Date())
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
    
    func testCertificateDetail_IsInvalid() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.invalid = true
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
    
    func testCertificateDetail_AllTypes_Selected_Vaccination() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        
        // Invalid
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.invalid = true
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
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1800)
    }
    
    func testCertificateDetail_AllTypes_Selected_Vaccination_with_Bosster() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        
        // Invalid
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.invalid = true
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
        cert5.vaccinationCertificate.hcert.dgc.v!.first!.dn = 3
        cert5.vaccinationQRCodeData = "5"

        // Vaccination
        var cert6: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert6.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert6.vaccinationQRCodeData = "6"

        let certs = [cert, cert2, cert3, cert4, cert5, cert6]
        vacinationRepoMock.certificates = certs
        _ = BoosterLogic.init(certLogic: DCCCertLogicMock(),
                                   userDefaults: MockPersistence())
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1800)
    }
    
    func testCertificateDetail_AllTypes_Selected_Recovery() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        
        // Invalid
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.invalid = true
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
        cert4.vaccinationCertificate.hcert.dgc.r!.first!.du = DateUtils.parseDate("2027-04-26T15:05:00")!
        cert4.vaccinationQRCodeData = "4"

        // Vaccination Partly
        var cert5: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert5.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert5.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        cert5.vaccinationQRCodeData = "5"

        let certs = [cert, cert2, cert3, cert4, cert5]
        vacinationRepoMock.certificates = certs
        _ = BoosterLogic.init(certLogic: DCCCertLogicMock(),
                                   userDefaults: MockPersistence())
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1800)
    }
    
    func testCertificateDetail_AllTypes_Selected_Vaccination_Partly() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        
        // Invalid
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.invalid = true
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
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
    
    func testCertificateDetail_AllTypes_Selected_Invalid() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        
        // Invalid
        var cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.parseDate("2021-04-26T15:05:00")!
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.invalid = true
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
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
    
    func testCertificateDetail_Booster() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 2
        cert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 1
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = DateUtils.parseDate("2022-04-26T15:05:00")!
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1600)
    }
    
    var singleDoseImmunizationJohnsonCert = CBORWebToken.mockVaccinationCertificate
        .mockVaccinationUVCI("1")
        .medicalProduct(.johnsonjohnson)
        .doseNumber(1)
        .seriesOfDoses(1)
        .extended(vaccinationQRCodeData: "1")
    var vaccinationWithTwoShotsOfVaccine = CBORWebToken.mockVaccinationCertificate
        .mockVaccinationUVCI("2")
        .medicalProduct(.biontech)
        .doseNumber(2)
        .seriesOfDoses(2)
        .extended(vaccinationQRCodeData: "2")
    
    func testCertificateDetail_ShowReissueNotification() {
        var singleDoseImmunizationJohnsonCert = singleDoseImmunizationJohnsonCert
        singleDoseImmunizationJohnsonCert.reissueProcessNewBadgeAlreadySeen = false
        let certs = [singleDoseImmunizationJohnsonCert, vaccinationWithTwoShotsOfVaccine]
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1800)
    }
    
    func testCertificateDetail_ShowReissueNotification_NewBadgeAlreadySeen() {
        singleDoseImmunizationJohnsonCert.reissueProcessNewBadgeAlreadySeen = true
        let certs = [singleDoseImmunizationJohnsonCert, vaccinationWithTwoShotsOfVaccine]
        let vm = configureSut(certs: certs)
        let vc = CertificateDetailViewController(viewModel: vm)
        verifyView(view: vc.view, height: 1800)
    }
    
    func testCertificateIsRevoked() throws {
        var token = try ExtendedCBORWebToken.token1Of1()
        token.revoked = true
        let certs = [token]
        let viewModel = configureSut(certs: certs, bl: BoosterLogicMock())
        let viewController = CertificateDetailViewController(viewModel: viewModel)
        verifyView(view: viewController.view, height: 1600)
    }
    
    func testCertificateIsRevokedAndIsExpired() throws {
        var token = try ExtendedCBORWebToken.token1Of1()
        token.vaccinationCertificate.exp = Date() - 100
        token.revoked = true
        let certs = [token]
        let viewModel = configureSut(certs: certs, bl: BoosterLogicMock())
        let viewController = CertificateDetailViewController(viewModel: viewModel)
        verifyView(view: viewController.view, height: 1600)
    }

    func testReissueNotifications_new_badge_shown() {
        let viewModel = CertificateDetailViewModelMock()
        viewModel.showBoosterReissueIsNewBadge = true
        viewModel.showVaccinationExpiryReissueIsNewBadge = true
        viewModel.showBoosterReissueNotification = true
        viewModel.showRecoveryExpiryReissueIsNewBadgeValues = [true, true]
        let viewController = CertificateDetailViewController(viewModel: viewModel)
        verifyView(view: viewController.view, height: 1600)
    }
    
    func testReissueNotifications_new_badge_for_only_one_recovery() {
        let viewModel = CertificateDetailViewModelMock()
        viewModel.showVaccinationExpiryReissueNotification = true
        viewModel.showRecoveryExpiryReissueIsNewBadgeValues = [false, true]
        let viewController = CertificateDetailViewController(viewModel: viewModel)
        verifyView(view: viewController.view, height: 1600)
    }
    
    func test_maskRuleAvailable_and_notNeedMask_() throws {
        let date = try XCTUnwrap(DateUtils.parseDate("2021-01-26T15:05:00"))
        let token = CBORWebToken.mockVaccinationCertificate.mockVaccinationSetDate(date).extended()
        let certs = [token]
        certificateHolderStatusModel.areMaskRulesAvailable = true
        certificateHolderStatusModel.needsMask = false
        certificateHolderStatusModel.latestMaskRuleDate = DateUtils.parseDate("2021-01-26T15:05:00")
        let viewModel = configureSut(certs: certs, bl: BoosterLogicMock())
        let viewController = CertificateDetailViewController(viewModel: viewModel)
        verifyView(view: viewController.view, height: 1600)
    }
    
    func test_maskRuleAvailable_and_needMask_() throws {
        let date = try XCTUnwrap(DateUtils.parseDate("2021-01-26T15:05:00"))
        let token = CBORWebToken.mockVaccinationCertificate.mockVaccinationSetDate(date).extended()
        let certs = [token]
        certificateHolderStatusModel.areMaskRulesAvailable = true
        certificateHolderStatusModel.needsMask = true
        certificateHolderStatusModel.latestMaskRuleDate = DateUtils.parseDate("2021-01-26T15:05:00")
        let viewModel = configureSut(certs: certs, bl: BoosterLogicMock())
        let viewController = CertificateDetailViewController(viewModel: viewModel)
        verifyView(view: viewController.view, height: 1600)
    }
}
