//
//  CertificatesOverviewPersonViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit

class CertificatesOverviewPersonViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet var headerView: OverviewHeaderView!
    @IBOutlet var gotoDetailsButton: MainButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var dotPageIndicator: DotPageIndicator!
    @IBOutlet weak var subtTitleLabel: UILabel!
    private(set) var viewModel: CertificatesOverviewPersonViewModelProtocol
    private(set) var cellWidthMargin: CGFloat = 100
    private(set) var layout: CardFlowLayout

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: CertificatesOverviewPersonViewModelProtocol) {
        self.viewModel = viewModel
        layout = CardFlowLayout(spacing: 0, leftSectionInset: cellWidthMargin / 2)
        super.init(nibName: String(describing: Self.self), bundle: .main)
        self.viewModel.delegate = self
        modalPresentationStyle = .fullScreen
        title = ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
        setupActionButton()
        setupCollectionView()
        setupDotIndicator()
        viewModelNeedsFirstCertificateVisible()
        collectionView.contentInsetAdjustmentBehavior = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModelDidUpdate()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Private

    private func setupDotIndicator() {
        dotPageIndicator.delegate = self
        dotPageIndicator.isHidden = viewModel.dotPageIndicatorIsHidden
        dotPageIndicator.selectedColor = .white
        dotPageIndicator.unselectedColor = .brandBase80
        dotPageIndicator.numberOfDots = viewModel.certificateViewModels.count
    }

    private func setupHeaderView() {
        view.backgroundColor = viewModel.backgroundColor
        collectionView.backgroundColor = viewModel.backgroundColor
        subtTitleLabel.attributedText = viewModel.pageSubtitle.styledAs(.body).colored(.white)
        headerView.attributedTitleText = viewModel.pageTitle.styledAs(.header_2).colored(.white)
        headerView.image = .close
        headerView.action = viewModel.close
        headerView.titleIcon.isHidden = true
    }

    private func setupCollectionView() {
        collectionView.clipsToBounds = false
        collectionView.delegate = self
        collectionView.dataSource = self
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "\(CertificateCollectionViewCell.self)",
                                      bundle: Bundle.uiBundle),
                                forCellWithReuseIdentifier: "\(CertificateCollectionViewCell.self)")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }

    private func setupActionButton() {
        gotoDetailsButton.style = viewModel.manageCertificatesButtonStyle
        gotoDetailsButton.icon = viewModel.manageCertificatesIcon
        gotoDetailsButton.title = viewModel.modalButtonTitle
        gotoDetailsButton.action = viewModel.showDetails
    }

    private func reloadCollectionView() {
        collectionView.reloadData()
        dotPageIndicator.numberOfDots = viewModel.certificateViewModels.count
        let hasOnlyOneCertificate = viewModel.certificateViewModels.count == 1
        dotPageIndicator.isHidden = hasOnlyOneCertificate
        collectionView.isScrollEnabled = !hasOnlyOneCertificate
    }
}

// MARK: - UITableViewDataSource

extension CertificatesOverviewPersonViewController: UICollectionViewDataSource {
    public func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        viewModel.certificateViewModels.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard viewModel.certificateViewModels.count > indexPath.row else { return UICollectionViewCell() }
        let vm = viewModel.certificateViewModels[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: vm.reuseIdentifier, for: indexPath) as? CardCollectionViewCell else { return UICollectionViewCell() }
        cell.viewModel = vm
        cell.viewModel?.delegate = cell
        (cell as? CertificateCollectionViewCell)?.shadow(show: false)
        (cell as? CertificateCollectionViewCell)?.contentStackView.layoutMargins.left = 0
        (cell as? CertificateCollectionViewCell)?.contentStackView.layoutMargins.right = 0
        (cell as? CertificateCollectionViewCell)?.contentStackView.layoutMargins.top = 0
        (cell as? CertificateCollectionViewCell)?.contentStackView.layoutMargins.bottom = 0
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CertificatesOverviewPersonViewController: UICollectionViewDelegate {
    public func scrollViewDidEndDecelerating(_: UIScrollView) {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        dotPageIndicator.selectDot(withIndex: visibleIndexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CertificatesOverviewPersonViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width - cellWidthMargin, height: collectionView.bounds.height)
    }
}

// MARK: - DotPageIndicatorDelegate

extension CertificatesOverviewPersonViewController: DotPageIndicatorDelegate {
    public func dotPageIndicator(_: DotPageIndicator, didTapDot index: Int) {
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
    }
}

// MARK: - ViewModelDelegate

extension CertificatesOverviewPersonViewController: CertificatesOverviewPersonViewModelDelegate {
    func viewModelDidUpdate() {
        setupHeaderView()
        reloadCollectionView()
        setupActionButton()
    }

    func viewModelNeedsFirstCertificateVisible() {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        dotPageIndicator.selectDot(withIndex: 0)
    }

    func viewModelNeedsCertificateVisible(at index: Int) {
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
        dotPageIndicator.selectDot(withIndex: index)
    }
}
