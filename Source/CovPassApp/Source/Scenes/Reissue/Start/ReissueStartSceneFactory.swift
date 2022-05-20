import UIKit
import PromiseKit
import CovPassUI
import CovPassCommon

enum ReissueContext {
    case boosterRenewal, certificateExtension
}

struct ReissueStartSceneFactory: ResolvableSceneFactory {
    
    // MARK: - Properties
    private let router: ReissueStartRouterProtocol
    private let tokens: [ExtendedCBORWebToken]
    private let context: ReissueContext
    
    // MARK: - Lifecycle
    
    init(router: ReissueStartRouterProtocol,
         tokens: [ExtendedCBORWebToken],
         context: ReissueContext) {
        self.router = router
        self.tokens = tokens
        self.context = context
    }
    
    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = ReissueStartViewModel(router: router,
                                              resolver: resolvable,
                                              tokens: tokens,
                                              context: context)
        let viewController = ReissueStartViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
