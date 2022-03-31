import CovPassUI
import CovPassCommon
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
                  resolver: Resolver<Void>) {
        sceneCoordinator
            .push(ReissueConsentSceneFactory(router: ReissueConsentRouter(sceneCoordinator: sceneCoordinator),
                                             tokens: tokens,
                                             resolver: resolver),
                  animated: true)
    }
}
