//
//  CertificatesOverviewPersonViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

private enum Constants {
    enum Keys {
        static let modalButtonTitle = "modal_button".localized
        static let modalSubline = "modal_subline".localized
    }
}

class CertificatesOverviewPersonViewModel: CertificatesOverviewPersonViewModelProtocol {
    
    
    // MARK: - Properties
    
    weak var delegate: CertificatesOverviewPersonViewModelDelegate?
    var pageTitle: String { certificateOwnerName }
    var pageSubtitle: String
    var modalButtonTitle: String = Constants.Keys.modalButtonTitle
    var certificateViewModels: [CardViewModel] { cardViewModels(for: certificates) }
    var showBadge: Bool { certificateViewModels.contains(where:\.showBoosterAvailabilityNotification) }
    var manageCertificatesIcon: UIImage { showBadge ? .manageNotification : .manage }
    var dotPageIndicatorIsHidden: Bool { certificateViewModels.count == 1 }
    private let repository: VaccinationRepositoryProtocol
    private let boosterLogic: BoosterLogicProtocol
    private var certificates: [ExtendedCBORWebToken]
    private var certificatesToShow: [ExtendedCBORWebToken]
    private let resolver: Resolver<CertificateDetailSceneResult>
    private var router: CertificatesOverviewPersonRouterProtocol
    private var selectedCertificateIndex: Int = 0
    private var certificateOwnerName: String { selectedCertificate.vaccinationCertificate.hcert.dgc.nam.fullName }
    private var selectedCertificate: ExtendedCBORWebToken { certificatesToShow[selectedCertificateIndex] }
    
    // MARK: - Lifecycle
    
    init(router: CertificatesOverviewPersonRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         boosterLogic: BoosterLogicProtocol,
         certificates: [ExtendedCBORWebToken],
         resolver: Resolver<CertificateDetailSceneResult>) {
        if certificates.isEmpty {
            fatalError("This scene makes no scence if certificates is empty, sould be covered by caller")
        }
        self.router = router
        self.repository = repository
        self.boosterLogic = boosterLogic
        self.certificates = certificates
        self.certificatesToShow = certificates.filterFirstOfAllTypes
        self.resolver = resolver
        self.pageSubtitle = String(format: Constants.Keys.modalSubline, certificatesToShow.count)
    }
    
    // MARK: - Methods
    
    private func cardViewModels(for certificates: [ExtendedCBORWebToken]) -> [CardViewModel] {
        certificatesToShow.map { cert in
            CertificateCardViewModel(token: cert,
                                     vaccinations: certificates.vaccinations,
                                     recoveries: certificates.recoveries,
                                     isFavorite: false,
                                     showFavorite: false,
                                     showTitle: false,
                                     showAction: false,
                                     showNotificationIcon: false,
                                     onAction: showCertificate,
                                     onFavorite: { _ in },
                                     repository: repository,
                                     boosterLogic: boosterLogic)
        }
    }
    
    private func showCertificate(_ certificate: ExtendedCBORWebToken) {
        showCertificates()
    }
    
    private func showCertificates() {
        firstly {
            router.showCertificatesDetail(certificates: certificates)
        }
        .cancelled { [self] in
            // User cancelled by back button or swipe gesture.
            // So refresh everything because we don't know what exactly changed here.
            resolver.cancel()
        }
        .done {
            self.handleCertificateDetailSceneResult($0)
        }
        .catch { [weak self] error in
            self?.router.showUnexpectedErrorDialog(error)
        }
    }
    
    private func handleCertificateDetailSceneResult(_ result: CertificateDetailSceneResult) {
        switch result {
        case .didDeleteCertificate:
            resolver.fulfill(.didDeleteCertificate)
        case let .showCertificatesOnOverview(certificate):
            self.refresh()
            delegate?.viewModelDidUpdate()
            let indexOfCertType = certificatesToShow.indexOfSameCertType(cert: certificate)
            delegate?.viewModelNeedsCertificateVisible(at: indexOfCertType)
        case .addNewCertificate:
            resolver.fulfill(.addNewCertificate)
        }
    }
    
    private func refresh() {
        firstly {
            repository.getCertificateList()
        }
        .get {
            if let someCertificateOfThisPerson = self.certificates.first {
                let certificates = $0.certificates.filterMatching(someCertificateOfThisPerson)
                self.setCertificates(certificates)
            }
        }
        .done { _ in
            self.delegate?.viewModelDidUpdate()
        }
        .cauterize()
    }
    
    private func setCertificates(_ certificates: [ExtendedCBORWebToken]) {
        self.certificates = certificates
        self.certificatesToShow = certificates.filterFirstOfAllTypes
    }
    
    func showDetails() {
        showCertificates()
    }
    
    func close() {
        resolver.cancel()
    }
}

private extension Array where Element == ExtendedCBORWebToken {
    func indexOfSameCertType(cert: ExtendedCBORWebToken) -> Int {
        firstIndex { token in
            token.vaccinationCertificate.certType == cert.vaccinationCertificate.certType
        } ?? 0
    }
}
