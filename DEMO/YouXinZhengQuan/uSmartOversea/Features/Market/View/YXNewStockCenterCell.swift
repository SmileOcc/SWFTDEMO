//
//  YXNewStockCenterCell.swift
//  uSmartOversea
//
//  Created by ellison on 2018/12/28.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

let AD_ICON_WIDTH: CGFloat = 22
let AD_ICON_HEIGHT: CGFloat = 14

@objc enum YXNewStockCenterCellStyle: Int {
    case normal
    case showAD
}

class YXNewStockCenterAdView: UIView {
    
    typealias TapAction = (_ code: Int) -> Void
    
    @objc var index = 0
    
    @objc var tapAction: TapAction?
    
    fileprivate lazy var adBgView: UIImageView = {
        let adBgView = UIImageView()
        adBgView.image = UIImage(named: "newstock_adbg")
        return adBgView
    }()
    
    fileprivate lazy var adTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().mainThemeColor()
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .left
        return label
    }()
    
    @objc lazy var adIconView: UIImageView = {
        let iconView = UIImageView()
        return iconView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(adTextLabel)
        
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer.init { (tap) in
            if let action = self.tapAction {
                action(self.index)
            }
        }
        self.addGestureRecognizer(tapGesture)
        
        adTextLabel.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXNewStockCenterCell: UICollectionViewCell {
    
    @objc var cellStyle: YXNewStockCenterCellStyle = .normal {
        didSet {
            if cellStyle == .normal {
//                numLabel.isHidden = false
                adView.removeFromSuperview()
                blueView.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview().offset(10)
                    make.width.equalTo(3)
                    make.height.equalTo(8)
                    make.centerY.equalToSuperview()
                }
                
            }else {
//                numLabel.isHidden = true
                contentView.addSubview(adView)
                blueView.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview()
                    make.width.equalTo(3)
                    make.height.equalTo(8)
                    make.top.equalToSuperview().offset(15)
                }
                adView.snp.makeConstraints { (make) in
                    make.top.equalTo(blueView.snp.bottom).offset(10)
                    make.left.right.bottom.equalToSuperview()
                }
            }
        }
    }
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    fileprivate lazy var numLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    lazy var blueView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().mainThemeColor()
        return view
    }()
    
    fileprivate lazy var adView: UIView = {
        let adView = UIView()
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "bullbear_not_available")
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        adView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        return adView
    }()
    
    lazy var moreButton: QMUIButton = {
        let moreButton = QMUIButton()
        moreButton.spacingBetweenImageAndTitle = 3
        moreButton.imagePosition = .right
        moreButton.setTitle(YXLanguageUtility.kLang(key: "share_info_more"), for: .normal)
        moreButton.setImage(UIImage(named: "blue_bg_arrow"), for: .normal)
        moreButton.titleLabel?.font = .systemFont(ofSize: 12)
        moreButton.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        _ = moreButton.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            self?.moreBlock?()
        })
        return moreButton
    }()
    
    fileprivate lazy var adContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.addSubview(moreButton)
        moreButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        return view
    }()
    
    @objc var title: String? = nil {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    @objc var num: Int = 0 {
        didSet {
            self.numLabel.text = "\(num)"
        }
    }
    
    var adList: [YXMarketIPOAdItem]? = nil {
        didSet {
            
            for subview in self.adContainerView.subviews {
                if let view = subview as? YXNewStockCenterAdView {
                    view.removeFromSuperview()
                }
            }
            if let list = adList, list.count > 0 {
                var preView: UIView!
                for (index, item) in list.enumerated() {
    
                    let text = "\(item.companyName ?? "--")(\(item.symbolText()))"
                    
                    let adDetailView = YXNewStockCenterAdView()
                    adDetailView.adTextLabel.text = text
                    adDetailView.index = index
                    adDetailView.tapAction = { index in
                        if let block = self.gestureBlock {
                            block(index)
                        }
                    }
                    
                    self.adContainerView.addSubview(adDetailView)
                    
                    adDetailView.snp.makeConstraints { (make) in
                        make.left.equalToSuperview().offset(10)
                        make.right.equalToSuperview().offset(-5)
                        make.height.equalTo(20)
                        if list.count == 1 {
                            make.top.equalToSuperview().offset(13)
                        }else {
                            if index == 0 {
                                make.top.equalToSuperview().offset(1)
                            }else {
                                make.top.equalTo(preView.snp.bottom).offset(4)
                            }
                        }
                        
                    }
                    
                    preView = adDetailView
                }
                
                if self.adContainerView.superview == nil {
                    self.adView.addSubview(self.adContainerView)
                    self.adContainerView.snp.makeConstraints { (make) in
                        make.left.right.top.bottom.equalToSuperview()
                    }
                }
            }else {
                self.adContainerView.removeFromSuperview()
            }
        }
    }
    
    @objc var gestureBlock : ((_ index: Int) -> Void)?
    
    @objc var moreBlock : (() -> Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initializeViews() {
        
        contentView.addSubview(blueView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(numLabel)
        
        blueView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(3)
            make.height.equalTo(8)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(blueView.snp.right).offset(7)
            make.centerY.equalTo(blueView)
        }
        
        numLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalTo(titleLabel)
        }
    }
}
