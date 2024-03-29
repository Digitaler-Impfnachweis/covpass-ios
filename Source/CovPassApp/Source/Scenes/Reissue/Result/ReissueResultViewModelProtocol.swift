import CovPassCommon
import CovPassUI

protocol ReissueResultViewModelProtocol {
    var delegate: ViewModelDelegate? { get set }
    var title: String { get }
    var subtitle: String { get }
    var newCertTitle: String { get }
    var newCertItem: CertificateItem { get }
    var oldCertTitle: String { get }
    var oldCertItem: CertificateItem { get }
    var deleteOldCertButtonTitle: String { get }
    var deleteOldCertLaterButtonTitle: String { get }
    func deleteOldTokens()
    func deleteOldTokensLater()
}
