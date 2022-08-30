//
//  FontSizes.swift
//  download_asset
//
//  Created by design on 30.08.2022.
//

import UIKit

/// Global properties
public let maxDimensionValue: CGFloat = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
public let minDimensionValue: CGFloat = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)

struct F {
    
    struct DownloadFontGroup {
        /// Calculate title font, minimum possible value 14
        static let titleFont = UIFont(name: K.Fonts.productSansBold, size: max(maxDimensionValue / 57, 14))
        
        /// Calculate description font, minimum possible value 12
        static let descFont = UIFont(name: K.Fonts.productSansBold, size: max(maxDimensionValue / 66, 12))
        
        /// Calculate season title font, minimum possible value 16
        static let seasonTitleFont = UIFont(name: K.Fonts.productSansBold, size: max(maxDimensionValue / 46, 16))
    }
    
    struct NavigationBarFontGroup {
        /// Calculate navigation title font, minimum possible value 14
        static let titleFont = UIFont(name: K.Fonts.productSansBold, size: max(maxDimensionValue / 46, 16))
    }
    
    struct SubscriptionGroup {
        /// Calculate subscription cancel button font
        static let cancelButtonFont = UIFont(name: K.Fonts.robotoMedium, size: max(maxDimensionValue / 52, 16))
        
        static let sectionTitleFont = UIFont(name: K.Fonts.openSansRegular, size: max(maxDimensionValue / 65, 12))
        
        static let sectionDescFont = UIFont(name: K.Fonts.openSansRegular, size: max(maxDimensionValue / 65, 12))
        
        static let sectionHeaderTitleFont = UIFont(name: K.Fonts.openSansRegular, size: max(maxDimensionValue / 64, 13))
        
        static let sectionHeaderDescFont = UIFont(name: K.Fonts.openSansRegular, size: max(maxDimensionValue / 64, 13))
        
        static let subscribeButtonFont = UIFont(name: K.Fonts.robotoMedium, size: max(maxDimensionValue / 52, 16))
        
        static let subscriptionListItemFont = UIFont(name: K.Fonts.robotoMedium, size: max(maxDimensionValue / 42, 20))
        
        static let subscriptionListTitleFont = UIFont(name: K.Fonts.robotoMedium, size: max(maxDimensionValue / 35, 22))
        
        static let paymentPolicyFont = UIFont(name: K.Fonts.robotoMedium, size: max(maxDimensionValue / 46, 16))
        
        static let paymentFinishTitleFont = UIFont(name: K.Fonts.robotoMedium, size: max(minDimensionValue / 25, 15))
        
        static let paymentFinishButtonFont = UIFont(name: K.Fonts.robotoMedium, size: max(minDimensionValue / 28, 13))
        
        static let paymentFinishDescFont = UIFont(name: K.Fonts.robotoMedium, size: max(minDimensionValue / 28, 13))
    }
}

