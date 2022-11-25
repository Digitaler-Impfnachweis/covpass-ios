import CovPassCommon
import CovPassUI
import PromiseKit

protocol ReissueStartRouterProtocol: RouterProtocol {
    func showNext(tokens: [ExtendedCBORWebToken],
                  resolver: Resolver<Void>,
                  context: ReissueContext)
}
