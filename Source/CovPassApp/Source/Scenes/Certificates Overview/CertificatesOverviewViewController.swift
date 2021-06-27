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

class CertificatesOverviewViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet var headerView: InfoHeaderView!
    @IBOutlet var addButton: MainButton!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var dotPageIndicator: DotPageIndicator!

    // MARK: - Public

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
        viewModel.updateTrustList()
        setupHeaderView()
        setupActionButton()
        setupCollecttionView()
        setupDotIndicator()
        viewModel.loadCertificates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedCertificateIndex = viewModel.selectedCertificateIndex {
            collectionView.scrollToItem(at: IndexPath(item: selectedCertificateIndex, section: 0), at: .centeredHorizontally, animated: true)
            dotPageIndicator.selectDot(withIndex: selectedCertificateIndex)
        }
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
        headerView.attributedTitleText = "vaccination_start_screen_title".localized.styledAs(.header_2)
        headerView.image = .help
        headerView.action = { [weak self] in
            self?.viewModel.showAppInformation()
        }
    }

    private func setupCollecttionView() {
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
        addButton.action = { [weak self] in
            self?.viewModel.scanCertificate(withIntroduction: true)
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
        reloadCollectionView()
    }

    func viewModelDidUpdateFavorite() {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
        dotPageIndicator.selectDot(withIndex: 0)
        viewModel.loadCertificates()
    }

    func viewModelDidDeleteCertificate() {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
        dotPageIndicator.selectDot(withIndex: 0)
        viewModel.loadCertificates()
    }

    func viewModelUpdateDidFailWithError(_: Error) {
        viewModel.showErrorDialog()
    }
}
