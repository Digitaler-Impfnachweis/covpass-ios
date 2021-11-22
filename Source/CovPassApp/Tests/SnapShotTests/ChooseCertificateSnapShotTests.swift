//
//  ChooseCertificateSnapShotTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import CovPassApp
@testable import CovPassCommon

class ChooseCertificateSnapShotTests: BaseSnapShotTests {
    
    func testNoMatch() {
        let vm = ChooseCertificateViewModel(router: nil,
                                            repository: VaccinationRepositoryMock(), vaasRepository: VAASRepositoryMock(),
                                            resolvable: nil)
        let vc = ChooseCertificateViewController(viewModel: vm)
        vc.view.bounds = UIScreen.main.bounds
        RunLoop.current.run(for: 0.1)
        verifyView(vc: vc)
    }
    
    func testMatchFive() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert1: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert1.vaccinationCertificate.hcert.dgc.nam.fn = "Schneider"
        cert1.vaccinationCertificate.hcert.dgc.nam.gn = "Andrea"
        cert1.vaccinationCertificate.hcert.dgc.nam.fnt = "Schneider"
        cert1.vaccinationCertificate.hcert.dgc.nam.gnt = "Andrea"
        cert1.vaccinationCertificate.hcert.dgc.dobString = "1990-07-12"
        var cert2: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert2.vaccinationCertificate.hcert.dgc.nam.fn = "Schneider"
        cert2.vaccinationCertificate.hcert.dgc.nam.gn = "Andrea"
        cert2.vaccinationCertificate.hcert.dgc.nam.fnt = "Schneider"
        cert2.vaccinationCertificate.hcert.dgc.nam.gnt = "Andrea"
        cert2.vaccinationCertificate.hcert.dgc.dobString = "1990-07-12"
        var cert3: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert3.vaccinationCertificate.hcert.dgc.nam.fn = "Schneider"
        cert3.vaccinationCertificate.hcert.dgc.nam.gn = "Andrea"
        cert3.vaccinationCertificate.hcert.dgc.nam.fnt = "Schneider"
        cert3.vaccinationCertificate.hcert.dgc.nam.gnt = "Andrea"
        cert3.vaccinationCertificate.hcert.dgc.dobString = "1990-07-12"
        cert3.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.isoDateFormatter.date(from: "2020-01-01")!
        var cert4: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert4.vaccinationCertificate.hcert.dgc.nam.fn = "Schneider"
        cert4.vaccinationCertificate.hcert.dgc.nam.gn = "Andrea"
        cert4.vaccinationCertificate.hcert.dgc.nam.fnt = "Schneider"
        cert4.vaccinationCertificate.hcert.dgc.nam.gnt = "Andrea"
        cert4.vaccinationCertificate.hcert.dgc.dobString = "1990-07-12"
        cert4.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        var cert5: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert5.vaccinationCertificate.hcert.dgc.nam.fn = "Schneider"
        cert5.vaccinationCertificate.hcert.dgc.nam.gn = "Andrea"
        cert5.vaccinationCertificate.hcert.dgc.nam.fnt = "Schneider"
        cert5.vaccinationCertificate.hcert.dgc.nam.gnt = "Andrea"
        cert5.vaccinationCertificate.hcert.dgc.dobString = "1990-07-12"
        cert5.vaccinationCertificate.hcert.dgc.t!.first!.tt = "LP217198-3"
        cert5.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.isoDateFormatter.date(from: "2020-01-01")!
        
