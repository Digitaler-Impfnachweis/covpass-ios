//
//  UIImage+DS.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit

extension UIImage {

    @ImageLoader(name: "back_arrow")
    public private(set) static var arrowBack

    @ImageLoader(name: "cancel")
    public private(set) static var cancel

    @ImageLoader(name: "plus")
    public private(set) static var plus

    @ImageLoader(name: "check")
    public private(set) static var check

    @ImageLoader(name: "rg_arrow_down")
    public private(set) static var arrowDown

    @ImageLoader(name: "onboarding_screen_1")
    public private(set) static var onboardingScreen1

    @ImageLoader(name: "onboarding_screen_2")
    public private(set) static var onboardingScreen2

    @ImageLoader(name: "onboarding_screen_3")
    public private(set) static var onboardingScreen3

    @ImageLoader(name: "illustration_consent")
    public private(set) static var onboardingScreen4

    @ImageLoader(name: "illustration_1")
    public private(set) static var illustration1

    @ImageLoader(name: "illustration_2")
    public private(set) static var illustration2

    @ImageLoader(name: "illustration_3")
    public private(set) static var illustration3

    @ImageLoader(name: "start_screen_1")
    public private(set) static var startScreen

    @ImageLoader(name: "icon_lock")
    public private(set) static var lock

    @ImageLoader(name: "chevron_right")
    public private(set) static var chevronRight

    @ImageLoader(name: "button_close")
    public private(set) static var close

    @ImageLoader(name: "scan_proof_image")
    public private(set) static var proofScreen

    @ImageLoader(name: "settings_image")
    public private(set) static var settings

    @ImageLoader(name: "status_full")
    public private(set) static var statusFull

    @ImageLoader(name: "status_partial")
    public private(set) static var statusPartial

    @ImageLoader(name: "star_full")
    public private(set) static var starFull

    @ImageLoader(name: "star_partial")
    public private(set) static var starPartial

    @ImageLoader(name: "help")
    public private(set) static var help

    @ImageLoader(name: "no_vaccine_image")
    public private(set) static var noCertificate

    @ImageLoader(name: "star_48px")
    public private(set) static var starEmpty

    @ImageLoader(name: "prevention_label")
    public private(set) static var completness

    @ImageLoader(name: "shield_lefthalf_fill")
    public private(set) static var halfShield

    @ImageLoader(name: "icon_qr")
    public private(set) static var scan

    @ImageLoader(name: "icon_card")
    public private(set) static var card

    @ImageLoader(name: "delete")
    public private(set) static var delete

    @ImageLoader(name: "warning")
    public private(set) static var warning

    @ImageLoader(name: "checkbox_checked")
    public private(set) static var checkboxChecked

    @ImageLoader(name: "checkbox_unchecked")
    public private(set) static var checkboxUnchecked

    @ImageLoader(name: "result_success")
    public private(set) static var resultSuccess

    @ImageLoader(name: "result_error")
    public private(set) static var resultError

    @ImageLoader(name: "data")
    public private(set) static var data

    @ImageLoader(name: "checkmark")
    public private(set) static var validationCheckmark

    @ImageLoader(name: "pending")
    public private(set) static var validationPending

    @ImageLoader(name: "search")
    public private(set) static var validationSearch
}

@propertyWrapper
private struct ImageLoader {
    var wrappedValue: UIImage

    init(name: String) {
        guard let image = UIImage(named: name, in: UIConstants.bundle, compatibleWith: nil) else {
            fatalError("Image: \(name) does not exist")
        }
        wrappedValue = image
    }
}
