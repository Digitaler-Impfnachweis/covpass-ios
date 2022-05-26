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
        static var descriptionBullet1 = "renewal_expiry_consent_list_item_1".localized
        static var descriptionBullet2 = "renewal_expiry_consent_list_item_2".localized
        static var descriptionBullet3 = "renewal_expiry_consent_list_item_3".localized
        static var descriptionBullet4 = "renewal_expiry_consent_list_item_4".localized
        static var privacyHeadline = "certificate_renewal_consent_page_transfer_certificates_headline_privacy_policy".localized
        static var privacyText = "certificate_renewal_consent_page_transfer_certificates_button_link".localized
        static var agree = "certificate_renewal_consent_page_transfer_certificates_confirmation_button".localized
        static var disagree = "certificate_renewal_consent_page_transfer_certificates_cancel_button".localized
        static let errorTitle = "certificate_renewal_error_title".localized
        static let errorMessage = "certificate_renewal_error_copy".localized
    }
    enum Images {
        static var privacyChevron = UIImage.chevronRight
    }
    enum Config {
        static let errorFaqURLEnglish = URL(string: "https://www.digitaler-impfnachweis-app.de/en/faq#fragen-zur-covpass-app")
        static let errorFaqURLGerman = URL(string: "https://www.digitaler-impfnachweis-app.de/faq/#fragen-zur-covpass-app")
        static let defaultErrorID = "R000"
    }
}

class ReissueConsentViewModel: ReissueConsentViewModelProtocol {

    // MARK: - Properties
    weak var delegate: ViewModelDelegate?
    let certItems: [CertificateItem]
    let titleText = Constants.Keys.title
    let subTitleText = Constants.Keys.subTitle
    var descriptionText: NSAttributedString
    let privacyHeadlineText = Constants.Keys.privacyHeadline
    let hintTitle = Constants.Keys.hintTitle
    var hintText: NSAttributedString
    let dataPrivacyText = Constants.Keys.privacyText
    let dataPrivacyChecvron = Constants.Images.privacyChevron
    let buttonAgreeTitle = Constants.Keys.agree
    let buttonDisagreeTitle = Constants.Keys.disagree
    private(set) var isLoading = false
    private let reissueRepository: CertificateReissueRepositoryProtocol
    private let vaccinationRepository: VaccinationRepositoryProtocol
    private let resolver: Resolver<Void>
    private let router: ReissueConsentRouterProtocol
    private let tokens: [ExtendedCBORWebToken]
    private let decoder: JSONDecoder
    private lazy var qrCodeData: [String] = tokens.map(\.vaccinationQRCodeData)
    private let faqURL: URL
    private let context: ReissueContext
    
    // MARK: - Lifecyle
    
    init(router: ReissueConsentRouterProtocol,
         resolver: Resolver<Void>,
         tokens: [ExtendedCBORWebToken],
         reissueRepository: CertificateReissueRepositoryProtocol,
         vaccinationRepository: VaccinationRepositoryProtocol,
         decoder: JSONDecoder,
         locale: Locale,
         context: ReissueContext) {
        self.faqURL = (locale.isGerman() ? Constants.Config.errorFaqURLGerman : Constants.Config.errorFaqURLEnglish)!
        self.tokens = tokens
        self.reissueRepository = reissueRepository
        self.vaccinationRepository = vaccinationRepository
        self.decoder = decoder
        self.router = router
        self.resolver = resolver
        self.certItems = tokens.sortedByDn.compactMap{ $0.certItem(active: true) }
        self.descriptionText = Constants.Keys.description.styledAs(.body)
        self.hintText = Constants.Keys.hintText.styledAs(.body)
            .appendBullets([
                Constants.Keys.hintBulletPoint1.styledAs(.body),
                Constants.Keys.hintBulletPoint2.styledAs(.body),
            ], spacing: 12)
        
        if context == .boosterRenewal {
            self.hintText = hintText.appendBullets([Constants.Keys.hintBulletPoint3.styledAs(.body)])
        } else {
            self.descriptionText = NSAttributedString.toBullets([
                Constants.Keys.descriptionBullet1.styledAs(.body),
                Constants.Keys.descriptionBullet2.styledAs(.body),
                Constants.Keys.descriptionBullet3.styledAs(.body),
                Constants.Keys.descriptionBullet4.styledAs(.body),
            ])
        }
        self.context = context
    }
    
    // MARK: - Methods

    
    func processAgree() {
        showLoadingIndicator()
            .then(reissue())
            .then(save)
            .ensure { [weak self] in
                self?.isLoading = false
            }
            .done { [weak self] tokens in
                self?.handle(tokens: tokens)
            }
            .catch { [weak self] in
                self?.handle(reissueError: $0)
            }
    }

    private func showLoadingIndicator() -> Guarantee<[ExtendedCBORWebToken]> {
        isLoading = true
        delegate?.viewModelDidUpdate()
        return .value(tokens)
    }
    
    private func reissue() -> ([ExtendedCBORWebToken]) -> Promise<CertificateReissueRepositoryResponse> {
        if context == .boosterRenewal {
            return reissueRepository.renew
        } else {
            return reissueRepository.extend
        }
    }
    
    private func save(tokens: [ExtendedCBORWebToken]) -> Promise<[ExtendedCBORWebToken]> {
        vaccinationRepository
            .add(tokens: tokens)
            .map { tokens }
    }
    
    private func handleDoneExtendRenewal() {
        vaccinationRepository.delete(self.tokens.sortedByDn[0])
            .done {
                self.router.showGenericResultPage(resolver: self.resolver)
            }.catch { [weak self] error in
                self?.handle(reissueError: error)
            }
    }
    
    fileprivate func handleDoneBoosterRenewal(_ tokens: [ExtendedCBORWebToken]) {
        router.showReissueResultPage(newTokens: tokens, oldTokens: self.tokens, resolver: resolver)
    }
    
    fileprivate func extractedFunc() {
        delegate?.viewModelDidUpdate()
    }
    
    private func handle(tokens: [ExtendedCBORWebToken]) {
        extractedFunc()
        if context == .boosterRenewal {
            handleDoneBoosterRenewal(tokens)
        } else {
            handleDoneExtendRenewal()
        }
    }

    private func handle(reissueError: Error) {
        let errorID: String
        if let error = reissueError as? CertificateReissueRepositoryError {
            errorID = error.errorID
        } else {
            errorID = Constants.Config.defaultErrorID
        }
        
        delegate?.viewModelUpdateDidFailWithError(reissueError)
        router.showError(
            title: Constants.Keys.errorTitle,
            message: String(format: Constants.Keys.errorMessage, errorID),
            faqURL: faqURL
        )
    }
    
    func processDisagree() {
        router.cancel(resolver: resolver)
    }
    
    func processPrivacyStatement() {
        router.routeToPrivacyStatement()
    }
}
