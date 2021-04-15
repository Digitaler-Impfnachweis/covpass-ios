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

public struct CertificateViewModel {
    let parser: QRCodeProcessor = QRCodeProcessor()
    
    var title: String {
        "vaccination_certificate_list_title".localized
    }

    var faqTitel: String {
        "vaccination_certificate_faq_title".localized
    }

    var showAllFaqTitle: String {
        "vaccination_certificate_all_faq_title".localized
    }

    var noCertificateCardTitle: String {
        "vaccination_no_certificate_card_title".localized
    }

    var noCertificateCardMessage: String {
        "vaccination_no_certificate_card_message".localized
    }
    

    var addButtonTitle: String {
        "vaccination_certificate_add_button_title".localized
    }
    var addButtonImage: UIImage? {
        UIImage(named: UIConstants.IconName.PlusIcon, in: UIConstants.bundle, compatibleWith: nil)
    }
    
    public var titles = [
        "vaccination_certificate_first_faq".localized,
        "vaccination_certificate_second_faq".localized,
        "vaccination_certificate_third_faq".localized]
    
    func configure(cell: ActionCell, at indexPath: IndexPath) {
        cell.configure(title: titles[indexPath.row], iconName: UIConstants.IconName.ChevronRight)
    }
    
    func process(payload: String) -> String {
        parser.parse(payload) ?? ""
    }
}
