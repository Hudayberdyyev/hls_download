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
    public var localUrl: URL? {
        return URL(string: AssetStore.path(forKey: urlAsset.url.absoluteString) ?? "unknown")
    }
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
}
