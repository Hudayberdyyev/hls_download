//
//  UIImageExt.swift
//  download_asset
//
//  Created by design on 30.08.2022.
//

import UIKit

extension UIImage {
    func resizeImage(toSize size: CGSize = CGSize(width: 50, height: 50)) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
