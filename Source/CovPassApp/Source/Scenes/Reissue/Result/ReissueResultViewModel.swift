import Foundation
import PromiseKit
import CovPassUI
import CovPassCommon

private enum Constants {
    enum Keys {
        static var title = "certificate_renewal_confirmation_page_headline".localized
        static var subTitle = "certificate_renewal_confirmation_page_copy".localized
        static var newCertTitle = "certificate_renewal_confirmation_page_certificate_list_new".localized
        static var oldCertTitle = "certificate_renewal_confirmation_page_certificate_list_old".localized
        static var deleteOldCertTitle = "certificate_renewal_confirmation_page_certificate_delete_button".localized
        static var deleteOldCertLaterTitle = "certificate_renewal_confirmation_page_certificate_secondary_button".localized
    }
}

class ReissueResultViewModel: ReissueResultViewModelProtocol {
        
    // MARK: - Properties
    weak var delegate: ViewModelDelegate?
    let title = Constants.Keys.title
    let subtitle = Constants.Keys.subTitle
    let newCertTitle = Constants.Keys.newCertTitle
    let oldCertTitle = Constants.Keys.oldCertTitle
    let deleteOldCertButtonTitle = Constants.Keys.deleteOldCertTitle
    let deleteOldCertLaterButtonTitle = Constants.Keys.deleteOldCertLaterTitle
    let newCertItem: CertificateItem
    let oldCertItem: CertificateItem
    private let newTokens: [ExtendedCBORWebToken]
    private let oldTokens: [ExtendedCBORWebToken]
    private let resolver: Resolver<Void>
    private let router: ReissueResultRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    
    // MARK: - Lifecyle
    
    init(router: ReissueResultRouterProtocol,
         vaccinationRepository: VaccinationRepositoryProtocol,
         resolver: Resolver<Void>,
         newTokens: [ExtendedCBORWebToken],
         oldTokens: [ExtendedCBORWebToken]) {
        self.router = router
        self.resolver = resolver
        self.newTokens = newTokens
        self.oldTokens = oldTokens
        self.newCertItem = newTokens[0].certItem
        // TODO: old Cert item maybe has to be set gray status background -> has to be checked if final logic has been added
        self.oldCertItem = oldTokens[0].certItem
        self.repository = vaccinationRepository
    }
    
    // MARK: - Methods
    
    func deleteOldTokens() {
        let promises = oldTokens.map(repository.delete(_:))
        when(fulfilled: promises.makeIterator(), concurrently: 1)
            .done { [weak self] _ in
                self?.handleDone()
            }
            .catch { [weak self] error in
                self?.handle(error: error)
            }
    }

    private func handleDone() {
        resolver.fulfill_()
        router.dismiss()
    }

    private func handle(error: Error) {
        router.showError(error, resolver: resolver)
    }

    func deleteOldTokensLater() {
        resolver.fulfill_()
    }
}
