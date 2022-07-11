//
//  YXScreenshotShareViewController.swift
//  uSmartOversea
//
//  Created by youxin on 2019/5/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator

class YXScreenshotShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

class YXStockDetailSnapShotView: UIView {
    
    init(frame: CGRect, qrImage: UIImage) {
        super.init(frame: frame)
        
        initUI(qrImage: qrImage)
    }
    
    convenience init(_ qrImage: UIImage) {
        self.init(frame: CGRect.zero, qrImage: qrImage)
    }
    
    var image: UIImage! {
        didSet {
            imageView.image = image
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initUI(qrImage: UIImage)  {
        
        self.backgroundColor = QMUITheme().textColorLevel1().withAlphaComponent(0.3)
        addSubview(bottomView)
        addSubview(imageView)
        bottomView.addSubview(leftImageView)
        bottomView.addSubview(leftLogoImageView)
        bottomView.addSubview(leftDescLabel)
        bottomView.addSubview(rightImageView)
        bottomView.addSubview(rightLabelImageView)
        
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(70)
        }
        
        leftImageView.snp.makeConstraints { (make) in
            make.width.equalTo(67)
            make.height.equalTo(12)
            make.left.equalTo(leftLogoImageView.snp.right).offset(8)
            make.bottom.equalTo(leftLogoImageView.snp.centerY).offset(-2)
        }
        
        leftDescLabel.snp.makeConstraints { make in
            make.left.equalTo(leftLogoImageView.snp.right).offset(8)
            make.top.equalTo(leftLogoImageView.snp.centerY).offset(4)
        }
        
        leftLogoImageView.snp.makeConstraints { (make) in
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        rightImageView.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        

        imageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        leftImageView.image = UIImage(named: "share_logo")
        rightImageView.image = qrImage
    }
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.themeColor(withNormalHex: "#F8F9FC", andDarkColor: "#292933")
        return view
    }()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var leftLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage.init(named: "share_logo_icon")?.byRoundCornerRadius(4)
        return imageView
    }()
    
    lazy var leftDescLabel: UILabel = {
        let lab = UILabel()
        lab.text = YXLanguageUtility.kLang(key: "learning_intelligence_community")
        lab.font = UIFont.systemFont(ofSize: 10)
        lab.textColor = QMUITheme().textColorLevel2()
        return lab
    }()
    
    lazy var rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
//        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
       // imageView.isHidden = true
        return imageView
    }()
    
    lazy var rightLabelImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
}
