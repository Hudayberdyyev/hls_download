//
//  ViewController.swift
//  download_asset
//
//  Created by design on 15.08.2022.
//

import UIKit
import SnapKit
import SDWebImage

class ViewController: UIViewController {
    
    //MARK: - Properties
    private var downloadsList: [Track] = []
    private var downloadsCoreData: [Kino] = []
    
    //MARK: - UIControls
    lazy var filmsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(DownloadCell.self, forCellWithReuseIdentifier: K.Identifiers.downloadCellID)
        cv.backgroundColor = .clear
        return cv
    }()
    
    private let createDownloadItemButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .systemBlue
        b.layer.cornerRadius = 7
        b.clipsToBounds = true
        b.setTitle("Добавить новую загрузку", for: .normal)
        b.setTitleColor(UIColor.white, for: .normal)
        return b
    }()
    
    //MARK: - View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupInitialConfigurations()
        self.setupViews()
        self.setupGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadDownloadsFromDB()
    }
    
    private func setupInitialConfigurations() {
        print("\(#fileID) => \(#function)")
        /// Set background as black
        self.view.backgroundColor = .black
        
        /// Navigation bar configurations
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.topItem?.title = "Загрузки"
    }
    
    private func setupViews() {
        view.addSubview(createDownloadItemButton)
        createDownloadItemButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.6)
            make.height.equalTo(40)
            make.bottom.equalTo(view).offset(-15)
        }
        
        view.addSubview(filmsCollectionView)
        filmsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view)
            make.bottom.equalTo(createDownloadItemButton.snp.top).offset(-10)
        }
        
    }
    
    private func setupGestureRecognizers() {
        createDownloadItemButton.addTarget(self, action: #selector(createDownloadItemButtonTapped(_:)), for: .touchUpInside)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func reload(_ row: Int) {
        filmsCollectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.downloadsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let optionalCell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Identifiers.downloadCellID, for: indexPath)
        
        let cell = optionalCell as! DownloadCell
        
        let track = self.downloadsList[indexPath.row]
        cell.configure(track: track,
                       downloaded: track.dbRecord.downloaded,
                       download: nil)
        
        if track.dbRecord.cover_url != nil {
            /// Download and set image
            if let url = URL(string: track.dbRecord.cover_url ?? "") {
                cell.coverImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.coverImage.sd_setImage(with: url) { (image, error, cache, urls) in
                    if error != nil {
                        print("Job failed: \(error?.localizedDescription)")
                    } else {
                        /// Image loaded successfully
                    }
                }
            }
        } else {
            cell.coverImage.image = UIImage(named: "logo-light")
            cell.coverImage.contentMode = .scaleAspectFit
        }
        
        cell.delegate = self
        cell.editDelegate = self
        cell.updateDisplay(progress: 0.25, totalSize: "185MB")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 85)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(#fileID) => \(#function)")
    }
}

extension ViewController {
    @objc
    func createDownloadItemButtonTapped(_ sender: UIButton?) {
        print("\(#fileID) => \(#function)")
        let inputVC = InputViewController()
        self.navigationController?.pushViewController(inputVC, animated: true)
    }
}

//MARK: - Helper methods
extension ViewController {
    private func loadDownloadsFromDB() {
        /// Retrieve films from core data
        self.downloadsCoreData = DBServices.sharedInstance.getKino()
        self.downloadsList = []
        
        var index = 0
        for kino in self.downloadsCoreData {
            guard let url = URL(string: kino.url ?? "") else {
                /// Remove it from core data
                let movieId = kino.id
                DBServices.sharedInstance.deleteKinoFromDB(id: Int(movieId)) { isOk in
                    if isOk {
                        print("movie with id = \(movieId) successfully removed")
                    } else {
                        print("movie with id = \(movieId) remove fail with error")
                    }
                }
                
                continue
            }
            let track = Track(name: kino.k_name ?? "Название фильма", dbRecord: kino, previewURL: url, index: index)
            track.downloaded = kino.downloaded
            self.downloadsList.append(track)
            index += 1
        }
        
        print("count of downloading films = \(self.downloadsList.count)")
        
        self.filmsCollectionView.reloadData()
    }
}

//MARK: - TrackCell delegate, EditDownloads delegate methods
extension ViewController: TrackCellDelegate, EditDownloadsDelegate {
    func cancelTapped(_ cell: DownloadCell) {
        print("\(#fileID) => \(#function)")
    }
    
    func downloadTapped(_ cell: DownloadCell) {
        print("\(#fileID) => \(#function)")
    }
    
    func pauseTapped(_ cell: DownloadCell) {
        print("\(#fileID) => \(#function)")
    }
    
    func resumeTapped(_ cell: DownloadCell) {
        print("\(#fileID) => \(#function)")
    }
    
    func deleteKinoTapped(_ cell: DownloadCell) {
        print("\(#fileID) => \(#function)")
    }
    
    func forwardOrEditButtonTapped(on baseCell: UICollectionViewCell) {
        print("\(#fileID) => \(#function)")
    }
}
