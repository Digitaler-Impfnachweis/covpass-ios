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
    
    func testInitWithFailingTest() {
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        let initialToken = CBORWebToken.mockTestCertificate
        let routerMock = GProofMockRouter()
        let vm = GProofViewModel(initialToken: initialToken,
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
        let vm = GProofViewModel(initialToken: initialToken,
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
        let vm = GProofViewModel(initialToken: initialToken,
                                 router: routerMock,
                                 repository: vaccinationRepoMock,
                                 certLogic: certLogicMock,
                                 userDefaults: UserDefaultsPersistence(),
                                 boosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testInitWithSuccessfulVaccination() {
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let routerMock = GProofMockRouter()
        let vm = GProofViewModel(initialToken: initialToken,
                                 router: routerMock,
                                 repository: vaccinationRepoMock,
                                 certLogic: certLogicMock,
                                 userDefaults: UserDefaultsPersistence(),
                                 boosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        verifyView(vc: vc)
    }
    
    func testInitWithSuccessfulVaccinationAndScannedSuccessfulTest() {
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let routerMock = GProofMockRouter()
        let vm = GProofViewModel(initialToken: initialToken,
                                 router: routerMock,
                                 repository: vaccinationRepoMock,
                                 certLogic: certLogicMock,
                                 userDefaults: UserDefaultsPersistence(),
                                 boosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        vaccinationRepoMock.checkedCert = rapidTestToken()
        vm.scanTest()
        verifyAsync(vc: vc, wait: 0.1)
    }
    
    func testInitWithSuccessfulTestAndScannedFailingVaccination() {
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let initialToken = rapidTestToken()
        let routerMock = GProofMockRouter()
        let vm = GProofViewModel(initialToken: initialToken,
                                 router: routerMock,
                                 repository: vaccinationRepoMock,
                                 certLogic: certLogicMock,
                                 userDefaults: UserDefaultsPersistence(),
                                 boosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        certLogicMock.validateResult = [.init(rule: nil, result: .fail, validationErrors: nil)]
        vaccinationRepoMock.checkedCert = CBORWebToken.mockVaccinationCertificate
        vm.scan2GProof()
        verifyAsync(vc: vc, wait: 0.1)
    }
    
    func testInitWithSuccessfulVaccinationAndScannedFailingTest() {
        let vaccinationRepoMock = VaccinationRepositoryMock()
        let certLogicMock = DCCCertLogicMock()
        certLogicMock.validateResult = [.init(rule: nil, result: .passed, validationErrors: nil)]
        let initialToken = CBORWebToken.mockVaccinationCertificate
        let routerMock = GProofMockRouter()
        let vm = GProofViewModel(initialToken: initialToken,
                                 router: routerMock,
                                 repository: vaccinationRepoMock,
                                 certLogic: certLogicMock,
                                 userDefaults: UserDefaultsPersistence(),
                                 boosterAsTest: false)
        let vc = GProofViewController(viewModel: vm)
        certLogicMock.validateResult = [.init(rule: nil, result: .fail, validationErrors: nil)]
        vaccinationRepoMock.checkedCert = CBORWebToken.mockTestCertificate
        vm.scanTest()
        verifyAsync(vc: vc, wait: 0.1)
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
