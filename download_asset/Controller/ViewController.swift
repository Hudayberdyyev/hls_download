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
//        os_log("%@ => %@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function, String(downloadsList.count))
        let downloadsList = DBServices.sharedInstance.getKino()
        for kino in downloadsList {
//            DBServices.sharedInstance.changeDownloadingStateKinoByID(withID: kino.id, to: .notDownloaded)
//            DBServices.sharedInstance.changeLocalPathKinoById(with: Int(kino.id), to: "")
            
            /// Check to existing of download
//            let hlsObject = HLSObject(kino: kino)
//            let index = SessionManager.shared.getDownloadTaskIndex(hlsObject)
//            if index > -1 {
//                print("\(kino.id) => \(index)")
//            } else {
//                print("\(kino.id) => doesn't exists")
//            }
        }
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
            /// Initialize hls object
            let hlsObject = HLSObject(kino: kino)
            
            /// Check if it has valid download url, else remove it and just skip there
            if hlsObject.urlAsset == nil {
                DBServices.sharedInstance.deleteKinoFromDB(id: Int(kino.id)) { isOk in }
                continue
            }
            
            /// It's valid download, append it to download list
            self.downloadsList.append(hlsObject)
            
            /// Increment index
            index += 1
        }
        
        self.filmsCollectionView.reloadData()
    }
}

//MARK: - TrackCell delegate, EditDownloads delegate methods
extension ViewController: DownloadCellDelegate {
    func forwardOrRemoveButtonTapped(_ cell: UICollectionViewCell) {
        print("\(#fileID) => \(#function)")
    }
    
    func refreshButtonTapped(_ cell: UICollectionViewCell) {
        os_log("%@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function)
        if let downloadCell = cell as? DownloadCell,
           let indexPath = filmsCollectionView.indexPath(for: downloadCell),
           indexPath.row < self.downloadsList.count
        {
            let hlsObj = self.downloadsList[indexPath.row]
            hlsObj.resumeDownload()
        }
    }
    
    
    func downloadButtonTapped(_ cell: UICollectionViewCell) {
        os_log("%@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function)
        if let downloadCell = cell as? DownloadCell,
           let indexPath = filmsCollectionView.indexPath(for: downloadCell),
           indexPath.row < self.downloadsList.count
        {
            let hlsObj = self.downloadsList[indexPath.row]
            hlsObj.startDownload()
        }
    }
    
    func pauseButtonTapped(_ cell: UICollectionViewCell) {
        os_log("%@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function)
        if let downloadCell = cell as? DownloadCell,
           let indexPath = filmsCollectionView.indexPath(for: downloadCell),
           indexPath.row < self.downloadsList.count
        {
            let hlsObj = self.downloadsList[indexPath.row]
            hlsObj.cancelDownload()
        }
    }
    
    func resumeButtonTapped(_ cell: UICollectionViewCell) {
        os_log("%@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function)
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
    
    func locationCaptured(forMovie id: Int, to location: String) {
        os_log("%@ => %@ => %@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function, String(id), location)
        let optIndex = self.downloadsList.firstIndex { hlsObj in
            hlsObj.movieId == id
        }
        
        guard let index = optIndex else {return}
        
        self.downloadsList[index].localUrl = location
    }
    
    func updateView(for movieId: Int32) {
        os_log("%@ => %@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function, String(movieId))
        
        /// Retrieve last updates from core data
        let kino = DBServices.sharedInstance.getKinoByID(id: Int(movieId))
        
        /// Initialize optional index
        let optIndex = self.downloadsList.firstIndex { hlsObj in
            hlsObj.movieId == movieId
        }
        
        /// Safe retrieve index, and kino object
        guard let index = optIndex,
              let safeKino = kino
        else { return }
        
        /// Reset download list item
        self.downloadsList[index] = HLSObject(kino: safeKino)
        
        /// Re-confiugre corresponding cell
        if let downloadCell = self.filmsCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? DownloadCell {
            downloadCell.configure(hlsObject: self.downloadsList[index])
        }
    }
}
