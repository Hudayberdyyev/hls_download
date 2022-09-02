//
//  DownloadCell.swift
//  download_asset
//
//  Created by design on 30.08.2022.
//

import UIKit
import SkeletonView
import UICircularProgressRing
import SnapKit

protocol TrackCellDelegate {
    func cancelTapped(_ cell: DownloadCell)
    func downloadTapped(_ cell: DownloadCell)
    func pauseTapped(_ cell: DownloadCell)
    func resumeTapped(_ cell: DownloadCell)
    func deleteKinoTapped(_ cell: DownloadCell)
}

protocol EditDownloadsDelegate {
    func forwardOrEditButtonTapped(on baseCell: UICollectionViewCell)
}


class DownloadCell: BaseCell {
    
    var delegate: TrackCellDelegate?
    var editDelegate: EditDownloadsDelegate?
    
    let titleLabel:UILabel = {
        let label = UILabel()
        label.font = F.DownloadFontGroup.titleFont
        label.text = "kname"
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let durationLabel:UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .lightGray
        label.font = F.DownloadFontGroup.descFont
        return label
    }()
    
    let pauseButton:UIButton = {
        let bt = UIButton()
        bt.setTitle("", for: .normal)
        bt.setImage(UIImage(named: "round_pause_black_48")?.withRenderingMode(.alwaysTemplate), for: .normal)
        bt.isHidden = true
        bt.isUserInteractionEnabled = false
        return bt
    }()
    
    let downloadButton:UIButton = {
        let bt = UIButton()
        bt.setTitle("", for: .normal)
        bt.setImage(UIImage(named: "round_play_arrow_black_48")?.withRenderingMode(.alwaysTemplate), for: .normal)
        bt.isUserInteractionEnabled = false
        return bt
    }()
    
    let refreshButton:UIButton = {
        let bt = UIButton()
        bt.setTitle("", for: .normal)
        bt.setImage(Icon.Refresh1.image().withRenderingMode(.alwaysTemplate), for: .normal)
        return bt
    }()
    
    let resumeButton:UIButton = {
        let bt = UIButton()
        bt.setTitle("", for: .normal)
        bt.setImage(UIImage(named: "round_play_arrow_black_48")?.withRenderingMode(.alwaysTemplate), for: .normal)
        bt.isUserInteractionEnabled = false
        bt.isHidden = true
        return bt
    }()
    
    lazy var progressView2: UICircularProgressRing = {
        let pv = UICircularProgressRing()
        pv.outerRingColor = .clear
        pv.innerRingColor = .systemBlue
        pv.fontColor = .white
        pv.backgroundColor = .black
        pv.outerRingColor = .black
        pv.tintColor = .white
        pv.clipsToBounds = true
        pv.layer.cornerRadius = 10
        pv.outerRingWidth = 0
        pv.innerRingWidth = 7
        return pv
    }()
    
    private lazy var removeButton: UIButton = {
        
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = .black
        b.contentMode = .scaleAspectFit
        
        /// Set image
        b.imageView?.tintColor = .lightGray
        b.imageView?.contentMode = .scaleAspectFit
        
        let image = Icon.Remove1.image().resizeImage(toSize: CGSize(width: 30, height: 30))
        b.setImage(image, for: .normal)
        
        b.addTarget(self, action: #selector(removeButtonTapped(_:)), for: .touchUpInside)
        return b
    }()
    
    let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "0 MB"
        label.textColor = .lightGray
        label.font = F.DownloadFontGroup.descFont
        return label
    }()
    
    let coverImage:UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 5
        image.backgroundColor = .black
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override func setupViews() {
        
        
        self.addSubview(coverImage)
        coverImage.backgroundColor = .darkClouds
        
        self.addSubview(titleLabel)
        self.addSubview(durationLabel)
        self.addSubview(progressLabel)
        
        self.backgroundColor = .black
        
        self.contentView.addSubview(progressView2)
        self.contentView.addSubview(downloadButton)
        self.contentView.addSubview(pauseButton)
        self.contentView.addSubview(resumeButton)
        self.contentView.addSubview(refreshButton)
        
//        coverImage.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 8, left: 12, bottom: 4, right: 12))
        
//        let coverImageHeightConstant: CGFloat = self.frame.height - 12.0
        coverImage.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(8)
            make.bottom.equalTo(self).offset(-4)
            make.leading.equalTo(self).offset(12)
            make.width.equalTo(coverImage.snp.height).multipliedBy(854.0/480.0)
        }
        
