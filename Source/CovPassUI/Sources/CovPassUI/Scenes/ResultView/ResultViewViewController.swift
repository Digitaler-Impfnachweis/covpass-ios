import CovPassCommon
import UIKit

public class ResultViewViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var submitButton: MainButton!
    @IBOutlet var bottomStackView: UIStackView!
    @IBOutlet var pdfExportButton: MainButton!
    @IBOutlet var scrollView: UIScrollView!

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
        setupGradientBottomView()
    }

    func configureView() {
        configureSaveButton()
        configurePdfExportButton()
        configureImageView()
        configureLabels()
    }

    // MARK: Private methods

    private func configureSaveButton() {
        submitButton.style = .primary
        submitButton.title = viewModel.buttonTitle
        submitButton.action = viewModel.submitTapped
    }

    private func configurePdfExportButton() {
        pdfExportButton.isHidden = viewModel.shareButtonTitle.isNilOrEmpty
        pdfExportButton.title = viewModel.shareButtonTitle
        pdfExportButton.style = .secondary
        pdfExportButton.icon = .share
        pdfExportButton.action = viewModel.shareAsPdf
    }

    private func configureImageView() {
        imageView.image = viewModel.image
    }

    private func configureLabels() {
        titleLabel.attributedText = viewModel.title.styledAs(.header_1)
        descriptionLabel.attributedText = viewModel.description.styledAs(.body)
    }

    private func setupGradientBottomView() {
        bottomStackView.layoutIfNeeded()
        scrollView.contentInset.bottom = bottomStackView.bounds.height - 80
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bottomStackView.bounds
        gradientLayer.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor.backgroundPrimary.cgColor, UIColor.backgroundPrimary.cgColor]
        bottomStackView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
