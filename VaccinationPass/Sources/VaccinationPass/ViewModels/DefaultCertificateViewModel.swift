//
//  DefaultCertificateViewModel.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationUI
import VaccinationCommon

public class DefaultCertificateViewModel<T: QRCoderProtocol>: CertificateViewModel {
    // MARK: - Parser
    
    private let parser: T
    
    public init(parser: T) {
        self.parser = parser
    }
    
    // MARK: - HeadlineViewModel
    
    public var headlineTitle =  "vaccination_certificate_list_title".localized
    public var headlineButtonInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 0)
    public var headlineFont: UIFont = UIConstants.Font.subHeadlineFont
    public var headlineButtonImage = UIImage(named: UIConstants.IconName.HelpIcon, in: UIConstants.bundle, compatibleWith: nil)
    
    // MARK: - CertificateViewModel
    
    public weak var delegate: ViewModelDelegate?
    public var certificates: [BaseCertifiateConfiguration] = [
        noCertificateConfiguration(),
        mockHalfCertificateConfiguration(),
        mockFullCertificateConfiguration()
    ]
    public var addButtonImage = UIImage(named: UIConstants.IconName.PlusIcon, in: UIConstants.bundle, compatibleWith: nil)
    
    public func process(payload: String, completion: ((Error) -> Void)? = nil) {
        guard let decodedPayload = parser.parse(payload, completion: completion) else { return }
        delegate?.shouldReload()
    }
    
    public func configure<T: CellConfigutation>(cell: T, at indexPath: IndexPath)  {
        guard certificates.indices.contains(indexPath.row) else { return }
        let configuration = certificates[indexPath.row]
        if let noCertificateCell = cell as? NoCertificateCollectionViewCell, let noCertificateConfig = configuration as? NoCertifiateConfiguration {
            noCertificateCell.configure(with: noCertificateConfig)
        } else if let qrCertificateCell = cell as? QrCertificateCollectionViewCell, let qrCertificateConfig = configuration as? QRCertificateConfiguration {
            qrCertificateCell.configure(with: qrCertificateConfig)
        }
    }
    
    public func reuseIdentifier(for indexPath: IndexPath) -> String {
        guard certificates.indices.contains(indexPath.row) else {
            return "\(NoCertificateCollectionViewCell.self)"}
        return certificates[indexPath.row].identifier
    }
    
    // MARK: - Configurations
    
    private static func mockFullCertificateConfiguration() -> QRCertificateConfiguration {
        let image = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
        let stateImage = UIImage(named: UIConstants.IconName.CompletnessImage, in: UIConstants.bundle, compatibleWith: nil)
        let headerImage = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
        let qrViewConfiguration = QrViewConfiguration(tintColor: .white, qrValue: NSUUID().uuidString, qrTitle: nil, qrSubtitle: "Gultig bis 23.02.2023")
        return QRCertificateConfiguration(
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
    }

    private static func mockHalfCertificateConfiguration() -> QRCertificateConfiguration {
        let image = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
        let stateImage = UIImage(named: UIConstants.IconName.HalfShield, in: UIConstants.bundle, compatibleWith: nil)
        let headerImage = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
        let qrViewConfiguration = QrViewConfiguration(tintColor: .black, qrValue: NSUUID().uuidString, qrTitle: "Vorlaüfiger Impfnachweis", qrSubtitle: "Gultig bis 23.02.2023")
        return QRCertificateConfiguration(
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
    }
    
    private static func noCertificateConfiguration() -> NoCertifiateConfiguration {
        let image = UIImage(named: UIConstants.IconName.NoCertificateImage, in: UIConstants.bundle, compatibleWith: nil)
        return NoCertifiateConfiguration(
            title:"vaccination_no_certificate_card_title".localized,
            subtitle: "vaccination_no_certificate_card_message".localized,
            image: image)
    }
}
