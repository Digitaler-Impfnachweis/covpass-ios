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
        static var privacyHeadline = "certificate_renewal_consent_page_transfer_certificates_headline_privacy_policy".localized
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
    let certItems: [CertificateItem]
    let titleText = Constants.Keys.title
    let subTitleText = Constants.Keys.subTitle
    let descriptionText = Constants.Keys.description
    let privacyHeadlineText = Constants.Keys.privacyHeadline
    let hintTitle = Constants.Keys.hintTitle
    let hintText: NSAttributedString
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

    // MARK: - Lifecyle
    
    init(router: ReissueConsentRouterProtocol,
         resolver: Resolver<Void>,
         tokens: [ExtendedCBORWebToken],
         reissueRepository: CertificateReissueRepositoryProtocol,
         vaccinationRepository: VaccinationRepositoryProtocol,
         decoder: JSONDecoder) {
        self.tokens = tokens
        self.reissueRepository = reissueRepository
        self.vaccinationRepository = vaccinationRepository
        self.decoder = decoder
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
        showLoadingIndicator()
            .then(reissueRepository.reissue)
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

    private func save(tokens: [ExtendedCBORWebToken]) -> Promise<[ExtendedCBORWebToken]> {
        vaccinationRepository
            .add(tokens: tokens)
            .map { tokens }
    }

    private func handle(tokens: [ExtendedCBORWebToken]) {
        delegate?.viewModelDidUpdate()
        router.showNext(newTokens: tokens, oldTokens: self.tokens, resolver: resolver)
    }

    private func handle(reissueError: Error) {
        delegate?.viewModelUpdateDidFailWithError(reissueError)
        router.showError(reissueError, resolver: resolver)
    }
    
    func processDisagree() {
        router.cancel(resolver: resolver)
    }
    
    func processPrivacyStatement() {
        router.routeToPrivacyStatement()
    }
}
