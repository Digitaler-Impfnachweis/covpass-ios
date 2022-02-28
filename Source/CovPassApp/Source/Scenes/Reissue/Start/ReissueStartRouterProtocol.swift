import CovPassUI
import CovPassCommon

protocol ReissueStartRouterProtocol: RouterProtocol {
    func showNext(tokens: [ExtendedCBORWebToken])
}