        let certs = [cert1,
                     cert2,
                     cert3,
                     cert4,
                     cert5]
        vacinationRepoMock.certificates = certs
        let vm = ChooseCertificateViewModel(router: nil,
                                            repository: vacinationRepoMock,
                                            vaasRepository: VAASRepositoryMock(),
                                            resolvable: nil)
        let vc = ChooseCertificateViewController(viewModel: vm)
        vc.view.bounds = UIScreen.main.bounds
        RunLoop.current.run(for: 0.1)
        verifyView(vc: vc)
    }
    
    func testMatchOne() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert1: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert1.vaccinationCertificate.hcert.dgc.nam.fn = "Schneider"
        cert1.vaccinationCertificate.hcert.dgc.nam.gn = "Andrea"
        cert1.vaccinationCertificate.hcert.dgc.nam.fnt = "Schneider"
        cert1.vaccinationCertificate.hcert.dgc.nam.gnt = "Andrea"
        cert1.vaccinationCertificate.hcert.dgc.dobString = "1990-07-12"
        
        let certs = [cert1]
        vacinationRepoMock.certificates = certs
        let vm = ChooseCertificateViewModel(router: nil,
                                            repository: vacinationRepoMock,
                                            vaasRepository: VAASRepositoryMock(),
                                            resolvable: nil)
        let vc = ChooseCertificateViewController(viewModel: vm)
        vc.view.bounds = UIScreen.main.bounds
        RunLoop.current.run(for: 0.1)
        verifyView(vc: vc)
    }
    
    
    func testMatchFour() {
        let vacinationRepoMock: VaccinationRepositoryMock = VaccinationRepositoryMock()
        var cert1: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert1.vaccinationCertificate.hcert.dgc.nam.fn = "Schneider"
        cert1.vaccinationCertificate.hcert.dgc.nam.gn = "Andrea"
        cert1.vaccinationCertificate.hcert.dgc.nam.fnt = "Schneider"
        cert1.vaccinationCertificate.hcert.dgc.nam.gnt = "Andrea"
        cert1.vaccinationCertificate.hcert.dgc.dobString = "1990-07-12"
        var cert2: ExtendedCBORWebToken = CBORWebToken.mockRecoveryCertificate.extended()
        cert2.vaccinationCertificate.hcert.dgc.nam.fn = "Schneider"
        cert2.vaccinationCertificate.hcert.dgc.nam.gn = "Andrea"
        cert2.vaccinationCertificate.hcert.dgc.nam.fnt = "Schneider"
        cert2.vaccinationCertificate.hcert.dgc.nam.gnt = "Andrea"
        cert2.vaccinationCertificate.hcert.dgc.dobString = "1990-07-12"
        var cert3: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        cert3.vaccinationCertificate.hcert.dgc.nam.fn = "Schneider"
        cert3.vaccinationCertificate.hcert.dgc.nam.gn = "Andrea"
        cert3.vaccinationCertificate.hcert.dgc.nam.fnt = "Schneider"
        cert3.vaccinationCertificate.hcert.dgc.nam.gnt = "Andrea"
        cert3.vaccinationCertificate.hcert.dgc.dobString = "1990-07-12"
        cert3.vaccinationCertificate.hcert.dgc.t!.first!.sc = DateUtils.isoDateFormatter.date(from: "2020-01-01")!
        var cert4: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert4.vaccinationCertificate.hcert.dgc.nam.fn = "Schneider"
        cert4.vaccinationCertificate.hcert.dgc.nam.gn = "Andrea"
        cert4.vaccinationCertificate.hcert.dgc.nam.fnt = "Schneider"
        cert4.vaccinationCertificate.hcert.dgc.nam.gnt = "Andrea"
        cert4.vaccinationCertificate.hcert.dgc.dobString = "1990-07-12"
        cert4.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        
        let certs = [cert1,
                     cert2,
                     cert3,
                     cert4]
        vacinationRepoMock.certificates = certs
        let vm = ChooseCertificateViewModel(router: nil,
                                            repository: vacinationRepoMock,
                                            vaasRepository: VAASRepositoryMock(),
                                            resolvable: nil)
        let vc = ChooseCertificateViewController(viewModel: vm)
        vc.view.bounds = UIScreen.main.bounds
        RunLoop.current.run(for: 0.1)
        verifyView(vc: vc)
    }

}
