import Foundation
import Keychain

public struct VaccinationFavoriteRepository: VaccinationFavoriteRepositoryProtocol {
    public init() {}

    public func get() throws -> ExtendedCBORWebToken {
        guard let data = try Keychain
            .fetchPassword(for: KeychainConfiguration.vaccinationFavoriteCertificateKey)
        else {
            throw KeychainError.fetch
        }
        let certificate = try JSONDecoder().decode(ExtendedCBORWebToken.self, from: data)
        return certificate
    }

    public func save(_ token: ExtendedCBORWebToken?) throws {
        guard let token = token else {
            try Keychain
                .deletePassword(for: KeychainConfiguration.vaccinationFavoriteCertificateKey)
            return
        }
        let data = try JSONEncoder().encode(token)
        try Keychain
            .storePassword(data, for: KeychainConfiguration.vaccinationFavoriteCertificateKey)
    }
}
