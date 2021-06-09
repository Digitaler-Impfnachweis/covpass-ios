//
//  UIImage+DS.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

public extension UIImage {
    @ImageLoader(name: "back_arrow")
    private(set) static var arrowBack

    @ImageLoader(name: "cancel")
    private(set) static var cancel

    @ImageLoader(name: "plus")
    private(set) static var plus

    @ImageLoader(name: "check")
    private(set) static var check

    @ImageLoader(name: "rg_arrow_down")
    private(set) static var arrowDown

    @ImageLoader(name: "onboarding_screen_1")
    private(set) static var onboardingScreen1

    @ImageLoader(name: "onboarding_screen_2")
    private(set) static var onboardingScreen2

    @ImageLoader(name: "onboarding_screen_3")
    private(set) static var onboardingScreen3

    @ImageLoader(name: "Illustration_consent")
    private(set) static var onboardingScreen4

    @ImageLoader(name: "illustration_1")
    private(set) static var illustration1

    @ImageLoader(name: "illustration_2")
    private(set) static var illustration2

    @ImageLoader(name: "illustration_3")
    private(set) static var illustration3

    @ImageLoader(name: "start_screen_1")
    private(set) static var startScreen

    @ImageLoader(name: "icon_lock")
    private(set) static var lock

    @ImageLoader(name: "chevron_right")
    private(set) static var chevronRight

    @ImageLoader(name: "button_close")
    private(set) static var close

    @ImageLoader(name: "scan_proof_image")
    private(set) static var proofScreen

    @ImageLoader(name: "settings_image")
    private(set) static var settings

    @ImageLoader(name: "status_full")
    private(set) static var statusFull

    @ImageLoader(name: "status_partial")
    private(set) static var statusPartial

    @ImageLoader(name: "star_full")
    private(set) static var starFull

    @ImageLoader(name: "star_partial")
    private(set) static var starPartial

    @ImageLoader(name: "help")
    private(set) static var help

    @ImageLoader(name: "no_vaccine_image")
    private(set) static var noCertificate

    @ImageLoader(name: "star_48px")
    private(set) static var starEmpty

    @ImageLoader(name: "prevention_label")
    private(set) static var completness

    @ImageLoader(name: "shield_lefthalf_fill")
    private(set) static var halfShield

    @ImageLoader(name: "icon_qr")
    private(set) static var scan

    @ImageLoader(name: "icon_card")
    private(set) static var card

    @ImageLoader(name: "delete")
    private(set) static var delete

    @ImageLoader(name: "warning")
    private(set) static var warning

    @ImageLoader(name: "checkbox_checked")
    private(set) static var checkboxChecked

    @ImageLoader(name: "checkbox_unchecked")
    private(set) static var checkboxUnchecked

    @ImageLoader(name: "result_success")
    private(set) static var resultSuccess

    @ImageLoader(name: "result_error")
    private(set) static var resultError

    @ImageLoader(name: "data")
    private(set) static var data

    @ImageLoader(name: "checkmark")
    private(set) static var validationCheckmark

    @ImageLoader(name: "pending")
    private(set) static var validationPending

    @ImageLoader(name: "search")
    private(set) static var validationSearch

    @ImageLoader(name: "group")
    private(set) static var group

    @ImageLoader(name: "status_full_detail")
    private(set) static var statusFullDetail

    @ImageLoader(name: "status_partial_detail")
    private(set) static var statusPartialDetail

    @ImageLoader(name: "icon_test")
    private(set) static var iconTest
}

@propertyWrapper
private struct ImageLoader {
    var wrappedValue: UIImage

    init(name: String) {
        guard let image = UIImage(named: name, in: Bundle.uiBundle, compatibleWith: nil) else {
            fatalError("Image: \(name) does not exist")
        }
        wrappedValue = image
    }
}
