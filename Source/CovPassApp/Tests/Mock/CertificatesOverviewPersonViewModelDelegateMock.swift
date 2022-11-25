@testable import CovPassApp
import XCTest

class CertificatesOverviewPersonViewModelDelegateMock: CertificatesOverviewPersonViewModelDelegate {
    let viewModelNeedsCertificateVisibleExpectation = XCTestExpectation()

    func viewModelDidUpdate() {}

    func viewModelNeedsFirstCertificateVisible() {}

    func viewModelNeedsCertificateVisible(at _: Int) {
        viewModelNeedsCertificateVisibleExpectation.fulfill()
    }
}
