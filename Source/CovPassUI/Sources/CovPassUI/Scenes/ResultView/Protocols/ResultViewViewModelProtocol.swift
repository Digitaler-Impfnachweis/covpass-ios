import CovPassCommon
import UIKit

public protocol ResultViewViewModelProtocol {
    var image: UIImage { get }
    var title: String { get }
    var description: String { get }
    var buttonTitle: String { get }
    func submitTapped()
}
