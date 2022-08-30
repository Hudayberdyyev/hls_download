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
    
    //MARK: - View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    private func setupViews() {
        view.addSubview(coverUrlLabel)
        view.addSubview(coverUrlTextField)
        coverUrlLabel.snp.makeConstraints { make in
            make.leading.top.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.3)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
        
        coverUrlTextField.snp.makeConstraints { make in
            make.trailing.top.equalTo(view)
            make.leading.equalTo(coverUrlLabel.snp.trailing).offset(10)
            make.height.equalTo(view).multipliedBy(itemHeightConstant)
        }
    }
}
