//
//  IconNames.swift
//  download_asset
//
//  Created by design on 30.08.2022.
//

import UIKit

enum Icon: String {
    case Bookmark
    case Play
    case Download
    case path4
    case DownloadEpisode
    case LeftArrow
    case Forward1
    case Pencil1
    case Remove1
    case Close1
    case Icon1
    case Cancel1
    case Success1
    case Refresh1
    
    func image(selected: Bool = false) -> UIImage {
        return UIImage(named: selected ? (self.rawValue+"-selected") : self.rawValue)!
    }
    
    func originalImage(selected: Bool = false) -> UIImage? {
        return UIImage(named: selected ? (self.rawValue+"-selected") : self.rawValue)?.withRenderingMode(.alwaysTemplate)
    }
}
