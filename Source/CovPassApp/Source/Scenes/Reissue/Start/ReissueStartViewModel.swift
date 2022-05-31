import Foundation
import PromiseKit
import CovPassUI
import CovPassCommon

private enum Constants {
    enum Keys {
        enum boosterRenewal {
            static var title = "certificate_renewal_startpage_headline".localized
            static var description = "certificate_renewal_startpage_copy".localized
            static var hint = "certificate_renewal_startpage_copy_box".localized
            static var start = "certificate_renewal_startpage_main_button".localized
            static var later = "certificate_renewal_startpage_secondary_button".localized
        }
        enum ExpiryRenewal {
            static var title = "renewal_expiry_notification_title".localized
            static var description = "renewal_expiry_notification_copy_vaccination".localized
            static var hint = "certificate_renewal_startpage_copy_box".localized
            static var start_vaccination = "renewal_expiry_notification_button_vaccination".localized
            static var start_recovery = "renewal_expiry_notification_button_recovery".localized
            static var later = "certificate_renewal_startpage_secondary_button".localized
        }
    }
}

class ReissueStartViewModel: ReissueStartViewModelProtocol {
    
    // MARK: - Properties
    weak var delegate: ViewModelDelegate?
    let certItem: CertificateItem
    lazy var titleText = context == .boosterRenewal ? Constants.Keys.boosterRenewal.title : Constants.Keys.ExpiryRenewal.title
    lazy var descriptionText = context == .boosterRenewal ? Constants.Keys.boosterRenewal.description : Constants.Keys.ExpiryRenewal.description
    lazy var hintText = context == .boosterRenewal ? Constants.Keys.boosterRenewal.hint : Constants.Keys.ExpiryRenewal.hint
    lazy var buttonStartTitle = context == .boosterRenewal ? Constants.Keys.boosterRenewal.start : tokens.first?.firstVaccination != nil ? Constants.Keys.ExpiryRenewal.start_vaccination : Constants.Keys.ExpiryRenewal.start_recovery
    lazy var buttonLaterTitle = context == .boosterRenewal ? Constants.Keys.boosterRenewal.later : Constants.Keys.ExpiryRenewal.later
    private let resolver: Resolver<Void>
    private let router: ReissueStartRouterProtocol
    private let tokens: [ExtendedCBORWebToken]
    private let context: ReissueContext
    
    // MARK: - Lifecyle
    
    init(router: ReissueStartRouterProtocol,
         resolver: Resolver<Void>,
         tokens: [ExtendedCBORWebToken],
         context: ReissueContext) {
        self.context = context
        self.router = router
        self.resolver = resolver
        self.tokens = tokens
        let reissuableTokens: [ExtendedCBORWebToken]
        switch context {
        case .boosterRenewal:
            reissuableTokens = tokens.sortedByDn
        case .certificateExtension:
            reissuableTokens = tokens
        }
        certItem = reissuableTokens[0].certItem(active: true)
    }
    
    // MARK: - Methods
    
    func processStart() {
        router.showNext(tokens: tokens, resolver: resolver, context: context)
    }
    
    func processLater() {
        resolver.fulfill_()
    }
}
