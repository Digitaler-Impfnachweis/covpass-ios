//
//  CertificateHolderStatusModel.swift
//  
//
//  Created by Thomas Kuleßa on 31.08.22.
//

import Foundation

public struct CertificateHolderStatusModel: CertificateHolderStatusModelProtocol {
    private let dccCertLogic: DCCCertLogicProtocol
    private let vaccinationRepository: VaccinationRepositoryProtocol
    private var certificateList: CertificateList? {
        do {
            let certificateList = try vaccinationRepository.getCertificateList().wait()
            return certificateList
        } catch {
            return nil
        }
    }

    public init(
        dccCertLogic: DCCCertLogicProtocol,
        vaccinationRepository: VaccinationRepositoryProtocol
    ) {
        self.dccCertLogic = dccCertLogic
        self.vaccinationRepository = vaccinationRepository
    }

    public func holderNeedsMask(_ holder: Name, dateOfBirth: Date?) -> Bool {
        guard let certificateList = certificateList else { return false }
        let _ = certificateList.certificates
            .filter(by: holder, dateOfBirth: dateOfBirth)
            .filterFirstOfAllTypes
        // TODO: Do something with dccCertLogic and certificates.
        #warning("TODO: Finish implementation.")
        return false
    }

    public func holderIsFullyImmunized(_ holder: Name, dateOfBirth: Date?) -> Bool {
        guard let certificateList = certificateList else { return false }
        let _ = certificateList.certificates
            .filter(by: holder, dateOfBirth: dateOfBirth)
            .filterFirstOfAllTypes
        // TODO: Do something with dccCertLogic and certificates.
        #warning("TODO: Finish implementation.")
        return false
    }
}
