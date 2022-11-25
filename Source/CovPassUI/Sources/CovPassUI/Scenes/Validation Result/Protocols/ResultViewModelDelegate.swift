//
//  ResultViewModelDelegate.swift
//
//
//  Created by Thomas Kuleßa on 26.07.22.
//

public protocol ResultViewModelDelegate: AnyObject {
    func viewModelDidUpdate()
    func viewModelDidChange(_ newViewModel: ValidationResultViewModel)
}
