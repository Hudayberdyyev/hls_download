//
//  BaseCell.swift
//  download_asset
//
//  Created by design on 30.08.2022.
//

import UIKit

class BaseCell: UICollectionViewCell {
    
    //MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - View methods
    public func setupViews() {
        
    }
}
