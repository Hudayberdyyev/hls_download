//
//  SessionManager.swift
//  download_asset
//
//  Created by design on 02.09.2022.
//

import Foundation
import AVFoundation

protocol SessionManagerDelegate {
//    func updateProgress(for downloadItem: Download, with progress: Double, total size: Int64)
//    func downloadFinishedSuccessfully(streamUrl url: URL, for downloadItem: Download, with location: URL)
//    func downloadFailWithError(for downloadItem: Download)
//    func notAvailableSpace(for downloadItem: Download)
    
    func updateProgress(for hlsObj: HLSObject, with progress: Double)
    func downloadComplete(for hlsObj: HLSObject)
}

final internal class SessionManager: NSObject {
    //MARK: - Properties
    
    static let shared = SessionManager()
    public var sessionManagerDelegate: SessionManagerDelegate?
    internal let homeDirectoryURL = URL(fileURLWithPath: NSHomeDirectory())
    private var session: AVAssetDownloadURLSession!
    internal var downloadingMap = [AVAssetDownloadTask: HLSObject]()
    
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
    
    func downloadStream(_ hlsObject: HLSObject) {
        guard let task = session.makeAssetDownloadTask(
            asset: hlsObject.urlAsset,
            assetTitle: hlsObject.name,
            assetArtworkData: nil,
            options: [
                AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 0
            ]
        ) else {
            return
        }
                
        task.taskDescription = hlsObject.name
        downloadingMap[task] = hlsObject
        task.resume()
    }
    
    func cancelDownload(_ hlsObject: HLSObject) {
        downloadingMap.first(where: { $1 == hlsObject })?.key.cancel()
    }
    
    func resumeDownload(_ hlsObject: HLSObject) {
        guard let task = session.makeAssetDownloadTask(
            asset: hlsObject.getResumeDownloadLink(),
            assetTitle: hlsObject.name,
            assetArtworkData: nil,
            options: [
                AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 0
            ]
        ) else {
            print("resume download failed")
            return
        }
        
        print("resume download success")
        task.taskDescription = hlsObject.name
        downloadingMap[task] = hlsObject
        task.resume()
    }
}

extension SessionManager: AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("\(#fileID) => \(#function) => \((task as! AVAssetDownloadTask).urlAsset.url.absoluteString)")
        guard error != nil else {
            /// Download task is complete
            if let assetDownloadTask = task as? AVAssetDownloadTask,
               downloadingMap[assetDownloadTask] != nil {
                downloadingMap[assetDownloadTask]!.state = .downloaded
                sessionManagerDelegate?.downloadComplete(for: downloadingMap[assetDownloadTask]!)
            }
            return
        }
        
        /// Download task fail with error
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        print("\(#fileID) => \(#function) => \(assetDownloadTask.urlAsset.url.absoluteString)")
        /// Save the destination url
        guard let hlsObj = downloadingMap[assetDownloadTask] else {
            return
        }
        hlsObj.localUrl = location
        DBServices.sharedInstance.changeLocalPathKinoByStreamUrl(withUrl: hlsObj.urlAsset.url.absoluteString, to: location.absoluteString)
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        print("\(#fileID) => \(#function) => \(assetDownloadTask.urlAsset.url.absoluteString)")
        guard let hlsObj = downloadingMap[assetDownloadTask] else { return }
        /// Monitor progress
        let percentComplete = loadedTimeRanges.reduce(0.0) {
            let loadedTimeRange : CMTimeRange = $1.timeRangeValue
            return $0 + CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }
        
        sessionManagerDelegate?.updateProgress(for: hlsObj, with: percentComplete)
    }
}
