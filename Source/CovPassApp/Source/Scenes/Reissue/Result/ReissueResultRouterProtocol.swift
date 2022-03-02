import CovPassUI
import Foundation
import PromiseKit

protocol ReissueResultRouterProtocol: RouterProtocol {
    func dismiss()
    func showError(_ error: Error, resolver: Resolver<Void>)
}
