//
//  MockCertificateViewModel.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationPass
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
    
    var certificateViewModels: [CardViewModel] = []
    
    func process(payload: String, completion: ((Error) -> Void)?) {
        processCalled = true
    }

    func reuseIdentifier(for indexPath: IndexPath) -> String {
        certificateViewModels[indexPath.row].reuseIdentifier
    }
    
    var headlineTitle: String {
        "Title"
    }

    var headlineButtonImage: UIImage?{
        nil
    }

    func loadCertificates() {
        certificateViewModels = [MockCardViewModel()]
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

    func showErrorDialog() {
        // TODO: Add tests
    }
}
