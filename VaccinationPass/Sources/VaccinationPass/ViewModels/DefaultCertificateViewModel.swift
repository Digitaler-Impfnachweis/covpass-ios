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

public class DefaultCertificateViewModel: CertificateViewModel {
    // MARK: - Parser

    private let router: CertificateRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    
    public init(
        router: CertificateRouterProtocol,
        repository: VaccinationRepositoryProtocol) {
        self.router = router
        self.repository = repository
    }
    
    // MARK: - HeadlineViewModel
    
    public var headlineTitle = "vaccination_certificate_list_title".localized
    public var headlineButtonImage: UIImage? = .help
    
    // MARK: - CertificateViewModel
    
    public weak var delegate: ViewModelDelegate?
    public var addButtonImage: UIImage? = .plus

    public var certificates = [BaseCertifiateConfiguration]()
    public var certificateList = VaccinationCertificateList(certificates: [])
    public var matchedCertificates: [ExtendedCBORWebToken] {
        let certs = self.sortFavorite(certificateList.certificates, favorite: certificateList.favoriteCertificateId ?? "")
        return self.matchCertificates(certs)
    }

    public func process(payload: String) -> Promise<ExtendedCBORWebToken> {
        return repository.scanVaccinationCertificate(payload).then({ cert in
            return self.repository.getVaccinationCertificateList().map({ list in
                self.certificates = list.certificates.map { self.getCertficateConfiguration(for: $0) }
                return cert
            })
        })
    }

    public func loadCertificatesConfiguration() {
        repository.getVaccinationCertificateList().map({ list -> [ExtendedCBORWebToken] in
            self.certificateList = list
            return self.matchedCertificates
        }).done({ list in
            if list.isEmpty {
                self.certificates = [self.noCertificateConfiguration()]
                return
            }
            self.certificates = list.map { self.getCertficateConfiguration(for: $0) }
        }).catch({ error in
            print(error)
            self.certificates = [self.noCertificateConfiguration()]
        }).finally({
            self.delegate?.viewModelDidUpdate()
        })
    }

    private func sortFavorite(_ certificates: [ExtendedCBORWebToken], favorite: String) -> [ExtendedCBORWebToken] {
        guard let favoriteCert = certificates.first(where: { $0.vaccinationCertificate.hcert.dgc.v.first?.ci == favorite }) else { return certificates }
        var list = [ExtendedCBORWebToken]()
        list.append(favoriteCert)
        list.append(contentsOf: certificates.filter({ $0 != favoriteCert }))
        return list
    }

    private func matchCertificates(_ certificates: [ExtendedCBORWebToken]) -> [ExtendedCBORWebToken] {
        var list = [ExtendedCBORWebToken]()
        var certs: [ExtendedCBORWebToken] = certificates.reversed()
        while certs.count > 0 {
            guard let cert = certs.popLast() else { return list }
            let pair = findCertificatePair(cert, certs)
            certs.removeAll(where: { pair.contains($0) })

            if let fullCert = pair.first(where: { $0.vaccinationCertificate.hcert.dgc.fullImmunization
            }) {
                list.append(fullCert)
            } else if let partialCert = pair.last {
                list.append(partialCert)
            }
        }
        return list
    }

    private func findCertificatePair(_ certificate: ExtendedCBORWebToken, _ certificates: [ExtendedCBORWebToken]) -> [ExtendedCBORWebToken] {
        var list = [certificate]
        for cert in certificates where certificate.vaccinationCertificate.hcert.dgc == cert.vaccinationCertificate.hcert.dgc {
            if !list.contains(cert) {
                list.append(cert)
            }
        }
        return list
    }
    
    // MARK: - Collection View
    
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

    // MARK: - Card Configurations

    private func getCertficateConfiguration(for certificate: ExtendedCBORWebToken) -> QRCertificateConfiguration {
        certificate.vaccinationCertificate.hcert.dgc.fullImmunization ? fullCertificateConfiguration(for: certificate) : halfCertificateConfiguration(for: certificate)
    }

