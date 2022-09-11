//
//  SessionManager.swift
//  download_asset
//
//  Created by design on 02.09.2022.
//

import Foundation
import AVFoundation
import os.log
import CloudKit

protocol SessionManagerDelegate {
//    func updateProgress(for downloadItem: Download, with progress: Double, total size: Int64)
//    func downloadFinishedSuccessfully(streamUrl url: URL, for downloadItem: Download, with location: URL)
//    func downloadFailWithError(for downloadItem: Download)
//    func notAvailableSpace(for downloadItem: Download)
    
    func updateProgress(for hlsObj: HLSObject, with progress: Double)
    func downloadComplete(for hlsObj: HLSObject)
    func locationCaptured(forMovie id: Int, to location: String)
    func updateView(for movieId: Int32)
}

final internal class SessionManager: NSObject {
    //MARK: - Properties
    static let shared = SessionManager()
    public var sessionManagerDelegate: SessionManagerDelegate?
    internal let homeDirectoryURL = URL(fileURLWithPath: NSHomeDirectory())
    private var session: AVAssetDownloadURLSession!
    internal var downloadingMap = [AVAssetDownloadTask: HLSObject]()
    private var cancelledDownloadTasks: [AVAssetDownloadTask] = []
    private let cancelled = "cancelled"
    
    //MARK: - Initialization
    override private init() {
        super.init()
        initializeSession()
    }
    
    public func getDownloadTaskIndex(_ hlsObject: HLSObject) -> Int {
        var currentIndex = 0
        for downloadMapItem in downloadingMap {
            if downloadMapItem.value == hlsObject {
                return currentIndex
            }
            currentIndex += 1
        }
        return -1
    }
    
