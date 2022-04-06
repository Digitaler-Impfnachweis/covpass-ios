//
//  GProofSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import XCTest
import CovPassUI
import CovPassCommon
import PromiseKit
import CertLogic

class GProofSnapShotTests: BaseSnapShotTests {
    
    let (_, resolver) = Promise<ExtendedCBORWebToken>.pending()
    var vaccinationRepoMock: VaccinationRepositoryMock!
    var certLogicMock: DCCCertLogicMock!
    
    override func setUpWithError() throws {
        vaccinationRepoMock = VaccinationRepositoryMock()
        certLogicMock = DCCCertLogicMock()
    }
    
    override func tearDown() {
        vaccinationRepoMock = nil
        certLogicMock = nil
    }
    
    func viewModel(initialToken: ExtendedCBORWebToken,
            result: CertLogic.Result,
            convertBooster: Bool = false,
            bosterAsTest: Bool = false) -> GProofViewModel {
        certLogicMock.validateResult = [.init(rule: nil, result: result, validationErrors: nil)]
        let token = initialToken.vaccinationCertificate
        if token.isVaccination {
            let vaccination = token.hcert.dgc.v!.first!
            if convertBooster {
                vaccination.dn = 3
                vaccination.sd = 2
                let dateFor410DaysAgo = Calendar.current.date(byAdding: .day, value: -410, to: Date())
                vaccination.dt = try! XCTUnwrap(dateFor410DaysAgo)
            } else {
                let dateForTwelveMonthAgo = Calendar.current.date(byAdding: .month, value: -13, to: Date())
                vaccination.dt = try! XCTUnwrap(dateForTwelveMonthAgo)
            }
        }
        vaccinationRepoMock.checkedCert = token
        let routerMock = GProofMockRouter()
        return GProofViewModel(resolvable: resolver,
                               router: routerMock,
                               repository: vaccinationRepoMock,
                               revocationRepository: CertificateRevocationRepositoryMock(),
                               certLogic: certLogicMock,
                               userDefaults: UserDefaultsPersistence(),
                               boosterAsTest: bosterAsTest)

    }


    // MARK: Init flow with Token failing functional or Technical and passing
    
    func testInitWithSuccessfulVaccinationStartOverWithTechnicalFailingCertificate() throws {
        let initialToken = ExtendedCBORWebToken(vaccinationCertificate: .mockVaccinationCertificate,
                                                vaccinationQRCodeData: "")
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        vm.scanQRCode()
        RunLoop.main.run(for: 0.1)
        certLogicMock.validateResult = []
        vaccinationRepoMock.checkedCert = nil
        vm.startover()
        RunLoop.main.run(for: 0.1)
        verifyView(view: vc.view)
    }
    
    func testInitWithFunctionalFailingTest() {
        let initialToken = ExtendedCBORWebToken(vaccinationCertificate: .mockTestCertificate,
                                                vaccinationQRCodeData: "")
        let vm = viewModel(initialToken: initialToken, result: .fail)
        let vc = GProofViewController(viewModel: vm)
        vm.startover()
        RunLoop.main.run(for: 0.1)
        verifyView(view: vc.view)
    }
    
    func testInitWithFunctionalFailingVaccination() {
        let initialToken = ExtendedCBORWebToken(vaccinationCertificate: .mockVaccinationCertificate,
                                                vaccinationQRCodeData: "")
        let vm = viewModel(initialToken: initialToken, result: .fail)
        let vc = GProofViewController(viewModel: vm)
        vm.startover()
        RunLoop.main.run(for: 0.1)
        verifyView(view: vc.view)
    }
    
    func testInitWithSuccessfulTest() {
        let initialToken = ExtendedCBORWebToken(vaccinationCertificate: rapidTestToken(),
                                                vaccinationQRCodeData: "")
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        vm.startover()
        RunLoop.main.run(for: 0.1)
        verifyView(view: vc.view)
    }
    
    func testInitWithSuccessfulVaccination() throws {
        let initialToken = ExtendedCBORWebToken(vaccinationCertificate: .mockVaccinationCertificate,
                                                vaccinationQRCodeData: "")
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        vm.startover()
        RunLoop.main.run(for: 0.1)
        verifyView(view: vc.view)
    }
    
    // MARK: Init with some token and scan seccond failing functional or Technical and passing
    
    func testInitWithSuccessfulVaccinationAndScannedSuccessfulTest() throws {
        let initialToken = ExtendedCBORWebToken(vaccinationCertificate: .mockVaccinationCertificate,
                                                vaccinationQRCodeData: "")
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        vm.startover()
        RunLoop.main.run(for: 0.1)
        vaccinationRepoMock.checkedCert = rapidTestToken()
        vm.scanNext()
        RunLoop.main.run(for: 0.1)
        verifyView(view: vc.view)
    }
    