    private func fullCertificateConfiguration(for certificate: ExtendedCBORWebToken) -> QRCertificateConfiguration {
        QRCertificateConfiguration(
            qrValue: certificate.validationQRCodeData ?? NSUUID().uuidString,// neeeded due to no qr data
            title: "Covid-19 Nachweis".localized,
            subtitle: certificate.vaccinationCertificate.hcert.dgc.nam.fullName,
            image: .starEmpty,
            stateImage: .completness,
            stateTitle: "Impfungen Anzeigen".localized,
            headerImage: .starEmpty,
            favoriteAction: favoriteAction,
            backgroundColor: .onBrandAccent70,
            tintColor: UIColor.white)
    }

    private func halfCertificateConfiguration(for certificate: ExtendedCBORWebToken) -> QRCertificateConfiguration {
        QRCertificateConfiguration(
            title: "Covid-19 Nachweis".localized,
            subtitle: certificate.vaccinationCertificate.hcert.dgc.nam.fullName,
            image: .starEmpty,
            stateImage: .halfShield,
            stateTitle: "Impfungen Anzeigen".localized,
            headerImage: .starEmpty,
            favoriteAction: favoriteAction,
            backgroundColor: .onBackground50)

    }
    
    private func noCertificateConfiguration() -> NoCertifiateConfiguration {
        NoCertifiateConfiguration(
            title:"vaccination_no_certificate_card_title".localized,
            subtitle: "vaccination_no_certificate_card_message".localized,
            image: .noCertificate
        )
    }

    private func certificatePair(for indexPath: IndexPath) -> [ExtendedCBORWebToken] {
        if certificateList.certificates.isEmpty {
            return []
        }
        return findCertificatePair(matchedCertificates[indexPath.row], certificateList.certificates)
    }

    private func certificatePair(for certificate: ExtendedCBORWebToken) -> [ExtendedCBORWebToken] {
        if certificateList.certificates.isEmpty {
            return []
        }
        return findCertificatePair(certificate, certificateList.certificates)
    }

    public func showCertificate(at indexPath: IndexPath) {
        showCertificates(
            certificatePair(for: indexPath)
        )
    }

    public func showCertificate(_ certificate: ExtendedCBORWebToken) {
        showCertificates(
            certificatePair(for: certificate)
        )
    }

    private func showCertificates(_ certificates: [ExtendedCBORWebToken]) {
        guard certificates.isEmpty == false else {
            return
        }
        router.showCertificates(certificates)
    }

    public func scanCertificate() {
        firstly {
           router.showProof()
        }
        .then {
           self.router.scanQRCode()
        }
        .map { result in
           try self.payloadFromScannerResult(result)
        }
        .then { payload in
           self.process(payload: payload)
        }
        .ensure {
           self.loadCertificatesConfiguration()
        }
//        .done { certificate in
//            self.showCertificate(at: certificate)
//        }
        .catch { error in
           print(error)
           // TODO error handling
        }
    }

    private func favoriteAction(for configuration: QRCertificateConfiguration) {
        guard let extendedCertificate = certificateList.certificates.filter({ $0.vaccinationCertificate.hcert.dgc.nam.fullName == configuration.subtitle }).first else { return }
        certificateList.favoriteCertificateId = extendedCertificate.vaccinationCertificate.hcert.dgc.v.first?.ci
        firstly {
            repository.saveVaccinationCertificateList(certificateList).asVoid()
        }
        .done {
            self.loadCertificatesConfiguration()
        }.catch{ error in
            print(error)
            // TODO error handling
        }
    }

    private func payloadFromScannerResult(_ result: ScanResult) throws -> String {
        switch result {
        case .success(let payload):
            return payload
        case .failure(let error):
            throw error
        }
    }
}
