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
    var showBadge: Bool { certificateViewModels.contains(where: \.showNotification) }
    var manageCertificatesIcon: UIImage { showBadge ? .manageNotification : .manage }
    var manageCertificatesButtonStyle: MainButtonStyle { .alternativeWhiteTitle }
    var dotPageIndicatorIsHidden: Bool { certificateViewModels.count == 1 }
    var backgroundColor: UIColor { holderNeedsMask ? .onBrandAccent70 : .brandAccent90 }
    private let repository: VaccinationRepositoryProtocol
    private let boosterLogic: BoosterLogicProtocol
    private var certificates: [ExtendedCBORWebToken]
    private var certificatesToShow: [ExtendedCBORWebToken]
    private let resolver: Resolver<CertificateDetailSceneResult>
    private var router: CertificatesOverviewPersonRouterProtocol
    private var selectedCertificateIndex: Int = 0
    private var certificateOwnerName: String { selectedCertificate?.vaccinationCertificate.hcert.dgc.nam.fullName ?? "" }
    private var selectedCertificate: ExtendedCBORWebToken? { selectedCertificateIndex < certificatesToShow.count ? certificatesToShow[selectedCertificateIndex] : nil }
    private let certificateHolderStatusModel: CertificateHolderStatusModelProtocol
    private var certificate: CBORWebToken { token.vaccinationCertificate }
    private var token: ExtendedCBORWebToken {
        guard let latestCertificate = certificates.sortLatest().first else {
            fatalError("This scene withouth any certificate makes no sense")
        }
        return latestCertificate
    }

    private var holderNeedsMask: Bool
    private var persistence: Persistence

    // MARK: - Lifecycle

    init(router: CertificatesOverviewPersonRouterProtocol,
         persistence: Persistence,
         repository: VaccinationRepositoryProtocol,
         boosterLogic: BoosterLogicProtocol,
         certificateHolderStatusModel: CertificateHolderStatusModelProtocol,
         certificates: [ExtendedCBORWebToken],
         resolver: Resolver<CertificateDetailSceneResult>) {
        if certificates.isEmpty {
            fatalError("This scene makes no scence if certificates is empty, sould be covered by caller")
        }
        self.router = router
        self.persistence = persistence
        self.repository = repository
        self.boosterLogic = boosterLogic
        self.certificateHolderStatusModel = certificateHolderStatusModel
        self.certificates = certificates
        holderNeedsMask = certificateHolderStatusModel.holderNeedsMask(certificates, region: persistence.stateSelection)
        certificatesToShow = certificates.filterFirstOfAllTypes
        self.resolver = resolver
        pageSubtitle = String(format: Constants.Keys.modalSubline, certificatesToShow.count)
    }

    // MARK: - Methods

    private func cardViewModels(for _: [ExtendedCBORWebToken]) -> [CardViewModel] {
        certificatesToShow.map { cert in
            CertificateCardViewModel(token: cert,
                                     holderNeedsMask: holderNeedsMask,
                                     onAction: showCertificate,
                                     repository: repository,
                                     boosterLogic: boosterLogic)
        }
    }

    private func showCertificate(_: ExtendedCBORWebToken) {
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
            refresh()
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
        certificatesToShow = certificates.filterFirstOfAllTypes
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
