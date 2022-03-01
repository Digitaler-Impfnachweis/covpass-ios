import CovPassUI
import CovPassCommon
import PromiseKit

protocol ReissueStartRouterProtocol: RouterProtocol {
    func showNext(tokens: [ExtendedCBORWebToken], resolver: Resolver<Void>)
}
