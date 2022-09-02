//
//  SessionManager.swift
//  download_asset
//
//  Created by design on 02.09.2022.
//

import Foundation
import AVFoundation

final internal class SessionManager: NSObject {
    //MARK: - Properties
    
    static let shared = SessionManager()
    
    internal let homeDirectoryURL = URL(fileURLWithPath: NSHomeDirectory())
    private var session: AVAssetDownloadURLSession!
    
    //MARK: - Initialization
    override private init() {
        super.init()
        let configuration = URLSessionConfiguration.background(withIdentifier: "tm.film.belet.bgSessionAsset")
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.timeoutIntervalForRequest = 120
        configuration.timeoutIntervalForResource = 120
        
        session = AVAssetDownloadURLSession(
            configuration: configuration,
            assetDownloadDelegate: self,
            delegateQueue: OperationQueue.main
        )
        
        restoreDownloadsMap()
    }
    
    private func restoreDownloadsMap() {
        print("\(#fileID) => \(#function)")
    }
}

extension SessionManager: AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard error != nil else {
            /// Download task is complete
            return
        }
        
        /// Download task fail with error
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        /// Save the destination url
        /// location.relativePath - path for saving partially downloaded data
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        /// Monitor progress
    }
}
