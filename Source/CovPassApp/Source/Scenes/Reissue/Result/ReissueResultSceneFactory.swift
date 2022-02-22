import UIKit
import PromiseKit
import CovPassUI
import CovPassCommon

struct ReissueResultSceneFactory: ResolvableSceneFactory {
    
    // MARK: - Properties
    
    let router: ReissueResultRouterProtocol
    let newToken: ExtendedCBORWebToken
    let oldToken: ExtendedCBORWebToken
    
    // MARK: - Lifecycle
    
    init(router: ReissueResultRouterProtocol,
         newToken: ExtendedCBORWebToken,
         oldToken: ExtendedCBORWebToken) {
        self.router = router
        self.newToken = newToken
        self.oldToken = oldToken
    }
    
    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = ReissueResultViewModel(router: router,
                                               resolver: resolvable,
                                               newToken: newToken,
                                               oldToken: oldToken)
        let viewController = ReissueResultViewController(viewModel: viewModel)
        return viewController
    }
}
