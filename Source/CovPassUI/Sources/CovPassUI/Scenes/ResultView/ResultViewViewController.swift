import CovPassCommon
import UIKit

public class ResultViewViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var submitButton: MainButton!

    // MARK: - Properties

    private(set) var viewModel: ResultViewViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    public init(viewModel: ResultViewViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .module)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    func configureView() {
        configureSaveButton()
        configureImageView()
        configureLabels()
    }

    // MARK: Private methods

    private func configureSaveButton() {
        submitButton.style = .primary
        submitButton.title = viewModel.buttonTitle
        submitButton.action = viewModel.submitTapped
    }

    private func configureImageView() {
        imageView.image = viewModel.image
    }

    private func configureLabels() {
        titleLabel.attributedText = viewModel.title.styledAs(.header_1)
        descriptionLabel.attributedText = viewModel.description.styledAs(.body)
    }
}
