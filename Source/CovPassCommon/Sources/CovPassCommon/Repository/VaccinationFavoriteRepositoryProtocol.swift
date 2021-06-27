import Foundation
import Keychain
import PromiseKit

public protocol VaccinationFavoriteRepositoryProtocol {
    /// Return the vaccination favorite certificate
    func get() throws -> ExtendedCBORWebToken

    /// Save the vaccination favorite certificate
    func save(_ token: ExtendedCBORWebToken?) throws
}