    private func initializeSession() {
        os_log("%@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function)
        let configuration = URLSessionConfiguration.background(withIdentifier: "tm.film.belet.bgSessionAsset")
        session = AVAssetDownloadURLSession(
            configuration: configuration,
            assetDownloadDelegate: self,
            delegateQueue: OperationQueue.main
        )
    }
    
    func downloadStream(_ hlsObject: HLSObject) {
        guard
            let urlAsset = hlsObject.urlAsset,
            let task = session.makeAssetDownloadTask(
            asset: urlAsset,
            assetTitle: hlsObject.name,
            assetArtworkData: nil
//            options: [
//                AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 0
//            ]
        ) else {
            return
        }
        
        DBServices.sharedInstance.changeDownloadingStateKinoByID(withID: Int32(hlsObject.movieId), to: .downloading)
        task.taskDescription = String(hlsObject.movieId)
        downloadingMap[task] = hlsObject
        task.resume()
    }
    
    func cancelDownload(_ hlsObject: HLSObject) {
        /// Safely retrieve asset download task
        if let assetDownloadTask = downloadingMap.first(where: { $1 == hlsObject })?.key {
            
            /// Cancel download task
            assetDownloadTask.cancel()
            
            /// Remove download task from downloading map
            downloadingMap.removeValue(forKey: assetDownloadTask)
            
            /// Change downloading state to core data
            DBServices.sharedInstance.changeDownloadingStateAndProgressByMovieId(withID: Int32(hlsObject.movieId), toState: .paused, toProgress: hlsObject.progress)
        }
    }
    
    func resumeDownload(_ hlsObject: HLSObject) {
        guard let resumeDownloadLink = hlsObject.getResumeDownloadLink(),
              let assetDownloadTask = session.makeAssetDownloadTask(
                asset: resumeDownloadLink,
                assetTitle: hlsObject.name,
                assetArtworkData: nil,
                options: [
                    AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 0
                ]
        ) else {
            os_log("%@ => %@ => %@ => failed", log: OSLog.downloads, type: .debug, #fileID, #function, String(hlsObject.movieId))
            return
        }
        os_log("%@ => %@ => %@ => success", log: OSLog.downloads, type: .debug, #fileID, #function, String(hlsObject.movieId))
        DBServices.sharedInstance.changeDownloadingStateKinoByID(withID: Int32(hlsObject.movieId), to: .downloading)
        assetDownloadTask.taskDescription = String(hlsObject.movieId)
        downloadingMap[assetDownloadTask] = hlsObject
        assetDownloadTask.resume()
    }
}

extension SessionManager: AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        /// Try to loggin error
        if let assetDownloadTask = task as? AVAssetDownloadTask {
            os_log("%@ => %@ => %@ => %@", log: OSLog.downloadsViewCycle, type: .info, #fileID, #function, assetDownloadTask.taskDescription ?? "unknown movie id", error?.localizedDescription ?? "nil")
        }
        
        guard error != nil else {
            /// Download task is complete
            if let assetDownloadTask = task as? AVAssetDownloadTask,
               let taskDescription = assetDownloadTask.taskDescription,
               let movieId = Int(taskDescription),
               let kino = DBServices.sharedInstance.getKinoByID(id: movieId)
            {
                let hlsObj = HLSObject(kino: kino)
                
                /// Change hls object download state
                hlsObj.state = .downloaded
                
                /// Notify delegate about download completed
                sessionManagerDelegate?.downloadComplete(for: hlsObj)
                downloadingMap.removeValue(forKey: assetDownloadTask)
                
                /// Change downloading state in core data
                DBServices.sharedInstance.changeDownloadingStateKinoByID(withID: Int32(hlsObj.movieId), to: .downloaded)
                
                os_log("Download complete => %@", log: OSLog.downloads, type: .debug, String(hlsObj.movieId))
            }
            return
        }
        
        /// Download task fail with error
        /// If task is canceled then just skip it, else save error state
        if error?.localizedDescription != self.cancelled,
           let assetDownloadTask = task as? AVAssetDownloadTask,
           let movieId = Int32(assetDownloadTask.taskDescription ?? "")
        {
            /// Change state to not downloaded
            DBServices.sharedInstance.changeDownloadingStateKinoByID(withID: movieId, to: .notDownloaded)
            
            /// Remove from downloading map
            downloadingMap.removeValue(forKey: assetDownloadTask)
            
            /// Reload download view
            sessionManagerDelegate?.updateView(for: movieId)
        }
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        os_log("%@ => %@ => %@", log: OSLog.downloadsViewCycle, type: .info, #fileID, #function, assetDownloadTask.taskDescription ?? "unknown movie id")
        
        let localPath: String = location.relativePath
        
        /// If it's cancelled download task
        if cancelledDownloadTasks.count > 0 {
            /// Set the index as not founded
            var index: Int = -1
            
            /// Iterate through cancelled tasks
            for i in 0...cancelledDownloadTasks.count-1 {
                /// If we found the element we are looking for, then save index
                if cancelledDownloadTasks[i] == assetDownloadTask { index = i }
            }
            
            /// If the element you are looking for was found then remove it
            if index != -1 { cancelledDownloadTasks.remove(at: index) }
            
            /// Save the local path on core data
            let movieId = Int(assetDownloadTask.taskDescription ?? "0") ?? 0
            DBServices.sharedInstance.changeLocalPathKinoById(with: movieId, to: localPath)
            
            /// If cancelled tasks is empty then restore all download tasks again
            if self.cancelledDownloadTasks.count == 0 {
                os_log("all active downloads is cancelled", log: OSLog.downloads, type: .debug)
                self.allTasksIsCancelledRestartDownloads()
            }
            
            return
        }
        
        /// Save local path for movie id
        if let movieIdStr = assetDownloadTask.taskDescription,
           let movieId = Int(movieIdStr) {
            os_log("%@ => %@ => local path changed", log: OSLog.viewCycle, type: .info, #fileID, #function)
            DBServices.sharedInstance.changeLocalPathKinoById(with: movieId, to: localPath)
            sessionManagerDelegate?.locationCaptured(forMovie: movieId, to: localPath)
        }
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        os_log("%@ => %@ => %@", log: OSLog.downloadsViewCycle, type: .info, #fileID, #function, assetDownloadTask.taskDescription ?? "unknown movie id")
        
        /// Save retrieve hls object
        guard let hlsObj = downloadingMap[assetDownloadTask] else { return }
        
        /// Monitor progress
        let percentComplete = loadedTimeRanges.reduce(0.0) {
            let loadedTimeRange : CMTimeRange = $1.timeRangeValue
            return $0 + CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }
        
        /// Change hls object progress property
        hlsObj.progress = percentComplete
        
        /// Notify session manager delegate
        sessionManagerDelegate?.updateProgress(for: hlsObj, with: percentComplete)
    }
}

//MARK: - Force quit, handler methods
extension SessionManager {
    public func cancelAllTasks() {
        os_log("%@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function)
        
        self.session.getAllTasks { tasks in
            os_log("%@ => %@ => active tasks count = %@", log: OSLog.viewCycle, type: .info, #fileID, #function, String(tasks.count))
            for task in tasks {
                if let assetDownloadTask = task as? AVAssetDownloadTask {
                    assetDownloadTask.cancel()
                }
            }
        }
        
    }
    
    public func restoreDownloadTasksFromCoreData() {
        os_log("%@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function)
        
        /// Retrieve downloads list from core data
        let downloadsList = DBServices.sharedInstance.getKino()
        
        /// Iterate through downloads list
        for downloadItem in downloadsList {
            /// If current item is not downloaded then start download, by created hls object
            if downloadItem.downloadingState == .notDownloaded,
               downloadItem.local_path != nil && downloadItem.local_path?.count ?? 0 > 5
            {
                
                /// Safe retrieve stream url
                guard let url = URL(string: downloadItem.url ?? "") else {
                    /// Remove this movie from core data
                    let movieId = downloadItem.id
                    DBServices.sharedInstance.deleteKinoFromDB(id: Int(movieId)) { isOk in }
                    continue
                }
                
                
                /// Initialize HLS object
                let headers: [String: String] = [
                    "Authorization": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySWQiOjk3fQ.c3Hnysn5_aB8YLnzty-5eXEcZVLYz0Aj5lz6-wslX8g"
                ]
                
                let hlsObject = HLSObject(
                    url: url,
                    options: ["AVURLAssetHTTPHeaderFieldsKey": headers],
                    name: downloadItem.k_name ?? "",
                    state: downloadItem.downloadingState,
                    thumbnailUrl: URL(string: downloadItem.cover_url ?? ""),
                    movieId: Int(downloadItem.id),
                    progress: downloadItem.progress
                )
                
                /// If local path is exists then reset HLS object local url property
                if downloadItem.local_path != nil {
                    hlsObject.localUrl = downloadItem.local_path
                }
                
                hlsObject.resumeDownload()
            }
        }
    }
}

//MARK: - Background mode, handler methods
extension SessionManager {
    private func allTasksIsCancelledRestartDownloads() {
        os_log("%@ => %@", log: OSLog.downloadsViewCycle, type: .info, #fileID, #function)
        
        /// Retrieve films from core data
        let downloadsList = DBServices.sharedInstance.getKino()
        
        for kino in downloadsList {
            let hlsObject = HLSObject(kino: kino)
            
            if hlsObject.urlAsset == nil {
                DBServices.sharedInstance.deleteKinoFromDB(id: hlsObject.movieId) { isOk in }
                continue
            }
            
            if kino.downloadingState == .downloading {
                hlsObject.resumeDownload()
            }
        }
    }
    
    public func restoreDownloadsMap() {
        os_log("%@ => %@", log: OSLog.downloadsViewCycle, type: .info, #fileID, #function)
        
        initializeSession()
        
        /// cancel all active tasks
        self.session.getAllTasks { tasks in
            os_log("%@ => %@ => %@", log: OSLog.downloads, type: .info, #fileID, #function, String(tasks.count))
            for task in tasks {
                if let assetDownloadTask = task as? AVAssetDownloadTask {
                    /// Cancel asset download task
                    /// Add download task to cancelled download array
                    self.cancelledDownloadTasks.append(assetDownloadTask)
                    assetDownloadTask.cancel()
                }
            }
        }
        
        /// Empty downloading map array
        self.downloadingMap = [:]
    }
}