    func testInitWithSuccessfulVaccinationAndScannedFunctionalFailingTest() throws {
        let initialToken = ExtendedCBORWebToken(vaccinationCertificate: .mockVaccinationCertificate,
                                                vaccinationQRCodeData: "")
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        vm.startover()
        RunLoop.main.run(for: 0.1)
        certLogicMock.validateResult = [.init(rule: nil, result: .fail, validationErrors: nil)]
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        vm.scanNext()
        RunLoop.main.run(for: 0.1)
        verifyView(view: vc.view)
    }
    
    func testInitWithSuccessfulVaccinationAndScannedTechnicalFailingTest() throws {
        let initialToken = ExtendedCBORWebToken(vaccinationCertificate: .mockVaccinationCertificate,
                                                vaccinationQRCodeData: "")
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        vm.startover()
        RunLoop.main.run(for: 0.1)
        certLogicMock.validateResult = []
        vaccinationRepoMock.checkedCert = nil
        vm.scanNext()
        RunLoop.main.run(for: 0.1)
        verifyView(view: vc.view)
    }
    
    func testInitWithSuccessfulTestAndScannedSuccessfulVaccination() {
        let initialToken = ExtendedCBORWebToken(vaccinationCertificate: rapidTestToken(),
                                                vaccinationQRCodeData: "")
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        vm.startover()
        RunLoop.main.run(for: 0.1)
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let vaccinationToken: CBORWebToken = CBORWebToken.mockVaccinationCertificate
        let dateForTwelveMonthAgo = Calendar.current.date(byAdding: .month, value: -14, to: Date())
        vaccinationToken.hcert.dgc.v!.first!.dt = try! XCTUnwrap(dateForTwelveMonthAgo)
        vaccinationRepoMock.checkedCert = vaccinationToken
        vm.scanNext()
        RunLoop.main.run(for: 0.1)
        verifyView(view: vc.view)
    }
    
    func testInitWithSuccessfulTestAndScannedFunctionalFailingVaccination() {
        let initialToken = ExtendedCBORWebToken(vaccinationCertificate: rapidTestToken(),
                                                vaccinationQRCodeData: "")
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        vm.startover()
        RunLoop.main.run(for: 0.1)
        certLogicMock.validateResult = [.init(rule: nil, result: .fail, validationErrors: nil)]
        vaccinationRepoMock.checkedCert = CBORWebToken.mockVaccinationCertificate
        vm.scanNext()
        RunLoop.main.run(for: 0.1)
        verifyView(view: vc.view)
    }
    
    func testInitWithSuccessfulTestAndScannedTechnicalFailingVaccination() {
        let initialToken = ExtendedCBORWebToken(vaccinationCertificate: rapidTestToken(),
                                                vaccinationQRCodeData: "")
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        vm.startover()
        RunLoop.main.run(for: 0.1)
        certLogicMock.validateResult = []
        vaccinationRepoMock.checkedCert = nil
        vm.scanNext()
        RunLoop.main.run(for: 0.1)
        verifyView(view: vc.view)
    }

    
    func testBoostedVaccinationWhereBosterCannotReplaceTest() throws {
        let initialToken = ExtendedCBORWebToken(vaccinationCertificate: .mockVaccinationCertificate,
                                                vaccinationQRCodeData: "")
        let vm = viewModel(initialToken: initialToken, result: .passed, convertBooster: true, bosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        vm.startover()
        RunLoop.main.run(for: 0.1)
        verifyView(view: vc.view)
    }
    
    func testBoostedVaccinationWhereBosterCanReplaceTest() throws {
        let initialToken = ExtendedCBORWebToken(vaccinationCertificate: .mockVaccinationCertificate,
                                                vaccinationQRCodeData: "")
        let vm = viewModel(initialToken: initialToken, result: .passed, convertBooster: true, bosterAsTest: true)
        let vc = GProofViewController(viewModel: vm)
        vm.startover()
        RunLoop.main.run(for: 0.1)
        verifyView(view: vc.view)
    }

    private func rapidTestToken() -> CBORWebToken {
        var token = CBORWebToken.mockTestCertificate
        token.hcert.dgc.t = [
            Test(
                tg: "840539006",
                tt: "LP217198-3",
                nm: "SARS-CoV-2 Rapid Test",
                ma: "1360",
                sc: Date(),
                tr: "260373001",
                tc: "Test Center",
                co: "DE",
                is: "Robert Koch-Institut iOS",
                ci: "URN:UVCI:01DE/IBMT102/18Q12HTUJ45NO7ZTR2RGAS#C"
            )
        ]
        return token
    }
}
