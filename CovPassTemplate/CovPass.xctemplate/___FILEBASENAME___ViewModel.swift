import Foundation
import PromiseKit
import CovPassUI

class ___VARIABLE_moduleName___ViewModel: ___VARIABLE_moduleName___ViewModelProtocol {
    
    // MARK: - Properties
    weak var delegate: ViewModelDelegate?
    private let resolver: Resolver<Void>?
    private let router: ___VARIABLE_moduleName___RouterProtocol?

    
    // MARK: - Lifecyle
    
    init(router: ___VARIABLE_moduleName___RouterProtocol,
         resolver: Resolver<Void>) {
        self.router = router
        self.resolver = resolver
    }
    
    // MARK: - Methods
    
}
