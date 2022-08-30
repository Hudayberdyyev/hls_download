//
//  KinoExtensions.swift
//  download_asset
//
//  Created by design on 30.08.2022.
//

import Foundation

enum DownloadingState: Int32 {
    case `downloading` = 0
    case `paused` = 1
    case `downloaded` = 2
    case `failed` = 3
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
