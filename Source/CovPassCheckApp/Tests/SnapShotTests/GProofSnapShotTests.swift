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
    
    let (_, resolver) = Promise<CBORWebToken>.pending()
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
    
    func viewModel(initialToken: CBORWebToken,
            result: CertLogic.Result,
            convertBooster: Bool = false,
            bosterAsTest: Bool = false) -> GProofViewModel {
        certLogicMock.validateResult = [.init(rule: nil, result: result, validationErrors: nil)]
        if initialToken.isVaccination {
            if convertBooster {
                initialToken.hcert.dgc.v!.first!.dn = 3
                initialToken.hcert.dgc.v!.first!.sd = 2
                let dateFor410DaysAgo = Calendar.current.date(byAdding: .day, value: -410, to: Date())
                initialToken.hcert.dgc.v!.first!.dt = try! XCTUnwrap(dateFor410DaysAgo)
            } else {
                let dateForTwelveMonthAgo = Calendar.current.date(byAdding: .month, value: -13, to: Date())
                initialToken.hcert.dgc.v!.first!.dt = try! XCTUnwrap(dateForTwelveMonthAgo)
            }
        }
        let routerMock = GProofMockRouter()
        return GProofViewModel(resolvable: resolver,
                             initialToken: initialToken,
                             router: routerMock,
                             repository: vaccinationRepoMock,
                             certLogic: certLogicMock,
                             userDefaults: UserDefaultsPersistence(),
                             boosterAsTest: bosterAsTest)

    }


    // MARK: Init flow with Token failing functional or Technical and passing
    
    func testInitWithSuccessfulVaccinationStartOverWithTechnicalFailingCertificate() throws {
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        certLogicMock.validateResult = []
        vaccinationRepoMock.checkedCert = nil
        vm.startover()
        verifyAsync(vc: vc, wait: 0.1)
    }
    
    func testInitWithFunctionalFailingTest() {
        let initialToken = CBORWebToken.mockTestCertificate
        let vm = viewModel(initialToken: initialToken, result: .fail)
        let vc = GProofViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testInitWithFunctionalFailingVaccination() {
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let vm = viewModel(initialToken: initialToken, result: .fail)
        let vc = GProofViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testInitWithSuccessfulTest() {
        let initialToken = rapidTestToken()
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testInitWithSuccessfulVaccination() throws {
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    // MARK: Init with some token and scan seccond failing functional or Technical and passing
    
    func testInitWithSuccessfulVaccinationAndScannedSuccessfulTest() throws {
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        vaccinationRepoMock.checkedCert = rapidTestToken()
        vm.scanNext()
        verifyAsync(vc: vc, wait: 0.1)
    }
    
    func testInitWithSuccessfulVaccinationAndScannedFunctionalFailingTest() throws {
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        certLogicMock.validateResult = [.init(rule: nil, result: .fail, validationErrors: nil)]
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        vm.scanNext()
        verifyAsync(vc: vc, wait: 0.1)
    }
    
    func testInitWithSuccessfulVaccinationAndScannedTechnicalFailingTest() throws {
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        certLogicMock.validateResult = []
        vaccinationRepoMock.checkedCert = nil
        vm.scanNext()
        verifyAsync(vc: vc, wait: 0.1)
    }
    
    func testInitWithSuccessfulTestAndScannedSuccessfulVaccination() {
        let initialToken = rapidTestToken()
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        vaccinationRepoMock.checkedCert = CBORWebToken.mockVaccinationCertificate
        vm.scanNext()
        verifyAsync(vc: vc, wait: 0.1)
    }
    
    func testInitWithSuccessfulTestAndScannedFunctionalFailingVaccination() {
        let initialToken = rapidTestToken()
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        certLogicMock.validateResult = [.init(rule: nil, result: .fail, validationErrors: nil)]
        vaccinationRepoMock.checkedCert = CBORWebToken.mockVaccinationCertificate
        vm.scanNext()
        verifyAsync(vc: vc, wait: 0.1)
    }
    
    func testInitWithSuccessfulTestAndScannedTechnicalFailingVaccination() {
        let initialToken = rapidTestToken()
        let vm = viewModel(initialToken: initialToken, result: .passed)
        let vc = GProofViewController(viewModel: vm)
        certLogicMock.validateResult = []
        vaccinationRepoMock.checkedCert = nil
        vm.scanNext()
        verifyAsync(vc: vc, wait: 0.1)
    }

    
    func testBoostedVaccinationWhereBosterCannotReplaceTest() throws {
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let vm = viewModel(initialToken: initialToken, result: .passed, convertBooster: true, bosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testBoostedVaccinationWhereBosterCanReplaceTest() throws {
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let vm = viewModel(initialToken: initialToken, result: .passed, convertBooster: true, bosterAsTest: true)
        let vc = GProofViewController(viewModel: vm)
        verifyView(vc: vc)
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
