//
//  Constants.swift
//  download_asset
//
//  Created by design on 30.08.2022.
//

import Foundation

struct K {
    struct Tokens {
        static let access = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySWQiOjk3fQ.c3Hnysn5_aB8YLnzty-5eXEcZVLYz0Aj5lz6-wslX8g"
    }
    
    struct Fonts {
        static let mPlusRegular = "Mplus-Regular"
        static let productSansBold = "ProductSans-Bold"
        static let productSansRegular = "ProductSans-Regular"
        
        /// Roboto family
        static let robotoThin = "Roboto-Thin" // 1
        static let robotoLight = "Roboto-Light" // 2
        static let robotoMedium = "Roboto-Medium" // 3
        
        /// Vollkorn family
        static let openSansExtraBold = "OpenSans-Extrabold"
        static let openSansBold = "OpenSans-Bold"
        static let openSansRegular = "OpenSans"
        static let openSansLight = "OpenSans-Light"
    }
    
    struct Identifiers {
        /*Cells*/
        static let homeBigCellID = "HomeBigCellID"
        static let homeSmallCellID = "HomeSmallCellID"
        static let bigCellID = "BigCellID"
        static let smallCellID = "SmallCellID"
        static let homeHeaderID = "HeaderID"
        static let categoryCellID = "CategoryCellID"
        static let recomendCellID = "RecommendedCellID"
        static let tabCellID = "TabCellID"
        static let contentCellID = "ContentCellID"
        static let episodeCellID = "EpisodeCellID"
        static let favoritesCellID = "FavoritesCellID"
        static let advantageCellID = "AdvantageCellID"
        static let tagCellID = "TagCellID"
        static let movieCellID = "MovieCellID"
        static let filterCellID = "FilterCellID"
        static let downloadCellID = "downloadCellID"
        static let downloadedSerialCellID = "downloadedSerialCellID"
        static let downloadedEpisodeCellID = "downloadedEpisodeCellID"
        static let dropdownCellId = "dropdownCellID"
        static let serialHeaderID = "serialHeaderID"
        static let subscribeCellID = "subscribeCellID"
        static let subscriptionListCellID = "subscriptionListCellID"
        static let subscriptionPaymentCardCellID = "subscriptionPaymentCardCellID"
        /*Downloads*/
        static let downloadSessionID = "BeletFilmsHLSDownloadsIdentifier"
        
        //TODO: - For testing purposes only
        static let customEpisodeCellID = "CustomEpisodeCellID"
    }
}
