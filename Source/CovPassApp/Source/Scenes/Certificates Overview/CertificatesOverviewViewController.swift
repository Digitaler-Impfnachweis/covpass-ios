//
//  CertificatesOverviewViewController.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import Scanner
import UIKit

private enum Constants {
    enum Accessibility {
        static let addCertificate = VoiceOverOptions.Settings(label: "accessibility_vaccination_start_screen_label_add_certificate".localized)
        static let moreInformation = VoiceOverOptions.Settings(label: "accessibility_vaccination_start_screen_label_information".localized)
    }

    enum Layout {
        static let actionLineHeight: CGFloat = 17
    }
}

class CertificatesOverviewViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headerView: OverviewHeaderView!
    @IBOutlet var addButton: MainButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var dotPageIndicator: DotPageIndicator!

    private(set) var viewModel: CertificatesOverviewViewModelProtocol

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init?(coder: NSCoder) not implemented yet") }

    init(viewModel: CertificatesOverviewViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: .main)
        self.viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        view.backgroundColor = UIColor.backgroundPrimary
        collectionView.backgroundColor = UIColor.backgroundPrimary
        setupHeaderView()
        setupActionButton()
        setupCollectionView()
        setupDotIndicator()
        viewModel.showNotificationsIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.updateTrustList()
        viewModel.updateBoosterRules()
        viewModel.updateValueSets()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Private

    private func setupDotIndicator() {
        dotPageIndicator.delegate = self
        dotPageIndicator.numberOfDots = viewModel.certificateViewModels.count
        dotPageIndicator.isHidden = viewModel.certificateViewModels.count == 1
    }

    private func setupHeaderView() {
        headerView.attributedTitleText = "certificate_action_button_check_validity".localized.styledAs(.header_3).colored(.brandBase).lineHeight(Constants.Layout.actionLineHeight)
        headerView.titleButton.isHidden = !viewModel.hasCertificates
        headerView.titleIcon.isHidden = !viewModel.hasCertificates
        headerView.image = .help
        headerView.actionButton.enableAccessibility(label:  Constants.Accessibility.moreInformation.label)

        headerView.titleAction = { [weak self] in
            self?.viewModel.showRuleCheck()
        }
        headerView.action = { [weak self] in
            self?.viewModel.showAppInformation()
        }
    }

    private func setupCollectionView() {
        collectionView.clipsToBounds = false
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = CardFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "\(NoCertificateCollectionViewCell.self)", bundle: Bundle.uiBundle), forCellWithReuseIdentifier: "\(NoCertificateCollectionViewCell.self)")
        collectionView.register(UINib(nibName: "\(CertificateCollectionViewCell.self)", bundle: Bundle.uiBundle), forCellWithReuseIdentifier: "\(CertificateCollectionViewCell.self)")
        collectionView.showsHorizontalScrollIndicator = false
    }

    private func setupActionButton() {
        addButton.icon = .plus
        addButton.innerButton.accessibilityLabel = Constants.Accessibility.addCertificate.label
        addButton.action = { [weak self] in
            self?.viewModel.scanCertificate()
        }
        if viewModel.isLoading {
            addButton.startAnimating()
        } else {
            addButton.stopAnimating()
        }
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

extension CertificatesOverviewViewController: UICollectionViewDataSource {
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

        return cell
    }
}

// MARK: - UITableViewDelegate

extension CertificatesOverviewViewController: UICollectionViewDelegate {
    public func scrollViewDidEndDecelerating(_: UIScrollView) {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        dotPageIndicator.selectDot(withIndex: visibleIndexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CertificatesOverviewViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width - 40, height: collectionView.bounds.height)
    }
}

// MARK: - DotPageIndicatorDelegate

extension CertificatesOverviewViewController: DotPageIndicatorDelegate {
    public func dotPageIndicator(_: DotPageIndicator, didTapDot index: Int) {
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
    }
}

// MARK: - ViewModelDelegate

extension CertificatesOverviewViewController: CertificatesOverviewViewModelDelegate {
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
