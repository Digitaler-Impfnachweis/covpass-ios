import CovPassUI
import Foundation
import CovPassCommon
import PromiseKit

protocol ReissueConsentRouterProtocol: RouterProtocol {
    func showNext(newTokens: [ExtendedCBORWebToken],
                  oldTokens: [ExtendedCBORWebToken],
                  resolver: Resolver<Void>)
    func cancel(resolver: Resolver<Void>)
    func routeToPrivacyStatement()
    func showError(_ error: Error, resolver: Resolver<Void>)
}
