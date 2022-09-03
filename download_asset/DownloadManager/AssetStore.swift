//
//  AssetStore.swift
//  download_asset
//
//  Created by design on 03.09.2022.
//

import Foundation

internal struct AssetStore {
    private static var shared: [String: String] = {
        /// Fetch all movie list in downloads
        let filmList = DBServices.sharedInstance.getKino()
        /// Initialize empty dictionary
        var dict: [String: String] = [:]
        /// Iterate through the movie list
        for filmItem in filmList {
            /// Save retrieve localPath(value), streamUrl(key)
            if let localPath = filmItem.local_path,
               let streamUrl = filmItem.url {
                /// Update value in dictionary
                dict.updateValue(localPath, forKey: streamUrl)
            }
        }
        /// Return result
        return dict
    }()
    
    static func allMap() -> [String: String] {
        return shared
    }
    
    static func path(forKey: String) -> String? {
        if let path = shared[forKey] {
            return path
        }
        return nil
    }
    
    @discardableResult
    static func set(path: String, forKey: String) -> Bool {
        /// Update dictionary
        shared[forKey] = path
        /// Update core data
        DBServices.sharedInstance.changeLocalPathKinoByStreamUrl(withUrl: forKey, to: path)
        return true
    }
    
    
}
