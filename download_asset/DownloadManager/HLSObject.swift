//
//  HLSObject.swift
//  download_asset
//
//  Created by design on 03.09.2022.
//

import Foundation
import AVFoundation

public class HLSObject {
    enum Result {
        case success
        case failure(Error)
    }
    
    //MARK: - Properties
    /// Identifier name
    public let name: String
    /// Target AVURLAsset that have HLS URL.
    public let urlAsset: AVURLAsset
    /// Local url path that saved for offline playback. return nil if not downloaded
    public var localUrl: URL?
    /// Downloading state
    public var state: DownloadingState
    /// Thumbnail url
    public var thumbnailUrl: URL?
    public var movieId: Int
    
    internal init(
        asset: AVURLAsset,
        description: String,
        state: DownloadingState,
        thumbnailUrl: URL?,
        movieId: Int
    ) {
        self.name = description
        self.urlAsset = asset
        self.state = state
        self.thumbnailUrl = thumbnailUrl
        self.movieId = movieId
    }
    
    /// Initialize HLSObject
    ///
    /// - Parameters:
    ///   - url: HLS(m3u8) URL.
    ///   - options: AVURLAsset options.
    ///   - name: Identifier name.
    public convenience init(url: URL, options: [String: Any]? = nil, name: String, state: DownloadingState, thumbnailUrl: URL?, movieId: Int) {
        let urlAsset = AVURLAsset(url: url, options: options)
        self.init(asset: urlAsset, description: name, state: state, thumbnailUrl: thumbnailUrl, movieId: movieId)
    }
    
    /// Start Download
    public func startDownload() {
        SessionManager.shared.downloadStream(self)
    }
    
    /// Cancel download
    public func cancelDownload() {
        SessionManager.shared.cancelDownload(self)
    }
    
    /// Resume download
    public func resumeDownload() {
        SessionManager.shared.resumeDownload(self)
    }
    
    /// Get resume download link
    public func getResumeDownloadLink() -> AVURLAsset {
        
        guard let localUrl = self.localUrl
        else {
            return self.urlAsset
        }
        
        let headers: [String: String] = [
            "Authorization": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySWQiOjk3fQ.c3Hnysn5_aB8YLnzty-5eXEcZVLYz0Aj5lz6-wslX8g"
        ]
        
        let urlAsset = AVURLAsset(url: localUrl, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        
        return urlAsset
    }
}

extension HLSObject: Equatable {}

public func == (lhs: HLSObject, rhs: HLSObject) -> Bool {
    return (lhs.name == rhs.name) && (lhs.urlAsset == rhs.urlAsset)
}

extension HLSObject: CustomStringConvertible {
    public var description: String {
        return "\(name), \(urlAsset.url)"
    }
}
