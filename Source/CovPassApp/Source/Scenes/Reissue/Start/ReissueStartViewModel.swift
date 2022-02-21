import Foundation
import PromiseKit
import CovPassUI
import CovPassCommon

private enum Constants {
    enum Keys {
        static var title = "certificate_renewal_startpage_headline".localized
        static var description = "certificate_renewal_startpage_copy".localized
        static var hint = "certificate_renewal_startpage_copy_box".localized
        static var start = "certificate_renewal_startpage_main_button".localized
        static var later = "certificate_renewal_startpage_secondary_button".localized
    }
}

class ReissueStartViewModel: ReissueStartViewModelProtocol {
    
    // MARK: - Properties
    weak var delegate: ViewModelDelegate?
    let token: ExtendedCBORWebToken
    let certItem: CertificateItem
    let titleText = Constants.Keys.title
    let descriptionText = Constants.Keys.description
    let hintText = Constants.Keys.hint
    let buttonStartTitle = Constants.Keys.start
    let buttonLaterTitle = Constants.Keys.later
    private let resolver: Resolver<Void>
    private let router: ReissueStartRouterProtocol
    
    // MARK: - Lifecyle
    
    init(router: ReissueStartRouterProtocol,
         resolver: Resolver<Void>,
         token: ExtendedCBORWebToken) {
        self.router = router
        self.resolver = resolver
        self.token = token
        self.certItem = token.certItem
    }
    
    // MARK: - Methods
    
    func processStart() {
        router.showNext(token: token)
    }
    
    func processLater() {
        router.cancel()
    }
}