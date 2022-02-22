import UIKit
import CovPassUI

class ReissueResultViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var newCertTitle: UILabel!
    @IBOutlet var newCertStack: UIStackView!
    @IBOutlet var oldCertTitle: UILabel!
    @IBOutlet var oldCertStack: UIStackView!
    @IBOutlet var deleteOldCertButton: MainButton!
    @IBOutlet var deleterOldCertLaterButton: MainButton!
    
    private(set) var viewModel: ReissueResultViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: ReissueResultViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        updateView()
    }

    // MARK: - Methods
    
    
    private func configureActions() {
        deleteOldCertButton.action = viewModel.deleteOldToken
        deleterOldCertLaterButton.action = viewModel.deleteOldToken
    }
    
    func updateView() {
        titleLabel.attributedText = viewModel.title.styledAs(.header_2)
        subTitleLabel.attributedText = viewModel.subtitle.styledAs(.body)
        newCertTitle.attributedText = viewModel.newCertTitle.styledAs(.header_3).colored(.onBackground70)
        oldCertTitle.attributedText = viewModel.oldCertTitle.styledAs(.header_3).colored(.onBackground70)
        deleteOldCertButton.title = viewModel.deleteOldCertButtonTitle
        deleterOldCertLaterButton.title = viewModel.deleteOldCertLaterButtonTitle
        newCertStack.addArrangedSubview(viewModel.newCertItem)
        oldCertStack.addArrangedSubview(viewModel.oldCertItem)
    }
    
 }

extension ReissueResultViewController: ViewModelDelegate {
    func viewModelDidUpdate() {
        updateView()
    }

    func viewModelUpdateDidFailWithError(_: Error) {
        // already handled in ViewModel
    }
}
