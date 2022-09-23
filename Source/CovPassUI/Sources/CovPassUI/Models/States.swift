//
//  States.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

public enum States {
    
    private static let states = ["DE_BY","DE_BB","DE_BE","DE_BW","DE_HB","DE_HH","DE_HE","DE_MV","DE_NI","DE_NW","DE_RP","DE_SN","DE_ST","DE_SL","DE_SH","DE_TH"]

    public static var load: [Country] { states.map{Country($0)}}
}
