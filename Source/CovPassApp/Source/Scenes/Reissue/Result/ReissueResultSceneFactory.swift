import UIKit
import PromiseKit
import CovPassUI
import CovPassCommon

struct ReissueResultSceneFactory: ResolvableSceneFactory {
    
    // MARK: - Properties
    
    let router: ReissueResultRouterProtocol
    let newTokens: [ExtendedCBORWebToken]
    let oldTokens: [ExtendedCBORWebToken]
    
    // MARK: - Lifecycle
    
    init(router: ReissueResultRouterProtocol,
         newTokens: [ExtendedCBORWebToken],
         oldTokens: [ExtendedCBORWebToken]) {
        self.router = router
        self.newTokens = newTokens
        self.oldTokens = oldTokens
    }
    
    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = ReissueResultViewModel(router: router,
                                               resolver: resolvable,
                                               newTokens: newTokens,
                                               oldTokens: oldTokens)
        let viewController = ReissueResultViewController(viewModel: viewModel)
        return viewController
    }
}
