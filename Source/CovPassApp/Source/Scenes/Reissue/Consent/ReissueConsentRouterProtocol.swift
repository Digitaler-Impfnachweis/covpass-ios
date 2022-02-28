import CovPassUI
import Foundation
import CovPassCommon
import PromiseKit

protocol ReissueConsentRouterProtocol: RouterProtocol {
    func showNext(newToken: ExtendedCBORWebToken,
                  oldToken: ExtendedCBORWebToken)
    func cancel() -> Promise<Bool>
    func routeToPrivacyStatement()
}
