import CovPassCommon
import CovPassUI

protocol ReissueStartViewModelProtocol {
    var delegate: ViewModelDelegate? { get set }
    var certItem: CertificateItem { get }
    var titleText: String { get }
    var descriptionText: String { get }
    var hintText: String { get }
    var buttonStartTitle: String { get }
    var buttonLaterTitle: String { get }
    func processStart()
    func processLater()
}
