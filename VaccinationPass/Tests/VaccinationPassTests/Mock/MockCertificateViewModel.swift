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

class MockCertificateViewModel: CertificateViewModel {

    // MARK: - Test Variables
    
    var processCalled = false
    var configureCalled = false
    
    // MARK: - CertificateViewModel
    
    weak var delegate: ViewModelDelegate?
    
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
    
    var headlineButtonInsets: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0 )
    }
    
    var headlineFont: UIFont {
        UIFont.systemFont(ofSize: 20)
    }
    
    var headlineButtonImage: UIImage?{
        nil
    }

    func loadCertificatesConfiguration() {
        certificates = [MockCellConfiguration.noCertificateConfiguration()]
    }

    func process(payload: String, completion: @escaping ((ExtendedVaccinationCertificate?, Error?) -> Void)) {

    }

    func detailViewModel(_ indexPath: IndexPath) -> VaccinationDetailViewModel? {
        return nil
    }
}
