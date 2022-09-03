//
//  KinoExtensions.swift
//  download_asset
//
//  Created by design on 30.08.2022.
//

import Foundation

public enum DownloadingState: Int32 {
    case `notDownloaded` = 0
    case `downloading` = 1
    case `paused` = 2
    case `downloaded` = 3
}

extension Kino {
    var downloadingState: DownloadingState {
        /// To get a state enum from stateValue, initialize the
        /// State type from the Int32 value stateValue
        get {
            return DownloadingState(rawValue: self.downloading_state)!
        }
        
        /// New value will be of type State, thus rawValue will
        /// be an Int32 value that can be saved in Core Data
        set {
            self.downloading_state = newValue.rawValue
        }
    }
}
