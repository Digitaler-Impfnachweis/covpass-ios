//
//  MockCertificateViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationPass
import VaccinationUI
import VaccinationCommon
import PromiseKit

class MockCertificateViewModel: CertificateViewModel {

    // MARK: - Test Variables
    
    var processCalled = false
    var configureCalled = false
    
    // MARK: - CertificateViewModel
    
    weak var delegate: CertificateViewModelDelegate?
    
    var addButtonImage: UIImage? = UIImage()
    
    var certificates: [BaseCertifiateConfiguration] = [
        MockCellConfiguration.noCertificateConfiguration()
    ]
    
    func process(payload: String, completion: ((Error) -> Void)?) {
        processCalled = true
    }
    
    func configure<T>(cell: T, at indexPath: IndexPath) where T : CellConfigutation {
        configureCalled = true
    }
    
    func reuseIdentifier(for indexPath: IndexPath) -> String {
        certificates[indexPath.row].identifier
    }
    
    var headlineTitle: String {
        "Title"
    }

    var headlineButtonImage: UIImage?{
        nil
    }

    func loadCertificatesConfiguration() {
        certificates = [MockCellConfiguration.noCertificateConfiguration()]
    }

    func process(payload: String) -> Promise<ExtendedCBORWebToken> {
        return Promise.init(error: ApplicationError.unknownError)
    }

    func detailViewModel(_ cert: ExtendedCBORWebToken) -> VaccinationDetailViewModel? {
        return nil
    }

    func detailViewModel(_ indexPath: IndexPath) -> VaccinationDetailViewModel? {
        return nil
    }

    func showCertificate(at indexPath: IndexPath) {
        // TODO: Add tests
    }

    func showCertificate(_ certificate: ExtendedCBORWebToken) {
        // TODO: Add tests
    }

    func scanCertificate() {
        // TODO: Add tests
    }

    func showAppInformation() {
        // TODO: Add tests
    }
}
