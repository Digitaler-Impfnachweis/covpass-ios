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
import PromiseKit

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
    
    public weak var delegate: CertificateViewModelDelegate?
    public var addButtonImage = UIImage(named: UIConstants.IconName.PlusIcon, in: UIConstants.bundle, compatibleWith: nil)

    public var certificates = [BaseCertifiateConfiguration]()
    public var certificateList = VaccinationCertificateList(certificates: [])
    public var matchedCertificates: [ExtendedVaccinationCertificate] {
        let certs = self.sortFavorite(certificateList.certificates, favorite: certificateList.favoriteCertificateId ?? "")
        return self.matchCertificates(certs)
    }

    public func process(payload: String) -> Promise<ExtendedVaccinationCertificate> {
        return Promise<ExtendedVaccinationCertificate>() { seal in
            // TODO refactor parser
            guard let decodedPayload = parser.parseVaccinationCertificate(payload, completion: { error in
                seal.reject(error)
            }) else {
                seal.reject(ApplicationError.unknownError)
                return
            }
            seal.fulfill(ExtendedVaccinationCertificate(vaccinationCertificate: decodedPayload, vaccinationQRCodeData: payload, validationQRCodeData: nil))
        }.then({ extendedVaccinationCertificate in
            return self.service.fetch().then({ list -> Promise<Void> in
                var certList = list
                if certList.certificates.contains(where: { $0.vaccinationQRCodeData == payload }) {
                    throw QRCodeError.qrCodeExists
                }
                certList.certificates.append(extendedVaccinationCertificate)

                // Mark first certificate as favorite
                if certList.certificates.count == 1 {
                    certList.favoriteCertificateId = extendedVaccinationCertificate.vaccinationCertificate.id
                }

                return self.service.save(certList)
            }).then(self.service.fetch).then({ list -> Promise<ExtendedVaccinationCertificate> in
                self.certificates = list.certificates.map { self.getCertficateConfiguration(for: $0.vaccinationCertificate) }
                return Promise.value(extendedVaccinationCertificate)
            })
        })
    }

    public func loadCertificatesConfiguration() {
        service.fetch().map({ list -> [ExtendedVaccinationCertificate] in
            self.certificateList = list
            return self.matchedCertificates
        }).done({ list in
            if list.isEmpty {
                self.certificates = [self.noCertificateConfiguration()]
                return
            }
            self.certificates = list.map { self.getCertficateConfiguration(for: $0.vaccinationCertificate) }
        }).catch({ error in
            print(error)
            self.certificates = [self.noCertificateConfiguration()]
        }).finally({
            self.delegate?.shouldReload()
        })
    }

    private func sortFavorite(_ certificates: [ExtendedVaccinationCertificate], favorite: String) -> [ExtendedVaccinationCertificate] {
        guard let favoriteCert = certificates.first(where: { $0.vaccinationCertificate.id == favorite }) else { return certificates }
        var list = [ExtendedVaccinationCertificate]()
        list.append(favoriteCert)
        list.append(contentsOf: certificates.filter({ $0 != favoriteCert }))
        return list
    }

    private func matchCertificates(_ certificates: [ExtendedVaccinationCertificate]) -> [ExtendedVaccinationCertificate] {
        var list = [ExtendedVaccinationCertificate]()
        var certs: [ExtendedVaccinationCertificate] = certificates.reversed()
        while certs.count > 0 {
            guard let cert = certs.popLast() else { return list }
            let pair = findCertificatePair(cert, certs)
            certs.removeAll(where: { pair.contains($0) })

            if let fullCert = pair.first(where: { !$0.vaccinationCertificate.partialVaccination }) {
                list.append(fullCert)
            } else if let partialCert = pair.last {
                list.append(partialCert)
            }
        }
        return list
    }

    private func findCertificatePair(_ certificate: ExtendedVaccinationCertificate, _ certificates: [ExtendedVaccinationCertificate]) -> [ExtendedVaccinationCertificate] {
        var list = [certificate]
        for cert in certificates where certificate.vaccinationCertificate == cert.vaccinationCertificate {
            if !list.contains(cert) {
                list.append(cert)
            }
        }
        return list
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
        if matchedCertificates.isEmpty {
            return nil
        }
        let pair = findCertificatePair(matchedCertificates[indexPath.row], certificateList.certificates)
        return VaccinationDetailViewModel(certificates: pair)
    }

    public func detailViewModel(_ cert: ExtendedVaccinationCertificate) -> VaccinationDetailViewModel? {
        if certificateList.certificates.isEmpty {
            return nil
        }
        let pair = findCertificatePair(cert, certificateList.certificates)
        return VaccinationDetailViewModel(certificates: pair)
    }
    
    // MARK: - Configurations

    private func getCertficateConfiguration(for certificate: VaccinationCertificate) -> QRCertificateConfiguration {
        certificate.partialVaccination ? halfCertificateConfiguration(for: certificate) : fullCertificateConfiguration(for: certificate)
    }

    private func fullCertificateConfiguration(for certificate: VaccinationCertificate) -> QRCertificateConfiguration {
        let image = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
        let stateImage = UIImage(named: UIConstants.IconName.CompletnessImage, in: UIConstants.bundle, compatibleWith: nil)
        let headerImage = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
        return QRCertificateConfiguration(
            certificate: certificate,
            image: image,
            stateImage: stateImage,
            detailsAction: detailsAction,
            headerImage: headerImage,
            favoriteAction: favoriteAction,
            backgroundColor: UIConstants.BrandColor.onBackground70,
            tintColor: UIColor.white)
    }

    private func halfCertificateConfiguration(for certificate: VaccinationCertificate) -> QRCertificateConfiguration {
        let image = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
        let stateImage = UIImage(named: UIConstants.IconName.HalfShield, in: UIConstants.bundle, compatibleWith: nil)
        let headerImage = UIImage(named: UIConstants.IconName.StarEmpty, in: UIConstants.bundle, compatibleWith: nil)
        return QRCertificateConfiguration(
            certificate: certificate,
            image: image,
            stateImage: stateImage,
            detailsAction: detailsAction,
            headerImage: headerImage,
            favoriteAction: favoriteAction,
            backgroundColor: UIConstants.BrandColor.onBackground50)
    }
    
    private func noCertificateConfiguration() -> NoCertifiateConfiguration {
        let image = UIImage(named: UIConstants.IconName.NoCertificateImage, in: UIConstants.bundle, compatibleWith: nil)
        return NoCertifiateConfiguration(
            title:"vaccination_no_certificate_card_title".localized,
            subtitle: "vaccination_no_certificate_card_message".localized,
            image: image)
    }
    
    
    private func favoriteAction(certificate: VaccinationCertificate) {
        // Mark as favorite
        
    }
    
    private func detailsAction(configuration: QRCertificateConfiguration) {
        guard let index = certificates.firstIndex(of: configuration) else { return }
        delegate?.detailsButtonTapped(for: IndexPath(item: index, section: 0))
    }
}
