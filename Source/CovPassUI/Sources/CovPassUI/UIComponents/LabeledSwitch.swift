//
//  LabeledSwitch.swift
//  
//
//  Created by Fatih Karakurt on 03.03.22.
//

import UIKit

public class LabeledSwitch: XibView {
    @IBOutlet public var label: UILabel!
    @IBOutlet public var uiSwitch: UISwitch!
    public var switchChanged: ((Bool) -> Void)? = nil
    
    public override func initView() {
        super.initView()
        contentView?.backgroundColor = .white
        uiSwitch.tintColor = .backgroundSecondary
        uiSwitch.layer.cornerRadius = uiSwitch.frame.height / 2.0
        uiSwitch.backgroundColor = .backgroundSecondary
        uiSwitch.clipsToBounds = true
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        switchChanged?(sender.isOn)
    }
}
