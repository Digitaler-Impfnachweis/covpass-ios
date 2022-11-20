import CovPassUI

class ChooseCheckSituationRouter: ChooseCheckSituationRouterProtocol {

    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }
}
