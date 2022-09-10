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
    public var localUrl: String?
    /// Downloading state
    public var state: DownloadingState
    /// Thumbnail url
    public var thumbnailUrl: URL?
    public var movieId: Int
    public var progress: Double?
    
    internal init(
        asset: AVURLAsset,
        description: String,
        state: DownloadingState,
        thumbnailUrl: URL?,
        movieId: Int,
        progress: Double?
    ) {
        self.name = description
        self.urlAsset = asset
        self.state = state
        self.thumbnailUrl = thumbnailUrl
        self.movieId = movieId
        self.progress = progress
    }
    
    /// Initialize HLSObject
    ///
    /// - Parameters:
    ///   - url: HLS(m3u8) URL.
    ///   - options: AVURLAsset options.
    ///   - name: Identifier name.
    public convenience init(
        url: URL,
        options: [String: Any]? = nil,
        name: String,
        state: DownloadingState,
        thumbnailUrl: URL?,
        movieId: Int,
        progress: Double?
    ) {
        let urlAsset = AVURLAsset(url: url, options: options)
        self.init(
            asset: urlAsset,
            description: name,
            state: state,
            thumbnailUrl: thumbnailUrl,
            movieId: movieId,
            progress: progress
        )
    }
    
    /// Start Download
    public func startDownload() {
        self.state = .downloading
        SessionManager.shared.downloadStream(self)
    }
    
    /// Cancel download
    public func cancelDownload() {
        self.state = .paused
        SessionManager.shared.cancelDownload(self)
    }
    
    /// Resume download
    public func resumeDownload() {
        self.state = .downloading
        SessionManager.shared.resumeDownload(self)
    }
    
    private func makeUrlAssetWithCredentials(url: URL) -> AVURLAsset {
        /// Retrieve valid token
        let headers: [String: String] = [
            "Authorization": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySWQiOjk3fQ.c3Hnysn5_aB8YLnzty-5eXEcZVLYz0Aj5lz6-wslX8g"
        ]
        
        /// Create url asset and return it
        let urlAsset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        
        return urlAsset
    }
    
    /// Get resume download link
    public func getResumeDownloadLink() -> AVURLAsset {
        
        /// Safe retrieve local url, else return urlAsset
        guard let localUrl = self.localUrl,
              let urlEncodedLocalUrl = localUrl.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let absoluteLocalURL = URL(string: urlEncodedLocalUrl, relativeTo: SessionManager.shared.homeDirectoryURL)
        else {
            return self.makeUrlAssetWithCredentials(url: self.urlAsset.url)
        }
        /// Return url asset with credentials
        return self.makeUrlAssetWithCredentials(url: absoluteLocalURL)
    }
}

extension HLSObject: Equatable {}

public func == (lhs: HLSObject, rhs: HLSObject) -> Bool {
    return (lhs.name == rhs.name) && (lhs.movieId == rhs.movieId)
}

extension HLSObject: CustomStringConvertible {
    public var description: String {
        return "\(name), \(urlAsset.url)"
    }
}

