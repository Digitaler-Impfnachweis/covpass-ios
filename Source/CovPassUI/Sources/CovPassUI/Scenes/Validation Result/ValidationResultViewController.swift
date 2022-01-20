//
//  ValidationResultViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import CovPassCommon

public struct Paragraph {
    var icon: UIImage?
    var title: String
    var subtitle: String
    
    public init (icon: UIImage?,
                 title: String,
                 subtitle: String) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
}

public typealias ValidationResultViewModel = ValidationViewModel & CancellableViewModelProtocol

public protocol ResultViewModelDelegate: AnyObject {
    func viewModelDidUpdate()
    func viewModelDidChange(_ newViewModel: ValidationResultViewModel)
}

public protocol ValidationViewModel {
    var router: ValidationResultRouterProtocol { get set }
    var repository: VaccinationRepositoryProtocol { get set }
    var certificate: CBORWebToken? { get set }
    var delegate: ResultViewModelDelegate? { get set }
    var toolbarState: CustomToolbarState { get }
    var icon: UIImage? { get }
    var resultTitle: String { get }
    var resultBody: String { get }
    var paragraphs: [Paragraph] { get }
    var info: String? { get }
    var buttonHidden: Bool { get set }
    func scanNextCertifcate()
}

private enum Constants {
    static let confirmButtonLabel = "validation_check_popup_valid_vaccination_button_title".localized
    
    enum Accessibility {
        static let image = VoiceOverOptions.Settings(label: "accessibility_image_alternative_text".localized)
        static let close = VoiceOverOptions.Settings(label: "accessibility_popup_label_close".localized)
    }
}

public class ValidationResultViewController: UIViewController {
    // MARK: - IBOutlet
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var toolbarView: CustomToolbarView!
    @IBOutlet var headline: InfoHeaderView!
    @IBOutlet var imageContainerView: UIStackView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var resultView: ParagraphView!
    @IBOutlet var paragraphStackView: UIStackView!
    @IBOutlet var infoView: PlainLabel!
    
    // MARK: - Properties
    
    private(set) var viewModel: ValidationResultViewModel
    
    // MARK: - Lifecycle
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }
    
    public init(viewModel: ValidationResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .uiBundle)
        self.viewModel.delegate = self
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureHeadline()
        configureToolbarView()
        configureAccessibility()
        updateViews()
    }
    
    // MARK: - Private
    
    private func updateViews() {
        toolbarView.primaryButton.isHidden = viewModel.buttonHidden
        
        stackView.setCustomSpacing(.space_24, after: imageContainerView)
        stackView.setCustomSpacing(.space_24, after: resultView)
        
        imageView.image = viewModel.icon
        imageView.enableAccessibility(label: Constants.Accessibility.image.label)
        
        resultView.attributedTitleText = viewModel.resultTitle.styledAs(.header_1)
        resultView.attributedBodyText = viewModel.resultBody.styledAs(.body)
        resultView.bottomBorder.isHidden = true
        
        infoView.attributedText = viewModel.info?.styledAs(.body).colored(.onBackground40)
        infoView.layoutMargins = .init(top: .zero, left: .space_24, bottom: .zero, right: .space_24)
        
        paragraphStackView.subviews.forEach {
            $0.removeFromSuperview()
            self.paragraphStackView.removeArrangedSubview($0)
        }
        viewModel.paragraphs.forEach {
            let p = ParagraphView()
            p.attributedTitleText = $0.title.styledAs(.header_3)
            p.attributedBodyText = $0.subtitle.styledAs(.body)
            p.image = $0.icon
            p.imageView.tintColor = .brandAccent
            p.bottomBorder.isHidden = true
            p.layoutMargins.bottom = .space_20
            self.paragraphStackView.addArrangedSubview(p)
        }
        
        UIAccessibility.post(notification: .layoutChanged, argument: resultView.titleLabel)
    }
    
    private func configureHeadline() {
        headline.attributedTitleText = "".styledAs(.header_3)
        headline.action = { [weak self] in
            self?.viewModel.cancel()
        }
        headline.image = .close
        headline.actionButton.enableAccessibility(label: Constants.Accessibility.close.label)
        stackView.setCustomSpacing(.space_24, after: headline)
    }
    
    private func configureToolbarView() {
        toolbarView.state = viewModel.toolbarState
        toolbarView.delegate = self
    }
    
    private func configureAccessibility() {
        headline.actionButton.enableAccessibility(label: Constants.Accessibility.close.label)
    }
}

// MARK: - ViewModelDelegate

extension ValidationResultViewController: ResultViewModelDelegate {
    public func viewModelDidUpdate() {
        updateViews()
    }
    
    public func viewModelDidChange(_ newViewModel: ValidationResultViewModel) {
        viewModel = newViewModel
        viewModel.delegate = self
        updateViews()
    }
}

// MARK: - CustomToolbarViewDelegate

extension ValidationResultViewController: CustomToolbarViewDelegate {
    public func customToolbarView(_: CustomToolbarView, didTap buttonType: ButtonItemType) {
        switch buttonType {
        case .textButton:
            viewModel.scanNextCertifcate()
        default:
            return
        }
    }
}

// MARK: - ModalInteractiveDismissibleProtocol

extension ValidationResultViewController: ModalInteractiveDismissibleProtocol {
    public func canDismissModalViewController() -> Bool {
        viewModel.isCancellable()
    }
    
    public func modalViewControllerDidDismiss() {
        viewModel.cancel()
    }
}
