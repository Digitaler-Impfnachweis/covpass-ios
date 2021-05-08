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

    // MARK: - Private Properties

    private let router: CertificateRouterProtocol
    private let repository: VaccinationRepositoryProtocol

    // MARK: - Lifecycle
    
    public init(
        router: CertificateRouterProtocol,
        repository: VaccinationRepositoryProtocol) {
        self.router = router
        self.repository = repository
    }
    
    // MARK: - Public Properties
    
    public weak var delegate: CertificateViewModelDelegate?
    public var certificateViewModels = [CardViewModel]()
    public var certificateList = VaccinationCertificateList(certificates: [])
    public var matchedCertificates: [ExtendedCBORWebToken] {
        let certs = self.sortFavorite(certificateList.certificates, favorite: certificateList.favoriteCertificateId ?? "")
        return self.matchCertificates(certs)
    }

    // MARK: - Public Actions

    public func process(payload: String) -> Promise<ExtendedCBORWebToken> {
        return repository.scanVaccinationCertificate(payload)
    }

    public func loadCertificates() {
        firstly {
            repository.getVaccinationCertificateList()
        }
        .map { list -> [ExtendedCBORWebToken] in
            self.certificateList = list
            return self.matchedCertificates
        }
        .done { list in
            if list.isEmpty {
                self.certificateViewModels = [NoCertificateCardViewModel()]
                return
            }
            self.certificateViewModels = list.map { cert in
                let isFavorite = self.certificatePair(for: cert).contains(where: { $0.vaccinationCertificate.hcert.dgc.v.first?.ci == self.certificateList.favoriteCertificateId })
                return CertificateCardViewModel(token: cert, isFavorite: isFavorite, onAction: self.onAction, onFavorite: self.onFavorite)
            }
        }
        .catch { error in
            self.certificateViewModels = [NoCertificateCardViewModel()]
        }
        .finally {
            self.delegate?.viewModelDidUpdate()
        }
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
           self.loadCertificates()
        }
        .done { certificate in
            self.showCertificate(certificate)
        }
        .catch { error in
            self.delegate?.viewModelUpdateDidFailWithError(error)
        }
    }

    public func showAppInformation() {
        router.showAppInformation()
    }

    public func showErrorDialog() {
        router.showErrorDialog()
    }

    // MARK: - Private Functions

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

    private func payloadFromScannerResult(_ result: ScanResult) throws -> String {
        switch result {
        case .success(let payload):
            return payload
        case .failure(let error):
            throw error
        }
    }

    private func onFavorite(_ id: String) {
        certificateList.favoriteCertificateId = certificateList.favoriteCertificateId == id ? nil : id
        firstly {
            repository.saveVaccinationCertificateList(certificateList).asVoid()
        }
        .done {
            self.delegate?.viewModelDidUpdateFavorite()
        }
        .catch{ error in
            self.delegate?.viewModelUpdateDidFailWithError(error)
        }
    }

    private func onAction(_ certificate: ExtendedCBORWebToken) {
        self.showCertificate(certificate)
    }

    private func showCertificates(_ certificates: [ExtendedCBORWebToken]) {
        guard certificates.isEmpty == false else {
            return
        }
        router.showCertificates(certificates)
    }
}
