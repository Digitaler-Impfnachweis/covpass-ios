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
import UIKit

public class CertificateViewModel {
    
    // MARK: - Parser
    
    private let parser: QRCoder = QRCoder()
    
    func process(payload: String, completion: ((Error) -> Void)? = nil) {
        guard let decodedPayload = parser.parse(payload, completion: completion) else { return }
        print(decodedPayload)
        delegate?.shouldReload()
    }
    
    // MARK: - Certificates Continer
    
    weak var delegate: ReloadDelegate?
    var certificates = [ "\(NoCertificateCollectionViewCell.self)",
                         "\(QrCertificateCollectionViewCell.self)",
                         "\(QrCertificateCollectionViewCell.self)"]
    
    func configure<T: CellConfigutation>(cell: T, at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if let actionCell = cell as? NoCertificateCollectionViewCell {
                let image = UIImage(named: UIConstants.IconName.NoCertificateImage, in: UIConstants.bundle, compatibleWith: nil)
                let noCertificateConfig = NoCertifiateConfiguration(
                    title:"Noch keine Impfung hinzugefügt",
                    subtitle: "Scannen Sie den QR-Code auf Ihrer Impfbescheinigung, um hier Ihre Impfung zu sehen",
                    image: image)
                actionCell.configure(with: noCertificateConfig)
            }
        case 1:
           if let actionCell = cell as? QrCertificateCollectionViewCell {
                let image = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
                let stateImage = UIImage(named: UIConstants.IconName.HalfShield, in: UIConstants.bundle, compatibleWith: nil)
                let headerImage = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
                let qrViewConfiguration = QrViewConfiguration(tintColor: .black, qrValue: NSUUID().uuidString, qrTitle: "Vorlaüfiger Impfnachweis", qrSubtitle: "Gultig bis 23.02.2023")
                let noCertificateConfig = QRCertificateConfiguration(
                    title: "Covid-19 Nachweis",
                    subtitle: "Maximilian Mustermann",
                    image: image,
                    stateImage: stateImage,
                    stateTitle: "Impfungen Anzeigen",
                    stateAction: nil,
                    headerImage: headerImage,
                    headerAction: nil,
                    backgroundColor: UIConstants.BrandColor.onBackground50,
                    qrViewConfiguration: qrViewConfiguration)
            actionCell.configure(with: noCertificateConfig)
            }
        case 2:
            if let actionCell = cell as? QrCertificateCollectionViewCell {
                let image = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
                let stateImage = UIImage(named: UIConstants.IconName.CompletnessImage, in: UIConstants.bundle, compatibleWith: nil)
                let headerImage = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
                let qrViewConfiguration = QrViewConfiguration(tintColor: .white, qrValue: NSUUID().uuidString, qrTitle: nil, qrSubtitle: "Gultig bis 23.02.2023")
                let noCertificateConfig = QRCertificateConfiguration(
                    title: "Covid-19 Nachweis",
                    subtitle: "Maximilian Mustermann",
                    image: image,
                    stateImage: stateImage,
                    stateTitle: "Impfungen Anzeigen",
                    stateAction: nil,
                    headerImage: headerImage,
                    headerAction: nil,
                    backgroundColor: UIConstants.BrandColor.onBackground70,
                    qrViewConfiguration: qrViewConfiguration)
                actionCell.configure(with: noCertificateConfig)
            }
        default:
            print("Sorry")
        }
    }
    
    func reuseIdentifier(for indexPath: IndexPath) -> String {
        certificates[indexPath.row]
    }
    
    // MARK: - Action Button 
    
    var addButtonImage: UIImage? = UIImage(named: UIConstants.IconName.PlusIcon, in: UIConstants.bundle, compatibleWith: nil)
    
    // MARK: - Header
    var headerTitle =  "Übersicht aller Impfnachweise"
    var headerButtonInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 0)
    var headerFont: UIFont { UIConstants.Font.subHeadlineFont }
    var headerActionImage = UIImage(named: UIConstants.IconName.HelpIcon, in: UIConstants.bundle, compatibleWith: nil)
}
