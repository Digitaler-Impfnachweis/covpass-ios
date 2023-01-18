import CovPassCommon
import PromiseKit
import UIKit

open class ResultViewViewModel: ResultViewViewModelProtocol {
    public let image: UIImage
    public let title: String
    public let description: String
    public let buttonTitle: String
    public var shareButtonTitle: String?
    private let resolver: Resolver<Void>
    private let router: ResultViewRouterProtocol?
    private let certificate: ExtendedCBORWebToken?

    public init(image: UIImage,
                title: String,
                description: String,
                buttonTitle: String,
                shareButtonTitle: String?,
                resolver: Resolver<Void>,
                router: ResultViewRouterProtocol?,
                certificate: ExtendedCBORWebToken?) {
        self.image = image
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.shareButtonTitle = shareButtonTitle
        self.resolver = resolver
        self.router = router
        self.certificate = certificate
    }

    public func submitTapped() {
        resolver.fulfill_()
    }

    public func shareAsPdf() {
        guard let certificate = certificate else {
            return
        }
        router?.showPDFExport(for: certificate)
            .done(submitTapped)
            .cauterize()
    }
}
