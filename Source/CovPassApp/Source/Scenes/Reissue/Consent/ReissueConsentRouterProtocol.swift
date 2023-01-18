import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit

protocol ReissueConsentRouterProtocol: RouterProtocol {
    func showReissueResultPage(newTokens: [ExtendedCBORWebToken],
                               oldTokens: [ExtendedCBORWebToken],
                               resolver: Resolver<Void>)
    func showGenericResultPage(resolver: Resolver<Void>,
                               certificate: ExtendedCBORWebToken)
    func cancel(resolver: Resolver<Void>)
    func routeToPrivacyStatement()
    func showError(title: String, message: String, faqURL: URL)
    func showURL(_ url: URL)
}
