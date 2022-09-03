//
//  UIButtonExt.swift
//  download_asset
//
//  Created by design on 03.09.2022.
//

import UIKit

extension UIButton {
    public func enableButton() {
        self.isUserInteractionEnabled = true
        self.isHidden = false
    }
    
    public func disableButton() {
        self.isUserInteractionEnabled = false
        self.isHidden = true
    }
}
