import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct ChooseCheckSituationSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: ChooseCheckSituationRouterProtocol

    // MARK: - Lifecycle

    init(router: ChooseCheckSituationRouterProtocol) {
        self.router = router
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let persistence = UserDefaultsPersistence()
        let viewModel = ChooseCheckSituationViewModel(router: router,
                                                      resolver: resolvable,
                                                      persistence: persistence)
        let viewController = ChooseCheckSituationViewController(viewModel: viewModel)
        return viewController
    }
}
