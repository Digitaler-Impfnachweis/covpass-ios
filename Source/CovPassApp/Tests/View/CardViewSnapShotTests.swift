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
    
    func testBoosterNotification() throws {
        let vacinationRepoMock = VaccinationRepositoryMock()
        let boosterRepoMock = BoosterLogicMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.mp = MedicalProduct.johnsonjohnson.rawValue
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 3
        cert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 1
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -489, to: Date()))
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        var boosterCandidate = BoosterCandidate(certificate: cert)
        boosterCandidate.state = .new
        boosterRepoMock.boosterCandidates = [boosterCandidate]
        let viewModel = CertificateCardViewModel(token: cert,
                                                 vaccinations: [],
                                                 recoveries: [],
                                                 isFavorite: false,
                                                 showFavorite: false,
                                                 onAction: { _ in },
                                                 onFavorite: { _ in },
                                                 repository: vacinationRepoMock,
                                                 boosterLogic: boosterRepoMock )
        let view = UINib(nibName: "CertificateCollectionViewCell", bundle: .uiBundle).instantiate(withOwner: nil).first as! CertificateCollectionViewCell
        let viewController = UIViewController()
        viewController.view.addSubview(view)
        view.viewModel = viewModel
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        verifyView(view: view)
    }

    func testBasicImmunizationNotification() throws {
        let vacinationRepoMock = VaccinationRepositoryMock()
        let boosterRepoMock = BoosterLogicMock()
        let cert: ExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        cert.vaccinationCertificate.hcert.dgc.nam.fn = "John 1"
        cert.vaccinationCertificate.hcert.dgc.v!.first!.mp = MedicalProduct.biontech.rawValue
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dn = 2
        cert.vaccinationCertificate.hcert.dgc.v!.first!.sd = 2
        cert.vaccinationCertificate.hcert.dgc.v!.first!.dt = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -489, to: Date()))
        let certs = [cert]
        vacinationRepoMock.certificates = certs
        var boosterCandidate = BoosterCandidate(certificate: cert)
        boosterCandidate.state = .new
        boosterRepoMock.boosterCandidates = [boosterCandidate]
        let viewModel = CertificateCardViewModel(token: cert,
                                                 vaccinations: [],
                                                 recoveries: [],
                                                 isFavorite: false,
                                                 showFavorite: false,
                                                 onAction: { _ in },
                                                 onFavorite: { _ in },
                                                 repository: vacinationRepoMock,
                                                 boosterLogic: boosterRepoMock )
        let view = UINib(nibName: "CertificateCollectionViewCell", bundle: .uiBundle).instantiate(withOwner: nil).first as! CertificateCollectionViewCell
        let viewController = UIViewController()
        viewController.view.addSubview(view)
        view.viewModel = viewModel
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        verifyView(view: view)
    }
    
}
