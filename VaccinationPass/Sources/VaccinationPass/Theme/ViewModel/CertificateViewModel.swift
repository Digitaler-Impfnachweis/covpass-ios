//
//  CertificateViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import VaccinationUI
import UIKit
import VaccinationCommon

public class CertificateViewModel {
    // MARK: - Private
    
    private let parser: QRCodeProcessor = QRCodeProcessor()
    
    // MARK: - Internal
    
    weak var stateDelegate: CertificateStateDelegate?
    var certificateState: CertificateState = .none {
        didSet { stateDelegate?.didUpdatedCertificate(state: certificateState) }
    }
    var title: String { "vaccination_certificate_list_title".localized }
    
    var addButtonImage: UIImage? {
        UIImage(named: UIConstants.IconName.PlusIcon, in: UIConstants.bundle, compatibleWith: nil)
    }
    
    var titles = [
        "vaccination_certificate_first_faq".localized,
        "vaccination_certificate_second_faq".localized,
        "vaccination_certificate_third_faq".localized]

    var faqTitle: String { "vaccination_certificate_faq_title".localized }

    var showAllFaqTitle: String {  "vaccination_certificate_all_faq_title".localized }

    // MARK: - No Certificate Configuration
    var noCertificateCardTitle: String { "vaccination_no_certificate_card_title".localized }

    var noCertificateCardMessage: String { "vaccination_no_certificate_card_message".localized }

    var noCertificateActionTitle: String { "vaccination_certificate_add_button_title".localized }
    
    // MARK: - Half Certificate Configuration
    var halfCertificateActionTitle: String { "vaccination_certificate_add_button_title".localized }
    
    func configure(cell: ActionCell, at indexPath: IndexPath) {
        cell.configure(title: titles[indexPath.row], iconName: UIConstants.IconName.ChevronRight)
    }
    
    func process(payload: String) {
        guard let decodedPayload = parser.parse(payload) else { return }
        print(decodedPayload)
        // Do more processes
        certificateState = .half
    }
    
    // MARK: - UIConfigureation
    
    let continerCornerRadius: CGFloat = 20
    let continerHeight: CGFloat = 200
    var headerButtonInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 0)
}
