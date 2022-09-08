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
        
        //TODO: - Should be restore downloads map
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
    
    public func restoreDownloadsMap() {
        os_log("%@ => %@", log: OSLog.downloadsViewCycle, type: .info, #fileID, #function)
        os_log("%@ => %@", log: OSLog.didEnterForeground, type: .debug, #fileID, #function)
        
        initializeSession()
        
            /// cancel all active tasks
        self.session.getAllTasks { tasks in
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
        
        
        /*
        session.getAllTasks { tasks in
            for task in tasks {
                if let assetDownloadTask = task as? AVAssetDownloadTask {
                    /// restore progress indicators, state, etc ...
                    if let movieId = Int(assetDownloadTask.taskDescription ?? "") {
                        /// get movie record from core data, by movieId
                        let movieData = DBServices.sharedInstance.getKinoByID(id: movieId)
                        
                        if  let kino = movieData,
                            let url = URL(string: kino.url ?? "") {
                            /// initialize authorization header
                            let headers: [String: String] = [
                                "Authorization": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySWQiOjk3fQ.c3Hnysn5_aB8YLnzty-5eXEcZVLYz0Aj5lz6-wslX8g"
                            ]
                            
                            /// create hls object
                            let hlsObject = HLSObject(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers], name: kino.k_name ?? "", state: kino.downloadingState, thumbnailUrl: URL(string: kino.cover_url ?? ""), movieId: movieId)
                            
                            /// resume download task
                            assetDownloadTask.resume()
                            
                            /// reset downloading map
                            self.downloadingMap[assetDownloadTask] = hlsObject
                            print("Restore download: \(movieId) has been restored")
                            
                            /// skip to next task
                            continue
                        }
                        print("Restore download: \(movieId) hasn't been restored, cause no such item with this movieId, or invalid stream url")
                        
                        /// skip to next task
                        continue
                    }
                    print("Restore download: empty task description")
                }
            }
        }
         */
    }
    
    private func allTasksIsCancelledRestartDownloads() {
        os_log("%@ => %@", log: OSLog.downloadsViewCycle, type: .info, #fileID, #function)
        os_log("%@ => %@", log: OSLog.didEnterForeground, type: .debug, #fileID, #function)
        
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
            if kino.downloadingState == .notDownloaded && localUrl.count > 5
            {
                hlsObject.resumeDownload()
            }
        }
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
        downloadingMap.first(where: { $1 == hlsObject })?.key.cancel()
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
            os_log("%@ => %@ => %@ => failed", log: OSLog.didEnterForeground, type: .debug, #fileID, #function, String(hlsObject.movieId))
            return
        }
        os_log("%@ => %@ => %@ => success", log: OSLog.didEnterForeground, type: .debug, #fileID, #function, String(hlsObject.movieId))
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
            os_log("%@ => %@ => %@", log: OSLog.downloadsViewCycle, type: .info, #fileID, #function, assetDownloadTask.taskDescription ?? "unknown movie id")
            os_log("%@ => %@ => %@", log: OSLog.didEnterForeground, type: .debug, #fileID, #function, assetDownloadTask.taskDescription ?? "unknown movie id")
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
        /// Check if it's restored download task
        os_log("%@ => %@", log: OSLog.didEnterForeground, type: .debug, #fileID, #function)
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
                os_log("%@ => %@ => all active downloads is cancelled", log: OSLog.didEnterForeground, type: .debug, #fileID, #function)
                self.allTasksIsCancelledRestartDownloads()
            }
            
            return
        }
        
        /// Save the destination url
        guard let hlsObj = downloadingMap[assetDownloadTask] else {
            return
        }
        hlsObj.localUrl = location
        DBServices.sharedInstance.changeLocalPathKinoByStreamUrl(withUrl: hlsObj.urlAsset.url.absoluteString, to: location.absoluteString)
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

extension SessionManager: AVAssetResourceLoaderDelegate {
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        os_log("%@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function)
        return true
    }
}
