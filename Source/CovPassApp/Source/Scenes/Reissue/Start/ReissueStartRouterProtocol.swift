import CovPassUI
import CovPassCommon

protocol ReissueStartRouterProtocol: RouterProtocol {
    func showNext(token: ExtendedCBORWebToken)
    func cancel()
}
