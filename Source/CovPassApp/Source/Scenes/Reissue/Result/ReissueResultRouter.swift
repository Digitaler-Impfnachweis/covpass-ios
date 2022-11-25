import CovPassUI
import Foundation
import PromiseKit

class ReissueResultRouter: ReissueResultRouterProtocol, DialogRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showError(_ error: Error, resolver _: Resolver<Void>) {
        print("\(#file):\(#function) Error: \(error)")
        showDialog(
            title: "error_standard_unexpected_title".localized,
            message: "error_standard_unexpected_message".localized,
            actions: [
                .init(title: "error_standard_unexpected_button_title".localized)
            ],
            style: .alert
        )
    }
}
