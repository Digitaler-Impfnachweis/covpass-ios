import CovPassUI
import CovPassCommon

protocol ReissueResultViewModelProtocol {
    var delegate: ViewModelDelegate? { get set }
    var title: String { get }
    var subtitle: String { get }
    var newCertTitle: String { get }
    var newToken: ExtendedCBORWebToken { get }
    var newCertItem: CertificateItem { get }
    var oldCertTitle: String { get }
    var oldToken: ExtendedCBORWebToken { get }
    var oldCertItem: CertificateItem { get }
    var deleteOldCertButtonTitle: String { get }
    var deleteOldCertLaterButtonTitle: String { get }
    func deleteOldToken()
    func deleteOldTokenLater()
}
