//
//  CheckSituationViewModelProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import UIKit

public protocol CheckSituationViewModelProtocol {
    var navBarTitle: String { get }
    var footerText: String { get }
    var newBadgeIconIsHidden: Bool { get }
    var pageImageIsHidden: Bool { get }
    var subTitleIsHidden: Bool { get }
    var offlineRevocationIsHidden: Bool { get }
    var descriptionTextIsTop: Bool { get }
    var hStackViewIsHidden: Bool { get }
    var buttonIsHidden: Bool { get set }
    var descriptionIsHidden: Bool { get }
    var delegate: ViewModelDelegate? { get set }

    // MARK: Update related properties

    var updateContextHidden: Bool { get }
    var offlineModusButton: String { get }
    var loadingHintTitle: String { get }
    var cancelButtonTitle: String { get }
    var listTitle: String { get }
    var downloadStateHintTitle: String { get }
    var downloadStateHintIcon: UIImage { get }
    var downloadStateHintColor: UIColor { get }
    var downloadStateTextColor: UIColor { get }
    var certificateProviderTitle: String { get }
    var certificateProviderSubtitle: String { get }
    var authorityListTitle: String { get }
    var authorityListSubtitle: String { get }
    var ifsgTitle: String { get }
    var ifsgSubtitle: String { get }
    var isLoading: Bool { get }
    var authorityListIsHidden: Bool { get }
    func doneIsTapped()
    func refresh()
    func cancel()
}
