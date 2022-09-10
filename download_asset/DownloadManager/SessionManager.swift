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
}

final internal class SessionManager: NSObject {
    //MARK: - Properties
    static let shared = SessionManager()
    public var sessionManagerDelegate: SessionManagerDelegate?
    internal let homeDirectoryURL = URL(fileURLWithPath: NSHomeDirectory())
    private var session: AVAssetDownloadURLSession!
    internal var downloadingMap = [AVAssetDownloadTask: HLSObject]()
    private var cancelledDownloadTasks: [AVAssetDownloadTask] = []
    
    //MARK: - Initialization
    override private init() {
        super.init()
        initializeSession()
    }
    
    public func downloadTasksCount() {
        session.getAllTasks { tasks in
            os_log("%@ => %@ => active tasks = %@", log: OSLog.viewCycle, type: .info, #fileID, #function, String(tasks.count))
        }
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
        guard let task = session.makeAssetDownloadTask(
            asset: hlsObject.urlAsset,
            assetTitle: hlsObject.name,
            assetArtworkData: nil
//            options: [
//                AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 0
//            ]
        ) else {
            return
        }
        
//        DBServices.sharedInstance.changeDownloadingStateKinoByID(withID: Int32(hlsObject.movieId), to: .downloading)
        task.taskDescription = String(hlsObject.movieId)
        downloadingMap[task] = hlsObject
        task.resume()
    }
    
    func cancelDownload(_ hlsObject: HLSObject) {
//        DBServices.sharedInstance.changeDownloadingStateKinoByID(withID: Int32(hlsObject.movieId), to: .paused)
        if let assetDownloadTask = downloadingMap.first(where: { $1 == hlsObject })?.key {
            os_log("%@ => %@ => downloading map count before deleting = %@", log: OSLog.viewCycle, type: .info, #fileID, #function, String(downloadingMap.count))
            assetDownloadTask.cancel()
            downloadingMap.removeValue(forKey: assetDownloadTask)
            os_log("%@ => %@ => downloading map count after deleting = %@", log: OSLog.viewCycle, type: .info, #fileID, #function, String(downloadingMap.count))
        }
        
//        downloadingMap.first(where: { $1 == hlsObject })?.key.cancel()
    }
    
    func resumeDownload(_ hlsObject: HLSObject) {
        guard let assetDownloadTask = session.makeAssetDownloadTask(
            asset: hlsObject.getResumeDownloadLink(),
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
//        DBServices.sharedInstance.changeDownloadingStateKinoByID(withID: Int32(hlsObject.movieId), to: .downloading)
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
               downloadingMap[assetDownloadTask] != nil {
                /// Change downloading map state
//                downloadingMap[assetDownloadTask]!.state = .downloaded
                
                /// Notify delegate about download completed
                downloadingMap[assetDownloadTask]?.state = .downloaded
                sessionManagerDelegate?.downloadComplete(for: downloadingMap[assetDownloadTask]!)
                
                /// Change downloading state in core data
//                DBServices.sharedInstance.changeDownloadingStateKinoByID(withID: Int32(downloadingMap[assetDownloadTask]!.movieId), to: .downloaded)
                os_log("download task is complete", log: OSLog.downloads, type: .debug)
            }
            return
        }
        
        /// Download task fail with error
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        os_log("%@ => %@ => %@", log: OSLog.downloadsViewCycle, type: .info, #fileID, #function, assetDownloadTask.taskDescription ?? "unknown movie id")
        
        /// If it's cancelled download task
        if cancelledDownloadTasks.count > 0 {
            /// Set the index as not founded
            var index: Int = -1
            
            /// Iterate through cancelled tasks
            for i in 0...cancelledDownloadTasks.count-1 {
                /// If we found the element we are looking for, then save index
                if cancelledDownloadTasks[i] == assetDownloadTask { index = i}
            }
            
            /// If the element you are looking for was found then remove it
            if index != -1 { cancelledDownloadTasks.remove(at: index) }
            
            /// Save the local path on core data
            let movieId = Int32(assetDownloadTask.taskDescription ?? "0") ?? 0
            DBServices.sharedInstance.changeLocalPathKinoById(with: movieId, to: location.absoluteString)
            
            /// If cancelled tasks is empty then restore all download tasks again
            if self.cancelledDownloadTasks.count == 0 {
                os_log("all active downloads is cancelled", log: OSLog.downloads, type: .debug)
                self.allTasksIsCancelledRestartDownloads()
            }
            
            return
        }
        
        /// Save local path for movie id
        if let movieIdStr = assetDownloadTask.taskDescription,
           let movieId = Int32(movieIdStr) {
            os_log("%@ => %@ => local path changed", log: OSLog.viewCycle, type: .info, #fileID, #function)
            DBServices.sharedInstance.changeLocalPathKinoById(with: movieId, to: location.absoluteString)
        }
        
//        /// Save the destination url
//        guard let hlsObj = downloadingMap[assetDownloadTask] else {
//            return
//        }
//        hlsObj.localUrl = location
//        DBServices.sharedInstance.changeLocalPathKinoByStreamUrl(withUrl: hlsObj.urlAsset.url.absoluteString, to: location.absoluteString)
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        os_log("%@ => %@ => %@", log: OSLog.downloadsViewCycle, type: .info, #fileID, #function, assetDownloadTask.taskDescription ?? "unknown movie id")
        guard let hlsObj = downloadingMap[assetDownloadTask] else { return }
        
        /// Monitor progress
        let percentComplete = loadedTimeRanges.reduce(0.0) {
            let loadedTimeRange : CMTimeRange = $1.timeRangeValue
            return $0 + CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }
        
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
            if downloadItem.downloadingState == .notDownloaded {
                
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
                    movieId: Int(downloadItem.id)
                )
                
                /// If local path is exists then reset HLS object local url property
                if downloadItem.local_path != nil {
                    hlsObject.localUrl = URL(string: downloadItem.local_path!)
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
            /// Safe retrieve url
            guard let url = URL(string: kino.url ?? "") else {
                /// If url isn't valid then remove it from core data
                let movieId = kino.id
                DBServices.sharedInstance.deleteKinoFromDB(id: Int(movieId)) { isOk in
                    if isOk {
                        os_log("movie with id = %@ successfully removed ", log: OSLog.downloads, type: .debug, movieId)
                    } else {
                        os_log("movie with id = %@ remove fail with error", log: OSLog.downloads, type: .debug, movieId)
                    }
                }
                
                continue
            }
            /// initialize headers
            let headers: [String: String] = [
                "Authorization": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySWQiOjk3fQ.c3Hnysn5_aB8YLnzty-5eXEcZVLYz0Aj5lz6-wslX8g"
            ]
            /// initialize hls object
            let hlsObject = HLSObject(
                url: url,
                options: ["AVURLAssetHTTPHeaderFieldsKey": headers],
                name: kino.k_name ?? "",
                state: kino.downloadingState,
                thumbnailUrl: URL(string: kino.cover_url ?? ""),
                movieId: Int(kino.id)
            )
            hlsObject.localUrl = URL(string: kino.local_path ?? "")
            
            /// if current state is downloading then resume download
            let localUrl = kino.local_path ?? ""
            
            if kino.downloadingState == .notDownloaded && localUrl.count > 5 {
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
                    
                    /// cancel asset download task
                    /// add download task to cancelled download array
                    self.cancelledDownloadTasks.append(assetDownloadTask)
                    assetDownloadTask.cancel()
                }
            }
        }
        
        /// empty downloading map array
        self.downloadingMap = [:]
    }
}