        titleLabel.anchor(top: self.topAnchor, leading: coverImage.trailingAnchor, bottom: durationLabel.topAnchor, trailing: progressView2.leadingAnchor, padding: .init(top: 0, left: 8, bottom: 0, right: 8))
        durationLabel.anchor(top: titleLabel.bottomAnchor, leading: coverImage.trailingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 8, bottom: 4, right: 8))
        progressLabel.anchor(top: durationLabel.bottomAnchor, leading: coverImage.trailingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 4, left: 8, bottom: 4, right: 8))
        
        self.addConstraint(NSLayoutConstraint.init(item: durationLabel, attribute: .centerY, relatedBy: .equal, toItem: coverImage, attribute: .centerY, multiplier: 1, constant: 0))
        
        downloadButton.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 20, height: 20))
        
        self.addConstraints([NSLayoutConstraint.init(item: downloadButton, attribute: .centerX, relatedBy: .equal, toItem: progressView2, attribute: .centerX, multiplier: 1, constant: 0),NSLayoutConstraint.init(item: downloadButton, attribute: .centerY, relatedBy: .equal, toItem: progressView2, attribute: .centerY, multiplier: 1, constant: 0),NSLayoutConstraint.init(item: pauseButton, attribute: .centerX, relatedBy: .equal, toItem: progressView2, attribute: .centerX, multiplier: 1, constant: 0),NSLayoutConstraint.init(item: pauseButton, attribute: .centerY, relatedBy: .equal, toItem: progressView2, attribute: .centerY, multiplier: 1, constant: 0),NSLayoutConstraint.init(item: resumeButton, attribute: .centerX, relatedBy: .equal, toItem: progressView2, attribute: .centerX, multiplier: 1, constant: 0),NSLayoutConstraint.init(item: resumeButton, attribute: .centerY, relatedBy: .equal, toItem: progressView2, attribute: .centerY, multiplier: 1, constant: 0)])
        resumeButton.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 20, height: 20))
        pauseButton.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 20, height: 20))
        
        
        
        progressView2.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor, padding: .init(top: 18, left: 0, bottom: 0, right: 18), size: .init(width: 40, height: 40))
        
        progressView2.shouldShowValueText = false
        
        downloadButton.addTarget(self, action: #selector(downloadBasdy(button:)), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseBasdy(button:)), for: .touchUpInside)
        
        resumeButton.addTarget(self, action: #selector(resumeBasdy(button:)), for: .touchUpInside)
        
        self.contentView.addSubview(removeButton)
        removeButton.snp.makeConstraints { (make) in
            make.height.width.equalTo(40)
            make.center.equalTo(progressView2)
        }
        removeButton.isHidden = true

        refreshButton.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.center.equalTo(progressView2)
        }
        refreshButton.isHidden = false
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func downloadBasdy(button:UIButton){
        print("\(#fileID) => \(#function)")
        delegate?.downloadTapped(self)
        self.downloadButton.isHidden = true
        self.pauseButton.isHidden = false
        self.resumeButton.isHidden = true
    }
    
    @objc func resumeBasdy(button:UIButton){
        print("\(#fileID) => \(#function)")
        self.resumeButton.isHidden = true
        self.pauseButton.isHidden = false
        self.downloadButton.isHidden = true
        delegate?.resumeTapped(self)

    }
    
    @objc func pauseBasdy(button:UIButton){
        print("\(#fileID) => \(#function)")
        self.pauseButton.isHidden = true
        self.resumeButton.isHidden = false
        self.downloadButton.isHidden = true
        delegate?.pauseTapped(self)
    }
    
    func configure(track: Track, downloaded: Bool, download: Download?, isEditTapped: Bool = false) {
        titleLabel.text = track.name
        
        /// If it's active download
        if let download = download {
            
            progressLabel.text = download.isDownloading ? "Загружается..." : "Приостановлен"
            
            if (download.isDownloading) {
                resumeButton.isHidden = true
                downloadButton.isHidden = true
                pauseButton.isHidden = false
            } else {
                resumeButton.isHidden = false
                pauseButton.isHidden = true
                downloadButton.isHidden = true
            }
            
            progressLabel.isHidden = false
            
            let durationLen = track.dbRecord.duration?.count ?? 0
            if (durationLen > 5){
                durationLabel.text = "\(track.dbRecord.duration ?? " ")"
            } else {
                durationLabel.text = "\(track.dbRecord.duration ?? " ") мин"
            }
            progressView2.isHidden = false
            
        }
         
        /// If it's downloaded
        if (downloaded){
            progressLabel.text = "Скачано"
            
            let durationLen = track.dbRecord.duration?.count ?? 0
            
            if (durationLen > 5) {
                durationLabel.text = "\(track.dbRecord.duration ?? " ")"
            } else {
                durationLabel.text = "\(track.dbRecord.duration ?? " ") мин"
            }
            
            progressView2.isHidden = true
            downloadButton.isHidden = true
            resumeButton.isHidden = true
            pauseButton.isHidden = true
            progressLabel.isHidden = false
        }
        self.downloadButton.isHidden = true
        self.progressView2.isHidden = true
        removeButton.isHidden = !isEditTapped
        self.layoutIfNeeded()
    }
    
    
    func updateDisplay(progress: Double, totalSize : String) {
        progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
        progressView2.maxValue =  100
        let prc = (CGFloat(progress) * 100)
        progressView2.minValue = 0
        progressView2.value = CGFloat(prc)
    }
}

//MARK: - Gesture methods
extension DownloadCell {
    @objc
    private func removeButtonTapped(_ sender: UIButton?) {
        print("\(#fileID) => \(#function)")
        self.editDelegate?.forwardOrEditButtonTapped(on: self)
    }
    
    @objc
    private func refreshButtonTapped(_ sender: UIButton?) {
        print("\(#fileID) => \(#function)")
    }
}
