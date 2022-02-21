import Foundation
import PromiseKit
import CovPassUI
import CovPassCommon
import UIKit

private enum Constants {
    enum Keys {
        static var title = "certificate_renewal_consent_page_transfer_certificates_headline".localized
        static var subTitle = "certificate_renewal_consent_page_transfer_certificates_subline".localized
        static var hintTitle = "certificate_renewal_consent_page_transfer_certificates_consent_box_subline".localized
        static var hintText = "certificate_renewal_consent_page_transfer_certificates_consent_box_copy".localized
        static var hintBulletPoint1 = "certificate_renewal_consent_page_transfer_certificates_consent_box_copy_list_item_1".localized
        static var hintBulletPoint2 = "certificate_renewal_consent_page_transfer_certificates_consent_box_copy_list_item_2".localized
        static var hintBulletPoint3 = "certificate_renewal_consent_page_transfer_certificates_consent_box_copy_list_item_3".localized
        static var description = "certificate_renewal_consent_page_transfer_certificates_copy".localized
        static var privacyText = "certificate_renewal_consent_page_transfer_certificates_button_link".localized
        static var agree = "certificate_renewal_consent_page_transfer_certificates_confirmation_button".localized
        static var disagree = "certificate_renewal_consent_page_transfer_certificates_cancel_button".localized
    }
    enum Images {
        static var privacyChevron = UIImage.chevronRight
    }
}

class ReissueConsentViewModel: ReissueConsentViewModelProtocol {

    // MARK: - Properties
    weak var delegate: ViewModelDelegate?
    let tokens: [ExtendedCBORWebToken]
    let certItems: [CertificateItem]
    let titleText = Constants.Keys.title
    let subTitleText = Constants.Keys.subTitle
    let descriptionText = Constants.Keys.description
    let hintTitle = Constants.Keys.hintTitle
    let hintText: NSAttributedString
    let dataPrivacyText = Constants.Keys.privacyText
    let dataPrivacyChecvron = Constants.Images.privacyChevron
    let buttonAgreeTitle = Constants.Keys.agree
    let buttonDisagreeTitle = Constants.Keys.disagree
    private let resolver: Resolver<Void>
    private let router: ReissueConsentRouterProtocol
    
    // MARK: - Lifecyle
    
    init(router: ReissueConsentRouterProtocol,
         resolver: Resolver<Void>,
         token: ExtendedCBORWebToken) {
        // TODO: in invissions tokens are an array of tokens, the page before shows only one, seems like here has to be loaded other certificates from the keychain?
        self.tokens = [token]
        self.router = router
        self.resolver = resolver
        self.certItems = tokens.compactMap{ $0.certItem }
        self.hintText = Constants.Keys.hintText.styledAs(.body)
            .appendBullets([
                Constants.Keys.hintBulletPoint1.styledAs(.body),
                Constants.Keys.hintBulletPoint2.styledAs(.body),
                Constants.Keys.hintBulletPoint3.styledAs(.body),
            ], spacing: 12)
    }
    
    // MARK: - Methods
    
    func processAgree() {
        // TODO: tokens has to be replaced. newToken and oldToken parameters here are only for demo purposes. After call is integrated, new Token will be that new reissued one.
        router.showNext(newToken: tokens.first!, oldToken: tokens.first!)
    }
    
    func processDisagree() {
        router.cancel()
    }
    
    func processPrivacyStatement() {
        router.routeToPrivacyStatement()
    }
}
