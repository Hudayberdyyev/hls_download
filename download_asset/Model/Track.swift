//
//  Track.swift
//  download_asset
//
//  Created by design on 30.08.2022.
//

import Foundation

/// Query service creates Track objects
class Track {
    //
    // MARK: - Constants
    
    let dbRecord: Kino
    // DBRecord.state property
    /// 0 - film
    /// 1 - serial
    
    let index: Int
    let name: String
    let previewURL: URL
    var episodeCount: Int = 0
    //
    // MARK: - Variables And Properties
    //
    var downloaded = false
    //
    // MARK: - Initialization
    //
    init(name: String, dbRecord: Kino, previewURL: URL, index: Int) {
        self.name = name
        self.dbRecord = dbRecord
        self.previewURL = previewURL
        self.index = index
    }
    
    public func downloadPaused() {
        print("\(#fileID) => \(#function)")
        self.dbRecord.downloadingState = .paused
        do {
            try DBServices.sharedInstance.saveContext()
        } catch {
            print(error.localizedDescription)
        }
    }
}
