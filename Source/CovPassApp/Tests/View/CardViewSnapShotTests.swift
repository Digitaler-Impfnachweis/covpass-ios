//
//  CardViewSnapShotTests.swift
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

class CardViewSnapShotTests: BaseSnapShotTests {
    
    func configureSut(certificate: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended(),
                      asBooster: Bool = true) throws -> CertificateCollectionViewCell {
        certificate.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        let vacinationRepoMock = VaccinationRepositoryMock()
        let boosterRepoMock = BoosterLogicMock()
        vacinationRepoMock.certificates = [certificate]
        if asBooster {
            var boosterCandidate = BoosterCandidate(certificate: certificate)
            boosterCandidate.state = .new
            boosterRepoMock.boosterCandidates = [boosterCandidate]
        }
        let viewModel = CertificateCardViewModel(token: certificate,
                                                 holderNeedsMask: true,
                                                 onAction: { _ in },
                                                 repository: vacinationRepoMock,
                                                 boosterLogic: boosterRepoMock)
        let view = UINib(nibName: "CertificateCollectionViewCell", bundle: .uiBundle).instantiate(withOwner: nil).first as! CertificateCollectionViewCell
        let viewController = UIViewController()
        viewController.view.addSubview(view)
        view.viewModel = viewModel
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        return view
    }

    func testBoosterNotification_test_certificate () throws {
        let cert: ExtendedCBORWebToken = CBORWebToken.mockTestCertificate.extended()
        let sut = try configureSut(certificate: cert, asBooster: true)
        verifyView(view: sut)
    }
    
    func testBoosterNotification_vaccination_partial_certificate () throws {
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 1
        cert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 2
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -489, to: Date()))
        let sut = try configureSut(certificate: cert)
        verifyView(view: sut)
    }
    
    func testBoosterNotification_vaccination_invalid () throws {
        var cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.invalid = true
        let sut = try configureSut(certificate: cert)
        verifyView(view: sut)
    }
}
