import UIKit
import PromiseKit
import CovPassUI
import CovPassCommon

struct ReissueResultSceneFactory: SceneFactory {
    
    // MARK: - Properties
    
    private let router: ReissueResultRouterProtocol
    private let newTokens: [ExtendedCBORWebToken]
    private let oldTokens: [ExtendedCBORWebToken]
    private let resolver: Resolver<Void>

    // MARK: - Lifecycle
    
    init(router: ReissueResultRouterProtocol,
         newTokens: [ExtendedCBORWebToken],
         oldTokens: [ExtendedCBORWebToken],
         resolver: Resolver<Void>) {
        self.router = router
        self.newTokens = newTokens
        self.oldTokens = oldTokens
        self.resolver = resolver
    }
    
    func make() -> UIViewController {
        let repository = VaccinationRepository.create()
        let viewModel = ReissueResultViewModel(router: router,
                                               vaccinationRepository: repository,
                                               resolver: resolver,
                                               newTokens: newTokens,
                                               oldTokens: oldTokens)
        let viewController = ReissueResultViewController(viewModel: viewModel)
        return viewController
    }
}
