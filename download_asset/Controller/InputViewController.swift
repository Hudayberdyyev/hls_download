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
        self.setupViews()
    }
    
    private func setupViews() {
        view.addSubview(coverUrlLabel)
        coverUrlLabel.snp.makeConstraints { make in
            make.leading.top.equalTo(view)
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        view.addSubview(coverUrlTextField)
        coverUrlTextField.snp.makeConstraints { make in
            make.trailing.top.equalTo(view)
            make.leading.equalTo(coverUrlLabel.snp.trailing).offset(offsetConstant)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        view.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.top.equalTo(coverUrlLabel.snp.bottom).offset(offsetConstant)
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        view.addSubview(durationTextField)
        durationTextField.snp.makeConstraints { make in
            make.top.equalTo(coverUrlTextField.snp.bottom).offset(offsetConstant)
            make.trailing.equalTo(view)
            make.leading.equalTo(durationLabel.snp.trailing).offset(offsetConstant)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        view.addSubview(movieIdLabel)
        movieIdLabel.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.top.equalTo(durationLabel.snp.bottom).offset(offsetConstant)
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        view.addSubview(movieIdTextField)
        movieIdTextField.snp.makeConstraints { make in
            make.top.equalTo(durationTextField.snp.bottom).offset(offsetConstant)
            make.trailing.equalTo(view)
            make.leading.equalTo(movieIdLabel.snp.trailing).offset(offsetConstant)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        view.addSubview(movieNameLabel)
        movieNameLabel.snp.makeConstraints { make in
            make.top.equalTo(movieIdLabel.snp.bottom).offset(offsetConstant)
            make.leading.equalTo(view)
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        view.addSubview(movieNameTextField)
        movieNameTextField.snp.makeConstraints { make in
            make.top.equalTo(movieIdTextField.snp.bottom).offset(offsetConstant)
            make.leading.equalTo(movieNameLabel.snp.trailing).offset(offsetConstant)
            make.trailing.equalTo(view)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        view.addSubview(stateLabel)
        stateLabel.snp.makeConstraints { make in
            make.top.equalTo(movieNameLabel.snp.bottom).offset(offsetConstant)
            make.leading.equalTo(view)
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        view.addSubview(stateTextField)
        stateTextField.snp.makeConstraints { make in
            make.top.equalTo(movieNameTextField.snp.bottom).offset(offsetConstant)
            make.leading.equalTo(stateLabel.snp.trailing).offset(offsetConstant)
            make.trailing.equalTo(view)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        view.addSubview(sourceUrlLabel)
        sourceUrlLabel.snp.makeConstraints { make in
            make.top.equalTo(stateLabel.snp.bottom).offset(offsetConstant)
            make.leading.equalTo(view)
            make.width.equalTo(view).multipliedBy(widthMultiplier)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        view.addSubview(sourceUrlTextField)
        sourceUrlTextField.snp.makeConstraints { make in
            make.top.equalTo(stateTextField.snp.bottom).offset(offsetConstant)
            make.leading.equalTo(sourceUrlLabel.snp.trailing).offset(offsetConstant)
            make.trailing.equalTo(view)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        view.addSubview(createButton)
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
    }
}
