@testable import CovPassApp
@testable import CovPassCommon
@testable import CovPassUI
import XCTest
import PromiseKit

class CertificatesOverviewPersonViewModelTests: XCTestCase {
    
    private var notExpiredNotRevokedNotInvalidCertificateVaccination: ExtendedCBORWebToken {
        var cert = CBORWebToken.mockVaccinationCertificate.extended(vaccinationQRCodeData: "1")
        cert.revoked = false
        cert.invalid = false
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .day, value: 100, to: Date())
        return cert
    }
    
    private var notExpiredNotRevokedNotInvalidCertificateRecovery: ExtendedCBORWebToken {
        var cert = CBORWebToken.mockRecoveryCertificate.extended(vaccinationQRCodeData: "2")
        cert.revoked = false
        cert.invalid = false
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .day, value: 100, to: Date())
        return cert
    }
    
    private var notExpiredNotRevokedNotInvalidCertificateRecovery2: ExtendedCBORWebToken {
        var cert = CBORWebToken.mockRecoveryCertificate.extended(vaccinationQRCodeData: "3")
        cert.revoked = false
        cert.invalid = false
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .day, value: 100, to: Date())
        return cert
    }
    
    private var notExpiredNotRevokedNotInvalidCertificateTest: ExtendedCBORWebToken {
        var cert = CBORWebToken.mockTestCertificate.extended(vaccinationQRCodeData: "4")
        cert.revoked = false
        cert.invalid = false
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .day, value: 100, to: Date())
        return cert
    }
    
    private var notExpiredNotRevokedNotInvalidCertificateTest2: ExtendedCBORWebToken {
        var cert = CBORWebToken.mockTestCertificate.extended(vaccinationQRCodeData: "5")
        cert.revoked = false
        cert.invalid = false
        cert.vaccinationCertificate.exp = Calendar.current.date(byAdding: .day, value: 100, to: Date())
        return cert
    }
    
    private var boosterLogicMock: BoosterLogicMock!
    private var router: CertificatesOverviewPersonRouterMock!
    private var promise: Promise<CertificateDetailSceneResult>!
    private var resolver: Resolver<CertificateDetailSceneResult>!
    private var vaccinationRepository: VaccinationRepositoryMock!
    private var viewModelDelegate: CertificatesOverviewPersonViewModelDelegateMock!
    
    override func setUpWithError() throws {
        boosterLogicMock = BoosterLogicMock()
        router = CertificatesOverviewPersonRouterMock()
        vaccinationRepository = VaccinationRepositoryMock()
        viewModelDelegate = CertificatesOverviewPersonViewModelDelegateMock()
        let (promise, resolver) = Promise<CertificateDetailSceneResult>.pending()
        self.promise = promise
        self.resolver = resolver

    }
    
    override func tearDownWithError() throws {
        vaccinationRepository = nil
        boosterLogicMock = nil
        router = nil
        viewModelDelegate = nil
        promise = nil
        resolver = nil
    }
    
    func configSut(certificates: [ExtendedCBORWebToken]) -> CertificatesOverviewPersonViewModel {
        let certificateHolder = CertificateHolderStatusModelMock()
        let sut = CertificatesOverviewPersonViewModel(router: router,
                                                      repository: vaccinationRepository,
                                                      boosterLogic: boosterLogicMock,
                                                      certificateHolderStatusModel: certificateHolder,
                                                      certificates: certificates,
                                                      resolver: resolver)
        sut.delegate = viewModelDelegate
        return sut
    }
    
    func test_vaccination() {
        // GIVEN
        let certs = [notExpiredNotRevokedNotInvalidCertificateVaccination]
        let sut = self.configSut(certificates: certs)
        
        // WHEN
        let certViewModels = sut.certificateViewModels
        let showBadge = sut.showBadge
        
        // THEN
        XCTAssertEqual(certViewModels.count, 1)
        XCTAssertEqual(certViewModels[0].showNotification, false)
        XCTAssertEqual(certViewModels[0].showNotification, showBadge)
    }
    
    func test_vaccination_and_recovery() {
        // GIVEN
        let certs = [notExpiredNotRevokedNotInvalidCertificateVaccination,
                     notExpiredNotRevokedNotInvalidCertificateRecovery]
        let sut = self.configSut(certificates: certs)
        
        // WHEN
        let certViewModels = sut.certificateViewModels
        let showBadge = sut.showBadge
        
        // THEN
        XCTAssertEqual(certViewModels.count, 2)
        XCTAssertEqual(certViewModels[0].showNotification, false)
        XCTAssertEqual(certViewModels[0].showNotification, showBadge)
    }
    
    func test_vaccination_and_twoRecoveries_and_twoTestCertificates() {
        // GIVEN
        let certs = [notExpiredNotRevokedNotInvalidCertificateVaccination,
                     notExpiredNotRevokedNotInvalidCertificateRecovery,
                     notExpiredNotRevokedNotInvalidCertificateRecovery2,
                     notExpiredNotRevokedNotInvalidCertificateTest,
                     notExpiredNotRevokedNotInvalidCertificateTest2]
        let sut = self.configSut(certificates: certs)
        
        // WHEN
        let certViewModels = sut.certificateViewModels
        let showBadge = sut.showBadge
        
        // THEN
        XCTAssertEqual(certViewModels.count, 3)
        XCTAssertEqual(certViewModels[0].showNotification, false)
        XCTAssertEqual(certViewModels[0].showNotification, showBadge)
    }
    
    func test_vaccination_and_recoveryWithNotification_and_twoTestCertificates() {
        // GIVEN
        let certs = [notExpiredNotRevokedNotInvalidCertificateVaccination,
                     notExpiredNotRevokedNotInvalidCertificateRecovery,
                     notExpiredNotRevokedNotInvalidCertificateRecovery2]
        let sut = self.configSut(certificates: certs)
        var boosterCandidate = BoosterCandidate(certificate: notExpiredNotRevokedNotInvalidCertificateRecovery)
        boosterCandidate.state = .new
        boosterLogicMock.boosterCandidates = [boosterCandidate]
        // WHEN
        let certViewModels = sut.certificateViewModels
        let showBadge = sut.showBadge
        
        // THEN
        XCTAssertEqual(certViewModels.count, 2)
        XCTAssertEqual(certViewModels[0].showNotification, false)
        XCTAssertEqual(certViewModels[1].showNotification, true)
        XCTAssertEqual(certViewModels[1].showNotification, showBadge)
    }
    
    func testGoToDetails() {
        // GIVEN
        let certs = [notExpiredNotRevokedNotInvalidCertificateVaccination]
        let sut = self.configSut(certificates: certs)
        
        // WHEN
        sut.showDetails()
        
        // THEN
        wait(for: [router.showCertificteExpectation], timeout: 0.1)
    }
    
    func testCloseTapped() {
        // GIVEN
        let certs = [notExpiredNotRevokedNotInvalidCertificateVaccination]
        let sut = self.configSut(certificates: certs)
        let expectation = XCTestExpectation()
        promise
            .cancelled {
                expectation.fulfill()
            }
            .cauterize()
        // WHEN
        sut.close()
        
        // THEN
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testGotoDetails_handleSceneResult_didDeleteCertificate() {
        // GIVEN
        let certs = [notExpiredNotRevokedNotInvalidCertificateVaccination]
        router.sceneResult = .didDeleteCertificate
        let sut = self.configSut(certificates: certs)
        let expectation = XCTestExpectation()
        promise
            .done{ result in
                switch result {
                case .didDeleteCertificate:
                    expectation.fulfill()
                case .showCertificatesOnOverview(_):
                    XCTFail()
                case .addNewCertificate:
                    XCTFail()
                }
            }
            .cauterize()
        // WHEN
        sut.showDetails()
        
        // THEN
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testGotoDetails_handleSceneResult_addNewCertificate() {
        // GIVEN
        let certs = [notExpiredNotRevokedNotInvalidCertificateVaccination]
        router.sceneResult = .addNewCertificate
        let sut = self.configSut(certificates: certs)
        let expectation = XCTestExpectation()
        promise
            .done{ result in
                switch result {
                case .addNewCertificate:
                    expectation.fulfill()
                case .showCertificatesOnOverview(_):
                    XCTFail()
                case .didDeleteCertificate:
                    XCTFail()
                }
            }
            .cauterize()
        // WHEN
        sut.showDetails()
        
        // THEN
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testGotoDetails_handleSceneResult_showCertificatesOnOverview() {
        // GIVEN
        let certs = [notExpiredNotRevokedNotInvalidCertificateVaccination,
                     notExpiredNotRevokedNotInvalidCertificateRecovery,
                     notExpiredNotRevokedNotInvalidCertificateTest]
        router.sceneResult = .showCertificatesOnOverview(certs.first!)
        let sut = self.configSut(certificates: certs)
        vaccinationRepository.certificates = [notExpiredNotRevokedNotInvalidCertificateVaccination]
        // WHEN
        sut.showDetails()
        
        // THEN
        wait(for: [viewModelDelegate.viewModelNeedsCertificateVisibleExpectation], timeout: 0.1)
    }
    
    func testGotoDetails_cancelled() {
        // GIVEN
        let certs = [notExpiredNotRevokedNotInvalidCertificateVaccination]
        router.sceneResultShouldCancel = true
        let sut = self.configSut(certificates: certs)
        let expectation = XCTestExpectation()
        promise
            .cancelled {
                expectation.fulfill()
            }
            .cauterize()
        // WHEN
        sut.showDetails()
        
        // THEN
        wait(for: [expectation], timeout: 0.1)
    }
}
