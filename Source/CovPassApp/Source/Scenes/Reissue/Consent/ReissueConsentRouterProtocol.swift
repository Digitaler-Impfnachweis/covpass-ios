import CovPassUI
import Foundation
import CovPassCommon

protocol ReissueConsentRouterProtocol: RouterProtocol {
    func showNext(newToken: ExtendedCBORWebToken,
                  oldToken: ExtendedCBORWebToken)
    func cancel()
    func routeToPrivacyStatement()
}
