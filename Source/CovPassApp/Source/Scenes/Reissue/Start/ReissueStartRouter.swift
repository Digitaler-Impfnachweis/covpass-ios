import CovPassUI
import CovPassCommon

class ReissueStartRouter: ReissueStartRouterProtocol {

    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showNext(tokens: [ExtendedCBORWebToken]) {
        sceneCoordinator
            .push(ReissueConsentSceneFactory(router: ReissueConsentRouter(sceneCoordinator: sceneCoordinator),
                                             tokens: tokens))
            .cauterize()
    }
}
