//
//  OSLogExt.swift
//  download_asset
//
//  Created by design on 05.09.2022.
//

import os.log
import Foundation

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// Categories
    static let viewCycleCategory = "viewCycle"
    static let downloadsCategory = "downloads"
    static let didEnterForegroundCategory = "didEnterForeground"
    /// Subsystems
    static let downloadsSubsystem = "downloads"
    
    /// Logs the view cycles like viewDidLoad
    static let viewCycle = OSLog(subsystem: subsystem, category: OSLog.viewCycleCategory)
    static let downloadsViewCycle = OSLog(subsystem: OSLog.downloadsSubsystem, category: OSLog.viewCycleCategory)
    
    /// Logs the downloads
    static let downloads = OSLog(subsystem: subsystem, category: OSLog.downloadsCategory)
    
    /// Logs of the didEnterForeground
    static let didEnterForeground = OSLog(subsystem: subsystem, category: OSLog.didEnterForegroundCategory)
}
