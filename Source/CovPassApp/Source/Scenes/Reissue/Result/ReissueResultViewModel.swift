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
    let newToken: ExtendedCBORWebToken
    let newCertItem: CertificateItem
    let oldToken: ExtendedCBORWebToken
    let oldCertItem: CertificateItem
    private let resolver: Resolver<Void>
    private let router: ReissueResultRouterProtocol
    
    // MARK: - Lifecyle
    
    init(router: ReissueResultRouterProtocol,
         resolver: Resolver<Void>,
         newToken: ExtendedCBORWebToken,
         oldToken: ExtendedCBORWebToken) {
        self.router = router
        self.resolver = resolver
        self.newToken = newToken
        self.oldToken = oldToken
        self.newCertItem = newToken.certItem
        // TODO: old Cert item maybe has to be set gray status background -> has to be checked if final logic has been added
        self.oldCertItem = oldToken.certItem
    }
    
    // MARK: - Methods
    
    func deleteOldToken() {
        // TODO: delete old token
        router.sceneCoordinator.dimiss(animated: true)
    }
    
    func deleteOldTokenLater() {
        // TODO: delete old token later
        router.sceneCoordinator.dimiss(animated: true)
    }
}
