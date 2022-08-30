//
//  Download.swift
//  download_asset
//
//  Created by design on 30.08.2022.
//

import Foundation
import AVFoundation

class Download {
    var isDownloading = false
    var progress: Double = 0
    var resumeData: Data?
    var task: URLSessionDownloadTask?
    var track: Track
    
    init(track: Track) {
        self.track = track
    }
    
    public func downloadPaused() {
        self.track.downloadPaused()
    }
}
