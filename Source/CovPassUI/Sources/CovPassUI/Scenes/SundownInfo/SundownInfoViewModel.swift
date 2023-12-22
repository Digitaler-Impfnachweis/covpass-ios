//
//  SundownInfoViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import PromiseKit
import UIKit

private enum Constants {
    static let popup_sundown_info_image = "popup_sundown_info_image".localized(bundle: .main)
    static let popup_sundown_info_title = "popup_sundown_info_title".localized.localized(bundle: .main)
    static let popup_sundown_info_copy = "popup_sundown_info_copy".localized.localized(bundle: .main)
    static let popup_sundown_info_subtitle = "popup_sundown_info_subtitle".localized.localized(bundle: .main)
    static let popup_sundown_info_bullet1 = "popup_sundown_info_bullet1".localized.localized(bundle: .main)
    static let popup_sundown_info_bullet2 = "popup_sundown_info_bullet2".localized.localized(bundle: .main)
    static let popup_sundown_info_bullet3 = "popup_sundown_info_bullet3".localized.localized(bundle: .main)
    static let popup_sundown_info_bullet4 = "popup_sundown_info_bullet4".localized.localized(bundle: .main)
    static let popup_sundown_info_bullet5 = "popup_sundown_info_bullet5".localized.localized(bundle: .main)
    static let popup_sundown_info_bullet6 = "popup_sundown_info_bullet6".localized.localized(bundle: .main)
    static let popup_sundown_info_bullet7 = "popup_sundown_info_bullet7".localized.localized(bundle: .main)
    static let popup_sundown_info_bullet8 = "popup_sundown_info_bullet8".localized.localized(bundle: .main)
    static let popup_sundown_info_bullet9 = "popup_sundown_info_bullet9".localized.localized(bundle: .main)
}

final class SundownInfoViewModel: SundownInfoViewModelProtocol {
    // MARK: - Properties

    var image: UIImage = .startScreen
    var imageDescription: String = Constants.popup_sundown_info_image
    var title: String = Constants.popup_sundown_info_title
    var copy: String = Constants.popup_sundown_info_copy
    var subtitle: String = Constants.popup_sundown_info_subtitle
    var bulletPoints: NSAttributedString {
        var bulletPoints = NSAttributedString.toBullets([bullet1, bullet2, bullet3])
        if Constants.popup_sundown_info_bullet4 != "popup_sundown_info_bullet4" {
            bulletPoints = bulletPoints.appendBullets([bullet4])
        }
        if Constants.popup_sundown_info_bullet5 != "popup_sundown_info_bullet5" {
            bulletPoints = bulletPoints.appendBullets([bullet5])
        }
        if Constants.popup_sundown_info_bullet6 != "popup_sundown_info_bullet6" {
            bulletPoints = bulletPoints.appendBullets([bullet6])
        }
        if Constants.popup_sundown_info_bullet7 != "popup_sundown_info_bullet7" {
            bulletPoints = bulletPoints.appendBullets([bullet7])
        }
        if Constants.popup_sundown_info_bullet8 != "popup_sundown_info_bullet8" {
            bulletPoints = bulletPoints.appendBullets([bullet8])
        }
        if Constants.popup_sundown_info_bullet9 != "popup_sundown_info_bullet9" {
            bulletPoints = bulletPoints.appendBullets([bullet9])
        }
        return bulletPoints
    }

    private var bullet1: NSAttributedString = Constants.popup_sundown_info_bullet1.styledAs(.body)
    private var bullet2: NSAttributedString = Constants.popup_sundown_info_bullet2.styledAs(.body)
    private var bullet3: NSAttributedString = Constants.popup_sundown_info_bullet3.styledAs(.body)
    private var bullet4: NSAttributedString = Constants.popup_sundown_info_bullet4.styledAs(.body)
    private var bullet5: NSAttributedString = Constants.popup_sundown_info_bullet5.styledAs(.body)
    private var bullet6: NSAttributedString = Constants.popup_sundown_info_bullet6.styledAs(.body)
    private var bullet7: NSAttributedString = Constants.popup_sundown_info_bullet7.styledAs(.body)
    private var bullet8: NSAttributedString = Constants.popup_sundown_info_bullet8.styledAs(.body)
    private var bullet9: NSAttributedString = Constants.popup_sundown_info_bullet9.styledAs(.body)
    private let resolver: Resolver<Void>
    private var persistence: Persistence

    // MARK: - Lifecycle

    init(
        resolvable: Resolver<Void>,
        persistence: Persistence
    ) {
        self.persistence = persistence
        resolver = resolvable
    }

    func cancel() {
        persistence.showSundownInfo = false
        resolver.fulfill_()
    }
}
