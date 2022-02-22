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

    func showNext(token: ExtendedCBORWebToken) {
        sceneCoordinator
            .push(ReissueConsentSceneFactory(router: ReissueConsentRouter(sceneCoordinator: sceneCoordinator),
                                             token: token))
            .cauterize()
    }
    
    func cancel() {
        sceneCoordinator.dimiss(animated: true)
    }
}
