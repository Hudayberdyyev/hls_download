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
import SDWebImage

protocol DownloadCellDelegate {
    func downloadButtonTapped(_ cell: UICollectionViewCell)
    func pauseButtonTapped(_ cell: UICollectionViewCell)
    func resumeButtonTapped(_ cell: UICollectionViewCell)
    func forwardOrRemoveButtonTapped(_ cell: UICollectionViewCell)
    func refreshButtonTapped(_ cell: UICollectionViewCell)
}

class DownloadCell: BaseCell {
    
    var delegate: DownloadCellDelegate?
    
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
        self.contentView.addSubview(removeButton)
        
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
        
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped(button:)), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseButtonTapped(button:)), for: .touchUpInside)
        resumeButton.addTarget(self, action: #selector(resumeButtonTapped(button:)), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped(_:)), for: .touchUpInside)
        
        
        removeButton.snp.makeConstraints { (make) in
            make.height.width.equalTo(40)
            make.center.equalTo(progressView2)
        }

        refreshButton.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.center.equalTo(progressView2)
        }
        
    }
    
    public func configure(
        hlsObject: HLSObject,
        isEditTapped: Bool = false
    ) {
        
        /// Set general properties
        self.titleLabel.text = hlsObject.name
        self.durationLabel.text = "длительность видео"
        
        /// Set thumbnail
        self.configureThumbnailImage(thumbnailUrl: hlsObject.thumbnailUrl)
        
        /// Not downloaded yet
        if hlsObject.state == .notDownloaded {
            configureCellForNotDownloadedState(hlsObject: hlsObject)
        }
        /// Downloading state
        else if hlsObject.state == .downloading {
            configureCellForDownloadingState(hlsObject: hlsObject)
        }
        /// Paused state
        else if hlsObject.state == .paused {
            configureCellForPausedState(hlsObject: hlsObject)
        }
        /// Downloaded  state
        else if hlsObject.state == .downloaded {
            configureCellForDownloadedState(hlsObject: hlsObject)
        }
        
        
        /// Edit mode enabled
        if isEditTapped {
            configureCellForEditMode()
        }
    }
    
    private func configureThumbnailImage(thumbnailUrl: URL?) {
        guard let url = thumbnailUrl else {return}
        coverImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        coverImage.sd_setImage(with: url) { (image, error, cache, urls) in
            if error != nil {
                /// Load image fail with error
                print("Job failed: \(error!.localizedDescription)")
            } else {
                /// Load image success
            }
        }
    }
    
    private func configureCellForEditMode() {
        self.downloadButton.disableButton()
        self.resumeButton.disableButton()
        self.pauseButton.disableButton()
        self.refreshButton.disableButton()
        self.removeButton.enableButton()
    }
    
    private func configureCellForNotDownloadedState(hlsObject: HLSObject) {
        self.downloadButton.disableButton()
        self.pauseButton.disableButton()
        self.resumeButton.disableButton()
        self.removeButton.disableButton()
        self.refreshButton.enableButton()
        self.progressLabel.text = "Произошла ошибка"
    }
    
    private func configureCellForPausedState(hlsObject: HLSObject) {
        self.downloadButton.disableButton()
        self.pauseButton.disableButton()
        self.resumeButton.enableButton()
        self.removeButton.disableButton()
        self.refreshButton.disableButton()
        
        /// Set progress label
        self.progressLabel.text = "Приостановлено"
        
        /// Configure progress view
        if let percentComplete = hlsObject.progress {
            self.progressView2.minValue = 0
            self.progressView2.maxValue = 100
            self.progressView2.value = CGFloat(percentComplete * 100)
        }
    }
    
    private func configureCellForDownloadingState(hlsObject: HLSObject) {
        self.downloadButton.disableButton()
        self.pauseButton.enableButton()
        self.resumeButton.disableButton()
        self.removeButton.disableButton()
        self.refreshButton.disableButton()
        self.progressLabel.text = "Скачивается ..."
    }
    
    private func configureCellForDownloadedState(hlsObject: HLSObject) {
        self.downloadButton.disableButton()
        self.pauseButton.disableButton()
        self.resumeButton.disableButton()
        self.removeButton.disableButton()
        self.refreshButton.disableButton()
        self.progressView2.isHidden = true
        self.progressLabel.text = "Скачано"
    }
    
    
    func updateDisplay(progress: Double, totalSize : String) {
        progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
        progressView2.maxValue =  100
        let prc = (CGFloat(progress) * 100)
        progressView2.minValue = 0
        progressView2.value = CGFloat(prc)
    }
    
    func updateDisplay(with percentComplete: Double) {
        DispatchQueue.main.async {
            self.progressLabel.text = String(format: "%.1f%%", percentComplete * 100)
            self.progressView2.minValue = 0
            self.progressView2.maxValue = 100
            self.progressView2.value = CGFloat(percentComplete * 100)
        }
    }
}

//MARK: - Gesture methods
extension DownloadCell {
    @objc
    private func removeButtonTapped(_ sender: UIButton?) {
        print("\(#fileID) => \(#function)")
        self.delegate?.forwardOrRemoveButtonTapped(self)
    }
    
    @objc
    private func refreshButtonTapped(_ sender: UIButton?) {
        print("\(#fileID) => \(#function)")
        self.delegate?.refreshButtonTapped(self)
        self.refreshButton.disableButton()
        self.resumeButton.disableButton()
        self.pauseButton.enableButton()
        self.progressLabel.text = "Ожидание ответа от сервера ... "
    }
    
    @objc
    func downloadButtonTapped(button: UIButton){
        print("\(#fileID) => \(#function)")
        delegate?.downloadButtonTapped(self)
        self.downloadButton.disableButton()
        self.pauseButton.enableButton()
        self.progressLabel.text = "Ожидание ответа от сервера ... "
    }
    
    @objc
    func resumeButtonTapped(button: UIButton){
        print("\(#fileID) => \(#function)")
        delegate?.resumeButtonTapped(self)
        self.resumeButton.disableButton()
        self.pauseButton.enableButton()
        self.progressLabel.text = "Ожидание ответа от сервера ... "
    }
    
    @objc
    func pauseButtonTapped(button: UIButton){
        print("\(#fileID) => \(#function)")
        delegate?.pauseButtonTapped(self)
        self.pauseButton.disableButton()
        self.resumeButton.enableButton()
        self.progressLabel.text = "Загрузка приостановлено"
    }
    
}
