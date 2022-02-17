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

class GProofSnapShotTests: BaseSnapShotTests {
    
    let (_, resolver) = Promise<CBORWebToken>.pending()

    func testInitWithFailingTest() {
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        let initialToken = CBORWebToken.mockTestCertificate
        let routerMock = GProofMockRouter()
        let vm = GProofViewModel(resolvable: resolver,
                                 initialToken: initialToken,
                                 router: routerMock,
                                 repository: vaccinationRepoMock,
                                 certLogic: certLogicMock,
                                 userDefaults: UserDefaultsPersistence(),
                                 boosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testInitWithSuccessfulTest() {
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let initialToken = rapidTestToken()
        let routerMock = GProofMockRouter()
        let vm = GProofViewModel(resolvable: resolver,
                                 initialToken: initialToken,
                                 router: routerMock,
                                 repository: vaccinationRepoMock,
                                 certLogic: certLogicMock,
                                 userDefaults: UserDefaultsPersistence(),
                                 boosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        verifyView(vc: vc)
    }

    func testInitWithFailingVaccination() {
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let routerMock = GProofMockRouter()
        let vm = GProofViewModel(resolvable: resolver,
                                 initialToken: initialToken,
                                 router: routerMock,
                                 repository: vaccinationRepoMock,
                                 certLogic: certLogicMock,
                                 userDefaults: UserDefaultsPersistence(),
                                 boosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testInitWithSuccessfulVaccination() throws {
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let dateForTwelveMonthAgo = Calendar.current.date(byAdding: .month, value: -13, to: Date())
        initialToken.hcert.dgc.v!.first!.dt = try XCTUnwrap(dateForTwelveMonthAgo)

        let routerMock = GProofMockRouter()
        let vm = GProofViewModel(resolvable: resolver,
                                 initialToken: initialToken,
                                 router: routerMock,
                                 repository: vaccinationRepoMock,
                                 certLogic: certLogicMock,
                                 userDefaults: UserDefaultsPersistence(),
                                 boosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testInitWithSuccessfulVaccinationAndScannedSuccessfulTest() throws {
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let dateForTwelveMonthAgo = Calendar.current.date(byAdding: .month, value: -13, to: Date())
        initialToken.hcert.dgc.v!.first!.dt = try XCTUnwrap(dateForTwelveMonthAgo)
        let routerMock = GProofMockRouter()
        let vm = GProofViewModel(resolvable: resolver,
                                 initialToken: initialToken,
                                 router: routerMock,
                                 repository: vaccinationRepoMock,
                                 certLogic: certLogicMock,
                                 userDefaults: UserDefaultsPersistence(),
                                 boosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        vaccinationRepoMock.checkedCert = rapidTestToken()
        vm.scanNext()
        verifyAsync(vc: vc, wait: 0.1)
    }
    
    func testInitWithSuccessfulTestAndScannedFailingVaccination() {
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let initialToken = rapidTestToken()
        let routerMock = GProofMockRouter()
        let vm = GProofViewModel(resolvable: resolver,
                                 initialToken: initialToken,
                                 router: routerMock,
                                 repository: vaccinationRepoMock,
                                 certLogic: certLogicMock,
                                 userDefaults: UserDefaultsPersistence(),
                                 boosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        certLogicMock.validateResult = [.init(rule: nil, result: .fail, validationErrors: nil)]
        vaccinationRepoMock.checkedCert = CBORWebToken.mockVaccinationCertificate
        vm.scanNext()
        verifyAsync(vc: vc, wait: 0.1)
    }
    
    func testInitWithSuccessfulVaccinationAndScannedFailingTest() throws {
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let dateForTwelveMonthAgo = Calendar.current.date(byAdding: .month, value: -13, to: Date())
        initialToken.hcert.dgc.v!.first!.dt = try XCTUnwrap(dateForTwelveMonthAgo)
        let routerMock = GProofMockRouter()
        let vm = GProofViewModel(resolvable: resolver,
                                 initialToken: initialToken,
                                 router: routerMock,
                                 repository: vaccinationRepoMock,
                                 certLogic: certLogicMock,
                                 userDefaults: UserDefaultsPersistence(),
                                 boosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        certLogicMock.validateResult = [.init(rule: nil, result: .fail, validationErrors: nil)]
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        vm.scanNext()
        verifyAsync(vc: vc, wait: 0.1)
    }
    
    func testBoostedVaccinationWhereBosterCannotReplaceTest() throws {
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let initialToken = CBORWebToken.mockVaccinationCertificate
        initialToken.hcert.dgc.v!.first!.dn = 3
        initialToken.hcert.dgc.v!.first!.sd = 2
        let dateFor410DaysAgo = Calendar.current.date(byAdding: .day, value: -410, to: Date())
        initialToken.hcert.dgc.v!.first!.dt = try XCTUnwrap(dateFor410DaysAgo)
        let routerMock = GProofMockRouter()
        let vm = GProofViewModel(resolvable: resolver,
                                 initialToken: initialToken,
                                 router: routerMock,
                                 repository: vaccinationRepoMock,
                                 certLogic: certLogicMock,
                                 userDefaults: UserDefaultsPersistence(),
                                 boosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testBoostedVaccinationWhereBosterCanReplaceTest() throws {
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let initialToken = CBORWebToken.mockVaccinationCertificate
        initialToken.hcert.dgc.v!.first!.dn = 3
        initialToken.hcert.dgc.v!.first!.sd = 2
        let dateFor410DaysAgo = Calendar.current.date(byAdding: .day, value: -410, to: Date())
        initialToken.hcert.dgc.v!.first!.dt = try XCTUnwrap(dateFor410DaysAgo)
        let routerMock = GProofMockRouter()
        let vm = GProofViewModel(resolvable: resolver,
                                 initialToken: initialToken,
                                 router: routerMock,
                                 repository: vaccinationRepoMock,
                                 certLogic: certLogicMock,
                                 userDefaults: UserDefaultsPersistence(),
                                 boosterAsTest: true)
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
