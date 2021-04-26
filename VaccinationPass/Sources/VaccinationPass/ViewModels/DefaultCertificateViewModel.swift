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
    private let service = VaccinationCertificateService()
    
    public init(parser: T) {
        self.parser = parser
    }
    
    // MARK: - HeadlineViewModel
    
    public var headlineTitle = "vaccination_certificate_list_title".localized
    public var headlineButtonInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 0)
    public var headlineFont: UIFont = UIConstants.Font.subHeadlineFont
    public var headlineButtonImage = UIImage(named: UIConstants.IconName.HelpIcon, in: UIConstants.bundle, compatibleWith: nil)
    
    // MARK: - CertificateViewModel
    
    public weak var delegate: ViewModelDelegate?
    public var certificates = [BaseCertifiateConfiguration]()
    public var addButtonImage = UIImage(named: UIConstants.IconName.PlusIcon, in: UIConstants.bundle, compatibleWith: nil)

    public func process(payload: String, completion: @escaping ((ExtendedVaccinationCertificate?, Error?) -> Void)) {
        guard let decodedPayload = parser.parse(payload, completion: { error in
            completion(nil, error)
        }) else {
            completion(nil, ApplicationError.unknownError)
            return
        }
        do {
            let extendedVaccinationCertificate = ExtendedVaccinationCertificate(vaccinationCertificate: decodedPayload, vaccinationQRCodeData: payload, validationQRCodeData: nil)
            var certificateList = VaccinationCertificateList(certificates: [])
            if let list = try service.fetch() {
                certificateList = list
            }
            if certificateList.certificates.allSatisfy({ $0.vaccinationQRCodeData != payload }) {
                certificateList.certificates.append(extendedVaccinationCertificate)
                try service.save(certificateList)
                certificates = certificateList.certificates.map { getCertficateConfiguration(for: $0.vaccinationCertificate) }
                completion(extendedVaccinationCertificate, nil)
            } else {
                completion(nil, QRCodeError.qrCodeExists)
            }
        } catch {
            completion(nil, error)
        }
        delegate?.shouldReload()
    }

    public func loadCertificatesConfiguration() {
        do {
            guard let certificateList = try service.fetch() else {
                certificates = [noCertificateConfiguration()]
                delegate?.shouldReload()
                return
            }
            if certificateList.certificates.isEmpty {
                certificates = [noCertificateConfiguration()]
                delegate?.shouldReload()
                return
            }
            certificates = certificateList.certificates.map { getCertficateConfiguration(for: $0.vaccinationCertificate) }
            delegate?.shouldReload()
        } catch {
            certificates = [noCertificateConfiguration()]
        }
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

    public func detailViewModel(_ indexPath: IndexPath) -> VaccinationDetailViewModel? {
        do {
            guard let certificateList = try service.fetch() else {
                certificates = [noCertificateConfiguration()]
                return nil
            }
            if certificateList.certificates.isEmpty {
                return nil
            }
            return VaccinationDetailViewModel(certificates: [certificateList.certificates[indexPath.row]])
        } catch {
            print(error)
            return nil
        }
    }
    
    // MARK: - Configurations

    private func getCertficateConfiguration(for certificate: VaccinationCertificate) -> QRCertificateConfiguration {
        certificate.isComplete() ? fullCertificateConfiguration(for: certificate) : halfCertificateConfiguration(for: certificate)
    }

    private func fullCertificateConfiguration(for certificate: VaccinationCertificate) -> QRCertificateConfiguration {
        let image = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
        let stateImage = UIImage(named: UIConstants.IconName.CompletnessImage, in: UIConstants.bundle, compatibleWith: nil)
        let headerImage = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
        let qrViewConfiguration = QrViewConfiguration(tintColor: .white, qrValue: NSUUID().uuidString, qrTitle: nil, qrSubtitle: nil)
        return QRCertificateConfiguration(
            title: "Covid-19 Nachweis",
            subtitle: certificate.name,
            image: image,
            stateImage: stateImage,
            stateTitle: "Impfungen Anzeigen",
            stateAction: nil,
            headerImage: headerImage,
            headerAction: nil,
            backgroundColor: UIConstants.BrandColor.onBackground70,
            qrViewConfiguration: qrViewConfiguration)
    }

    private func halfCertificateConfiguration(for certificate: VaccinationCertificate) -> QRCertificateConfiguration {
        let image = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
        let stateImage = UIImage(named: UIConstants.IconName.HalfShield, in: UIConstants.bundle, compatibleWith: nil)
        let headerImage = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
        let qrViewConfiguration = QrViewConfiguration(tintColor: .black, qrValue: NSUUID().uuidString, qrTitle: "Vorlaüfiger Impfnachweis", qrSubtitle: nil)
        return QRCertificateConfiguration(
            title: "Covid-19 Nachweis",
            subtitle: certificate.name,
            image: image,
            stateImage: stateImage,
            stateTitle: "Impfungen Anzeigen",
            stateAction: nil,
            headerImage: headerImage,
            headerAction: nil,
            backgroundColor: UIConstants.BrandColor.onBackground50,
            qrViewConfiguration: qrViewConfiguration)
    }
    
    private func noCertificateConfiguration() -> NoCertifiateConfiguration {
        let image = UIImage(named: UIConstants.IconName.NoCertificateImage, in: UIConstants.bundle, compatibleWith: nil)
        return NoCertifiateConfiguration(
            title:"vaccination_no_certificate_card_title".localized,
            subtitle: "vaccination_no_certificate_card_message".localized,
            image: image)
    }
}
