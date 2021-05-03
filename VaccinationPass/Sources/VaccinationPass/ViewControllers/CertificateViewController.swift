//
//  CertificateViewController.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import UIKit
import VaccinationCommon
import VaccinationUI
import Scanner

public class CertificateViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet public var headerView: InfoHeaderView!
    @IBOutlet public var addButton: MainButton!
    @IBOutlet public var collectionView: UICollectionView!
    @IBOutlet public var dotPageIndicator: DotPageIndicator!
    
    // MARK: - Public
    
    public var viewModel: CertificateViewModel!

    // MARK: - Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        setupHeaderView()
        setupActionButton()
        setupCollecttionView()
        setupDotIndicator()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.loadCertificatesConfiguration()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Private
    
    private func setupDotIndicator() {
        dotPageIndicator.delegate = self
        dotPageIndicator.numberOfDots = viewModel.certificates.count
        dotPageIndicator.isHidden = viewModel.certificates.count == 1 ? true : false
    }
    
    private func setupHeaderView() {
        headerView.attributedTitleText = viewModel.headlineTitle.styledAs(.header_2)
        headerView.image = viewModel.headlineButtonImage
    }
    
    private func setupCollecttionView() {
        collectionView.clipsToBounds = false
        collectionView.delegate = self
        collectionView.dataSource = self
        let layout = CardFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "\(NoCertificateCollectionViewCell.self)", bundle: UIConstants.bundle), forCellWithReuseIdentifier: "\(NoCertificateCollectionViewCell.self)")
        collectionView.register(UINib(nibName: "\(QrCertificateCollectionViewCell.self)", bundle: UIConstants.bundle), forCellWithReuseIdentifier: "\(QrCertificateCollectionViewCell.self)")
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func setupActionButton() {
        addButton.icon = viewModel?.addButtonImage
        addButton.action = { [weak self] in
            self?.viewModel.scanCertificate()
        }
    }

    private func reloadCollectionView() {
        collectionView.reloadData()
        dotPageIndicator.numberOfDots = viewModel.certificates.count
        dotPageIndicator.isHidden = viewModel.certificates.count == 1 ? true : false
    }
}

// MARK: - UITableViewDataSource

extension CertificateViewController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.certificates.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reuseIdentifier(for: indexPath), for: indexPath) as? BaseCardCollectionViewCell else { return UICollectionViewCell() }
        viewModel.configure(cell: cell, at: indexPath)

        // FIXME: DOES NOT WORK
        cell.onAction = { [weak self] in
            self?.viewModel.showCertificate(at: indexPath)
        }
        cell.onFavorite = { [weak self] in
            // TODO mark as favorite
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CertificateViewController: UICollectionViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        dotPageIndicator.selectDot(withIndex: visibleIndexPath.item)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.showCertificate(at: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CertificateViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width - 40, height: collectionView.bounds.height)
    }
}

// MARK: - DotPageIndicatorDelegate

extension CertificateViewController: DotPageIndicatorDelegate {
    public func dotPageIndicator(_ dotPageIndicator: DotPageIndicator, didTapDot index: Int) {
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
    }
}

// MARK: - StoryboardInstantiating

extension CertificateViewController: StoryboardInstantiating {
    public static var storyboardName: String {
        VaccinationPassConstants.Storyboard.Pass
    }
}

// MARK: - UpdateDelegate

extension CertificateViewController: ViewModelDelegate {
    public func shouldReload() {
        reloadCollectionView()
    }
}
