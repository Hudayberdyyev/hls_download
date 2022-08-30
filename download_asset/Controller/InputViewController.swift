//
//  InputViewController.swift
//  download_asset
//
//  Created by design on 30.08.2022.
//

import UIKit
import SnapKit

class InputViewController: UIViewController {
    
    //MARK: - Properties
    private let itemHeightConstant: CGFloat = 1.0 / 12.0
    private let defaultFont: UIFont = .systemFont(ofSize: 20)
    private let offsetConstant: CGFloat = 10.0
    private let widthMultiplier: CGFloat = 0.3
    
    //MARK: - UIControls
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .clear
        return sv
    }()
    
    private lazy var coverUrlTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .clear
        tf.textColor = .white
        tf.font = defaultFont
        tf.textAlignment = .center
        tf.layer.borderColor = UIColor.white.cgColor
        tf.layer.borderWidth = 2
        tf.layer.cornerRadius = 7
        tf.clipsToBounds = true
        tf.attributedPlaceholder = NSAttributedString(
            string: "Напишите сюда ...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        return tf
    }()
    
    private lazy var coverUrlLabel: UILabel = {
        let l = UILabel()
        l.backgroundColor = .clear
        l.textColor = .white
        l.font = defaultFont
        l.text = "cover_url: "
        l.textAlignment = .center
        return l
    }()
    
    private lazy var durationTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .clear
        tf.textColor = .white
        tf.font = defaultFont
        tf.textAlignment = .center
        tf.layer.borderColor = UIColor.white.cgColor
        tf.layer.borderWidth = 2
        tf.layer.cornerRadius = 7
        tf.clipsToBounds = true
        tf.attributedPlaceholder = NSAttributedString(
            string: "Напишите сюда ...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        return tf
    }()
    
    private lazy var durationLabel: UILabel = {
        let l = UILabel()
        l.backgroundColor = .clear
        l.textColor = .white
        l.font = defaultFont
        l.text = "duration: "
        l.textAlignment = .center
        return l
    }()
    
    private lazy var movieIdTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .clear
        tf.textColor = .white
        tf.font = defaultFont
        tf.textAlignment = .center
        tf.layer.borderColor = UIColor.white.cgColor
        tf.layer.borderWidth = 2
        tf.layer.cornerRadius = 7
        tf.clipsToBounds = true
        tf.attributedPlaceholder = NSAttributedString(
            string: "Напишите сюда ...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        return tf
    }()
    
    private lazy var movieIdLabel: UILabel = {
        let l = UILabel()
        l.backgroundColor = .clear
        l.textColor = .white
        l.font = defaultFont
        l.text = "movie_id: "
        l.textAlignment = .center
        return l
    }()
    
    private lazy var movieNameTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .clear
        tf.textColor = .white
        tf.font = defaultFont
        tf.textAlignment = .center
        tf.layer.borderColor = UIColor.white.cgColor
        tf.layer.borderWidth = 2
        tf.layer.cornerRadius = 7
        tf.clipsToBounds = true
        tf.attributedPlaceholder = NSAttributedString(
            string: "Напишите сюда ...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        return tf
    }()
    
    private lazy var movieNameLabel: UILabel = {
        let l = UILabel()
        l.backgroundColor = .clear
        l.textColor = .white
        l.font = defaultFont
        l.text = "k_name: "
        l.textAlignment = .center
        return l
    }()
    
    private lazy var stateTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .clear
        tf.textColor = .white
        tf.font = defaultFont
        tf.textAlignment = .center
        tf.layer.borderColor = UIColor.white.cgColor
        tf.layer.borderWidth = 2
        tf.layer.cornerRadius = 7
        tf.clipsToBounds = true
        tf.attributedPlaceholder = NSAttributedString(
            string: "Напишите сюда ...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        return tf
    }()
    
    private lazy var stateLabel: UILabel = {
        let l = UILabel()
        l.backgroundColor = .clear
        l.textColor = .white
        l.font = defaultFont
        l.text = "state: "
        l.textAlignment = .center
        return l
    }()
    
    private lazy var sourceUrlTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .clear
        tf.textColor = .white
        tf.font = defaultFont
        tf.textAlignment = .center
        tf.layer.borderColor = UIColor.white.cgColor
        tf.layer.borderWidth = 2
        tf.layer.cornerRadius = 7
        tf.clipsToBounds = true
        tf.attributedPlaceholder = NSAttributedString(
            string: "Напишите сюда ...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        return tf
    }()
    
    private lazy var sourceUrlLabel: UILabel = {
        let l = UILabel()
        l.backgroundColor = .clear
        l.textColor = .white
        l.font = defaultFont
        l.text = "source_url: "
        l.textAlignment = .center
        return l
    }()
    
    private lazy var createButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .systemBlue
        b.layer.cornerRadius = 7
        b.clipsToBounds = true
        b.setTitle("Добавить", for: .normal)
        b.setTitleColor(UIColor.white, for: .normal)
        return b
    }()
    
    //MARK: - View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInitialConfigurations()
        self.setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismissKeyboard()
    }
    
    private func setupInitialConfigurations() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewControllerTapped(_:))))
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        scrollView.addSubview(coverUrlLabel)
        coverUrlLabel.snp.makeConstraints { make in
            make.leading.top.equalTo(view)
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        scrollView.addSubview(coverUrlTextField)
        coverUrlTextField.snp.makeConstraints { make in
            make.trailing.top.equalTo(view)
            make.leading.equalTo(coverUrlLabel.snp.trailing).offset(offsetConstant)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        scrollView.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.top.equalTo(coverUrlLabel.snp.bottom).offset(offsetConstant)
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        scrollView.addSubview(durationTextField)
        durationTextField.snp.makeConstraints { make in
            make.top.equalTo(coverUrlTextField.snp.bottom).offset(offsetConstant)
            make.trailing.equalTo(view)
            make.leading.equalTo(durationLabel.snp.trailing).offset(offsetConstant)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        scrollView.addSubview(movieIdLabel)
        movieIdLabel.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.top.equalTo(durationLabel.snp.bottom).offset(offsetConstant)
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        scrollView.addSubview(movieIdTextField)
        movieIdTextField.snp.makeConstraints { make in
            make.top.equalTo(durationTextField.snp.bottom).offset(offsetConstant)
            make.trailing.equalTo(view)
            make.leading.equalTo(movieIdLabel.snp.trailing).offset(offsetConstant)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        scrollView.addSubview(movieNameLabel)
        movieNameLabel.snp.makeConstraints { make in
            make.top.equalTo(movieIdLabel.snp.bottom).offset(offsetConstant)
            make.leading.equalTo(view)
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        scrollView.addSubview(movieNameTextField)
        movieNameTextField.snp.makeConstraints { make in
            make.top.equalTo(movieIdTextField.snp.bottom).offset(offsetConstant)
            make.leading.equalTo(movieNameLabel.snp.trailing).offset(offsetConstant)
            make.trailing.equalTo(view)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        scrollView.addSubview(stateLabel)
        stateLabel.snp.makeConstraints { make in
            make.top.equalTo(movieNameLabel.snp.bottom).offset(offsetConstant)
            make.leading.equalTo(view)
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        scrollView.addSubview(stateTextField)
        stateTextField.snp.makeConstraints { make in
            make.top.equalTo(movieNameTextField.snp.bottom).offset(offsetConstant)
            make.leading.equalTo(stateLabel.snp.trailing).offset(offsetConstant)
            make.trailing.equalTo(view)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        scrollView.addSubview(sourceUrlLabel)
        sourceUrlLabel.snp.makeConstraints { make in
            make.top.equalTo(stateLabel.snp.bottom).offset(offsetConstant)
            make.leading.equalTo(view)
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        scrollView.addSubview(sourceUrlTextField)
        sourceUrlTextField.snp.makeConstraints { make in
            make.top.equalTo(stateTextField.snp.bottom).offset(offsetConstant)
            make.leading.equalTo(sourceUrlLabel.snp.trailing).offset(offsetConstant)
            make.trailing.equalTo(view)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        scrollView.addSubview(createButton)
        createButton.snp.makeConstraints { make in
            make.top.equalTo(sourceUrlTextField.snp.bottom).offset(offsetConstant)
            make.centerX.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.6)
            make.height.equalTo(40)
        }
        createButton.addTarget(self, action: #selector(createButtonTapped(_:)), for: .touchUpInside)
    }
}

//MARK: - Gesture methods
extension InputViewController {
    @objc
    func createButtonTapped(_ sender: UIButton?) {
        print("\(#fileID) => \(#function)")
        do {
            let movieId: Int = Int(movieIdTextField.text ?? "") ?? 0
            let movieName: String = movieNameTextField.text ?? ""
            let duration: String = durationTextField.text ?? ""
            let downloadURL: String = sourceUrlTextField.text ?? ""
            let imageURL: String = coverUrlTextField.text ?? ""
            let seasonIndex: Int = 0
            let episodeIndex: Int = 0
            let isSerial: Bool = false
            let downloadingState: DownloadingState = .downloading
            
            try DBServices.sharedInstance.addKinoToDB(
                id: movieId,
                movieName: movieName,
                duration: duration,
                downloadURL: downloadURL,
                imageURL: imageURL,
                seasonIndex: seasonIndex,
                episodeIndex: episodeIndex,
                isSerial: isSerial,
                downloadingState: downloadingState
            )
        } catch let err {
            print(err.localizedDescription)
        }
        
    }
    
    @objc
    func viewControllerTapped(_ sender: Any?) {
        print("\(#fileID) => \(#function)")
        if (sender as? UITextField) != nil {
            return
        }
        
        dismissKeyboard()
    }
    
    private func dismissKeyboard() {
        let textFields = scrollView.subviews.compactMap { $0 as? UITextField }
        
        for textFieldItem in textFields {
            textFieldItem.resignFirstResponder()
        }
    }
}
