import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit

class ReissueStartRouter: ReissueStartRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showNext(tokens: [ExtendedCBORWebToken],
                  resolver: Resolver<Void>,
                  context: ReissueContext) {
        sceneCoordinator
            .push(ReissueConsentSceneFactory(router: ReissueConsentRouter(sceneCoordinator: sceneCoordinator),
                                             tokens: tokens,
                                             resolver: resolver,
                                             context: context),
                  animated: true)
    }
}
