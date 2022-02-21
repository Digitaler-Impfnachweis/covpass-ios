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
        // TODO: add route to next screen
    }
    
    func cancel() {
        sceneCoordinator.dimiss(animated: true)
    }
}
