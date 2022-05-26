import CovPassUI
import Foundation
import CovPassCommon
import PromiseKit

protocol ReissueConsentRouterProtocol: RouterProtocol {
    func showReissueResultPage(newTokens: [ExtendedCBORWebToken],
                               oldTokens: [ExtendedCBORWebToken],
                               resolver: Resolver<Void>)
    func showGenericResultPage(resolver: Resolver<Void>)
    func cancel(resolver: Resolver<Void>)
    func routeToPrivacyStatement()
    func showError(title: String, message: String, faqURL: URL)
    func showURL(_ url: URL)
}
