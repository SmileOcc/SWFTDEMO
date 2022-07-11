//
//  YXMarketCommonHeaderCell.swift
//  uSmartOversea
//
//  Created by ellison on 2018/12/28.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXLearningCommonHeaderReusableView: UICollectionReusableView, HasDisposeBag {
    
    var action: (() -> Void)?
    var refreshAction: (() -> Void)?
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    @objc var icon: UIImage? = nil {
        didSet {
            self.iconView.image = icon
            if icon == nil {
                titleLabel.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview().offset(16)
                    make.centerY.equalTo(self)
                    make.width.lessThanOrEqualTo(YXConstant.screenWidth-70)
                }
                redDotView.snp.remakeConstraints { (make) in
                    make.left.equalTo(titleLabel.snp.right)
                    make.centerY.equalTo(titleLabel.snp.top)
                    make.width.height.equalTo( 8 )
                }
            } else {
                titleLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(iconView.snp.right).offset(10)
                    make.centerY.equalTo(self)
                    make.width.lessThanOrEqualTo(YXConstant.screenWidth-70)
                }
                
                redDotView.snp.remakeConstraints { (make) in
                    make.left.equalTo(iconView.snp.right)
                    make.centerY.equalTo(iconView.snp.top)
                    make.width.height.equalTo( 8 )
                }
            }
        }
    }
    
    @objc var hideChangeBtn: Bool = false {
        didSet {
            self.refreshbutton.isHidden = hideChangeBtn
        }
    }
    
    @objc var hideRightTitleBtn: Bool = false {
        didSet {
            self.arrowView.isHidden = !hideRightTitleBtn
            self.rightTitleLabel.isHidden = hideRightTitleBtn
        }
    }
    
    
    @objc var title: String? = nil {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    @objc var titleFont: UIFont? = nil {
        didSet {
            self.titleLabel.font = titleFont
        }
    }
    
    @objc var subTitle: String? = nil {
        didSet {
            self.subTitleLabel.text = subTitle
        }
    }
    
    @objc var hideRedDot: Bool = false {
        didSet {
            self.redDotView.isHidden = hideRedDot
        }
    }
    //小红点
    fileprivate lazy var redDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.isHidden = true
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var rightTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = QMUITheme().themeTintColor()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.minimumScaleFactor = 0.3
        label.isHidden = true
        return label
    }()
    
    lazy var rightTitleBtn: UIButton = {
        let btn =  UIButton(type: .custom)
        btn.setTitleColor(QMUITheme().themeTintColor(), for: .normal)
        btn.setTitle(YXLanguageUtility.kLang(key: "nbb_tab_myfollow"), for: .normal)
        btn.layer.cornerRadius = 4
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        btn.clipsToBounds = true

    //    btn.setSubmmitTheme()
        return btn
    }()
    
    fileprivate lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()
    
    lazy var arrowView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "market_more_arrow")
        return imageView
    }()
    
    lazy var button: UIButton = {
        let button = UIButton()
        return button
    }()
    
    lazy var refreshbutton: UIButton = {
        let button = QMUIButton()
        button.backgroundColor = .clear
        button.setTitleColor(UIColor.qmui_color(withHexString: "#FF8B00"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.setImage(UIImage(named: "icon"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        button.setTitle(YXLanguageUtility.kLang(key: "nbb_refresh_change"), for: .normal)
        return button
    }()
    
    fileprivate lazy var iconView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initializeViews() {
        addSubview(titleLabel)
//        addSubview(subTitleLabel)
        addSubview(arrowView)
        addSubview(iconView)
        addSubview(redDotView)
        addSubview(button)
        addSubview(refreshbutton)
        addSubview(rightTitleLabel)

        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalTo(self)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth-70)
        }
        
//        subTitleLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(titleLabel.snp.right).offset(10)
//            make.centerY.equalTo(titleLabel)
//        }
        
        refreshbutton.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(10)
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(80)
        }
        
        iconView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(12)
            make.centerY.equalTo(self)
        }
        
        arrowView.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-16)
            make.centerY.equalTo(self)
        }
        
        redDotView.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right)
            make.centerY.equalTo(iconView.snp.top)
            make.width.height.equalTo( 8 )
        }
        
        button.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        rightTitleLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-16)
            make.centerY.equalTo(self)
            make.width.equalTo(100)
        }
    }
    
}

class YXLearningMasterFooterReusableView: UICollectionReusableView {
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    lazy var refreshbutton: UIButton = {
        let button = QMUIButton()
        button.backgroundColor = .clear
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setImage(UIImage(named: "main_master_refresh_normal"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        button.setTitle(YXLanguageUtility.kLang(key: "nbb_refresh_change"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initializeViews() {
        self.addSubview(refreshbutton)
        
        refreshbutton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(100)
        }
    }
}

class YXLearningAskLineFooterReusableView: UICollectionReusableView {
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initializeViews() {
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        self.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalTo(0.5)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
}
