import CovPassUI
import Foundation
import CovPassCommon
import PromiseKit

protocol ReissueConsentRouterProtocol: RouterProtocol {
    func showNext(newTokens: [ExtendedCBORWebToken],
                  oldTokens: [ExtendedCBORWebToken])
    func cancel() -> Promise<Bool>
    func routeToPrivacyStatement()
}
