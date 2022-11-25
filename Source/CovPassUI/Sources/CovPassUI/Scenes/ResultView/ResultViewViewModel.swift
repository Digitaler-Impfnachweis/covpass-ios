import CovPassCommon
import PromiseKit
import UIKit

open class ResultViewViewModel: ResultViewViewModelProtocol {
    public let image: UIImage
    public let title: String
    public let description: String
    public let buttonTitle: String
    private let resolver: Resolver<Void>

    public init(image: UIImage,
                title: String,
                description: String,
                buttonTitle: String,
                resolver: Resolver<Void>) {
        self.image = image
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.resolver = resolver
    }

    public func submitTapped() {
        resolver.fulfill_()
    }
}
