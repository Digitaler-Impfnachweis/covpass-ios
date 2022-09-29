//
//  States.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

public enum States {
    
    private static let states = ["BY","BB","BE","BW","HB","HH","HE","MV","NI","NW","RP","SN","ST","SL","SH","TH"]

    public static var load: [Country] { states.map{Country($0)}}
}
