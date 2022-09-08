//
//  ViewController.swift
//  download_asset
//
//  Created by design on 15.08.2022.
//

import UIKit
import SnapKit
import SDWebImage
import os.log

class ViewController: UIViewController {
    
    //MARK: - Properties
    private var downloadsList: [HLSObject] = []
    private var downloadsCoreData: [Kino] = []
    private var isEditTapped: Bool = false
    
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
    
    private func forTestingPurposes() {
//        let downloadsList = DBServices.sharedInstance.getKino()
//        os_log("%@ => %@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function, String(downloadsList.count))
//        for kino in downloadsList {
//            DBServices.sharedInstance.changeLocalPathKinoById(with: kino.id, to: "")
//        }
    }
    
    //MARK: - View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("%@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function)
        // Do any additional setup after loading the view.
        forTestingPurposes()
        self.setupInitialConfigurations()
        self.setupViews()
        self.setupGestureRecognizers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Set as session manager delegate
        SessionManager.shared.sessionManagerDelegate = self
        self.setupEditButtonOnNavigationBar()
        self.loadDownloadsFromDB()
    }
    
    private func setupEditButtonOnNavigationBar() {
        let barButtonItem = UIBarButtonItem(
            image: Icon.Pencil1.image().resizeImage(toSize: CGSize(width: 20, height: 20))?.withRenderingMode(.alwaysTemplate),
            style: .plain,
            target: self,
            action: #selector(editButtonTappedOnNavBar(_:))
        )
        barButtonItem.tintColor = .lightGray
        barButtonItem.imageInsets = .init(top: 0, left: 5, bottom: 0, right: 5)
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func setupInitialConfigurations() {
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
        let hlsObject = self.downloadsList[indexPath.row]
        cell.configure(hlsObject: hlsObject, isEditTapped: self.isEditTapped)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 85)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
            /// Thumbnail url,  Movie id, Stream url, Movie name
            
            let headers: [String: String] = [
                "Authorization": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySWQiOjk3fQ.c3Hnysn5_aB8YLnzty-5eXEcZVLYz0Aj5lz6-wslX8g"
            ]
            let hlsObject = HLSObject(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers], name: kino.k_name ?? "", state: kino.downloadingState, thumbnailUrl: URL(string: kino.cover_url ?? ""), movieId: Int(kino.id))
            
            /// If we have valid local path for download then set localUrl
//            if let localPath = kino.local_path {
//                hlsObject.localUrl = URL(string: localPath)
//            }
            self.downloadsList.append(hlsObject)
            os_log("%@ => %@ => %@ downloading state is %@", log: OSLog.downloads, type: .info, #fileID, #function, kino.k_name ?? "", String(kino.downloading_state))
            index += 1
        }
        
        print("count of downloading films = \(self.downloadsList.count)")
        
        self.filmsCollectionView.reloadData()
    }
}

//MARK: - TrackCell delegate, EditDownloads delegate methods
extension ViewController: DownloadCellDelegate {
    func forwardOrRemoveButtonTapped(_ cell: UICollectionViewCell) {
        print("\(#fileID) => \(#function)")
    }
    
    func refreshButtonTapped(_ cell: UICollectionViewCell) {
        print("\(#fileID) => \(#function)")
    }
    
    
    func downloadButtonTapped(_ cell: UICollectionViewCell) {
        print("\(#fileID) => \(#function)")
        if let downloadCell = cell as? DownloadCell,
           let indexPath = filmsCollectionView.indexPath(for: downloadCell),
           indexPath.row < self.downloadsList.count
        {
            let hlsObj = self.downloadsList[indexPath.row]
            hlsObj.startDownload()
        }
    }
    
    func pauseButtonTapped(_ cell: UICollectionViewCell) {
        print("\(#fileID) => \(#function)")
        if let downloadCell = cell as? DownloadCell,
           let indexPath = filmsCollectionView.indexPath(for: downloadCell),
           indexPath.row < self.downloadsList.count
        {
            let hlsObj = self.downloadsList[indexPath.row]
            hlsObj.cancelDownload()
        }
    }
    
    func resumeButtonTapped(_ cell: UICollectionViewCell) {
        print("\(#fileID) => \(#function)")
        if let downloadCell = cell as? DownloadCell,
           let indexPath = filmsCollectionView.indexPath(for: downloadCell),
           indexPath.row < self.downloadsList.count
        {
            let hlsObj = self.downloadsList[indexPath.row]
            hlsObj.resumeDownload()
        }
    }
}

//MARK: - Gesture methods
extension ViewController {
    @objc
    func editButtonTappedOnNavBar(_ sender: UIButton?) {
        print("\(#fileID) => \(#function)")
        self.isEditTapped = !isEditTapped
        
        if isEditTapped {
            self.navigationController?.navigationBar.backgroundColor = .systemRed
            self.navigationItem.rightBarButtonItem?.image =  Icon.Close1.image().resizeImage(toSize: CGSize(width: 20, height: 20))?.withRenderingMode(.alwaysTemplate)
            self.navigationItem.rightBarButtonItem?.tintColor = .white
            
        } else {
            self.navigationController?.navigationBar.backgroundColor = .black
            self.navigationItem.rightBarButtonItem?.image =  Icon.Pencil1.image().resizeImage(toSize: CGSize(width: 20, height: 20))?.withRenderingMode(.alwaysTemplate)
            self.navigationItem.rightBarButtonItem?.tintColor = .lightGray
        }
        
        self.filmsCollectionView.reloadData()
    }
}

extension ViewController: SessionManagerDelegate {
    func updateProgress(for hlsObj: HLSObject, with progress: Double) {
        let optIndex = self.downloadsList.firstIndex { downloadItem in
            hlsObj.movieId == downloadItem.movieId
        }
        
        guard let index = optIndex else {return}
        
        if let downloadCell = self.filmsCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? DownloadCell {
            downloadCell.updateDisplay(with: progress)
        }
    }
    
    func downloadComplete(for hlsObj: HLSObject) {
        let optIndex = self.downloadsList.firstIndex { downloadItem in
            hlsObj.movieId == downloadItem.movieId
        }

        guard let index = optIndex else {return}
        self.downloadsList[index] = hlsObj
        
        if let downloadCell = self.filmsCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? DownloadCell {
            downloadCell.configure(hlsObject: self.downloadsList[index])
        }
    }
}
