//
//  ViewController.swift
//  download_asset
//
//  Created by design on 15.08.2022.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - UIControls
    lazy var filmsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(DownloadCell.self, forCellWithReuseIdentifier: K.Identifiers.downloadCellID)
        cv.backgroundColor = .red
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
    
    private func setupInitialConfigurations() {
        print("\(#fileID) => \(#function)")
        /// Set background as black
        self.view.backgroundColor = .black
        
        /// Navigation bar configurations
        self.navigationController!.navigationBar.barStyle = .black
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController!.navigationBar.topItem?.title = "Загрузки"
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
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(#fileID) => \(#function)")
    }
}

extension ViewController {
    @objc
    func createDownloadItemButtonTapped(_ sender: UIButton?) {
        print("\(#fileID) => \(#function)")
    }
}
