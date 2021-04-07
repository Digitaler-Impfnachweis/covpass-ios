//
//  OnboardingPageViewModelTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class OnboardingPageViewModelTests: XCTestCase {
    var sut: OnboardingPageViewModel!

    override func setUp() {
        super.setUp()
        sut = OnboardingPageViewModel(type: .page1)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testSettings() {
        XCTAssertEqual(sut.imageAspectRatio, 375 / 220)
        XCTAssertEqual(sut.imageWidth, UIScreen.main.bounds.width)
        XCTAssertEqual(sut.imageHeight, sut.imageWidth / sut.imageAspectRatio)
        XCTAssertEqual(sut.imageContentMode, .scaleAspectFit)
        XCTAssertEqual(sut.headlineFont, UIConstants.Font.onboardingHeadlineFont)
        XCTAssertEqual(sut.headlineColor, .black)
        XCTAssertEqual(sut.paragraphBodyFont, UIConstants.Font.regularLarger)
        XCTAssertEqual(sut.backgroundColor, UIConstants.BrandColor.backgroundPrimary)
    }

    func testPage1Values() {
        sut = OnboardingPageViewModel(type: .page1)
        XCTAssertEqual(sut.image, UIImage(named: UIConstants.IconName.OnboardingScreen1, in: UIConstants.bundle, compatibleWith: nil))
        XCTAssertEqual(sut.title, "Nach der Impfung erhalten Sie ihre Impfbescheinigung mit QR-Code")
        XCTAssertEqual(sut.info, "Gut zu wissen: Sie können den QR-Code nur ein mal verwenden. Die Impfbescheinigung ist anschließend an das einlesende Smartphone gebunden.")
    }

    func testPage2Values() {
        sut = OnboardingPageViewModel(type: .page2)
        XCTAssertEqual(sut.image, UIImage(named: UIConstants.IconName.OnboardingScreen2, in: UIConstants.bundle, compatibleWith: nil))
        XCTAssertEqual(sut.title, "Scannen Sie mit der App den QR-Code auf Ihrer Impfbescheinigung")
        XCTAssertEqual(sut.info, "Tipp: Speichern Sie Impfbescheinigungen von der ganzen Familie zusammen auf einem Smartphone und verwalten Sie diese sicher mit der App.")
    }

    func testPage3Values() {
        sut = OnboardingPageViewModel(type: .page3)
        XCTAssertEqual(sut.image, UIImage(named: UIConstants.IconName.OnboardingScreen3, in: UIConstants.bundle, compatibleWith: nil))
        XCTAssertEqual(sut.title, "Weisen Sie Ihren Impfschutz schnnell und sicher mit dem Impfticket nach")
        XCTAssertEqual(sut.info, "Sobald Ihr Impfschutz vollständig ist, erstellt die App automatisch einen Nachweis mit QR-Code. Dieses Impfticket enthält nur die nötigsten Daten. Zeigen Sie es zum Beispiel bei Flugreisen vor.")
    }
}
