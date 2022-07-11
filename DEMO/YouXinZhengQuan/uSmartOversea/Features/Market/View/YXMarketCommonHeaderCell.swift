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

class YXMarketCommonHeaderCell: UICollectionReusableView, HasDisposeBag {
    
    var action: (() -> Void)?
    
    @objc var icon: UIImage? = nil {
        didSet {
            self.iconView.image = icon
            if icon == nil {
                titleLabel.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview().offset(18)
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
        button.rx.tap.subscribe(onNext: { [weak self](_) in
            if let action = self?.action {
                action()
            }
        }).disposed(by: disposeBag)
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
        addSubview(subTitleLabel)
        addSubview(arrowView)
        addSubview(iconView)
        addSubview(redDotView)
        addSubview(button)
        
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalTo(self)
            make.width.lessThanOrEqualTo(YXConstant.screenWidth-70)
        }
        
        subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(10)
            make.centerY.equalTo(titleLabel)
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
    }
    
}


class YXGuessHeaderView: UICollectionReusableView {
    
    lazy var comonHeaderView: YXMarketCommonHeaderCell = {
        let view = YXMarketCommonHeaderCell()
        view.arrowView.isHidden = true
        return view
    }()
    
    lazy var refreshGuessButton: QMUIButton = {
        let button = QMUIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "change_refresh"), for: .normal)
        button.setImage(UIImage(named: "guess_refresh"), for: .normal)
        button.setTitleColor(QMUITheme().themeTextColor(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.spacingBetweenImageAndTitle = 3
        button.imagePosition = .left
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            
        })
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(comonHeaderView)
        addSubview(refreshGuessButton)
        
        comonHeaderView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        refreshGuessButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class YXMarketTabSectionHeader: UICollectionReusableView, HasDisposeBag {
    
    var action: (() -> Void)?
    var tabTitleAction: ((_ index: Int) -> Void)?
    
    var titles: [String] = [] {
        didSet {
            firstButton.setTitle(titles.first, for: .normal)
            secondButton.setTitle(titles.last, for: .normal)
        }
    }
    
    lazy var firstButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .selected)
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        button.rx.tap.subscribe(onNext: { [weak self](_) in
            if let action = self?.tabTitleAction {
                self?.firstButton.isSelected = true
                self?.secondButton.isSelected = false
                self?.firstButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
                self?.secondButton.titleLabel?.font = .systemFont(ofSize: 20)
                action(0)
            }
        }).disposed(by: disposeBag)
        return button
    }()
    
    lazy var secondButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .selected)
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        button.rx.tap.subscribe(onNext: { [weak self](_) in
            if let action = self?.tabTitleAction {
                self?.firstButton.isSelected = false
                self?.secondButton.isSelected = true
                self?.firstButton.titleLabel?.font = .systemFont(ofSize: 20)
                self?.secondButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
                action(1)
            }
        }).disposed(by: disposeBag)
        return button
    }()
    
    lazy var arrowView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "market_more_arrow")
        return imageView
    }()
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.rx.tap.subscribe(onNext: { [weak self](_) in
            if let action = self?.action {
                action()
            }
        }).disposed(by: disposeBag)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        firstButton.isSelected = true
        secondButton.isSelected = false
        
        firstButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        secondButton.titleLabel?.font = .systemFont(ofSize: 20)
        
        addSubview(arrowView)
        addSubview(button)
        addSubview(firstButton)
        addSubview(secondButton)
        
        
        firstButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalTo(self)
        }
        
        secondButton.snp.makeConstraints { (make) in
            make.left.equalTo(firstButton.snp.right).offset(16)
            make.centerY.equalTo(self)
        }
        
        arrowView.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-16)
            make.centerY.equalTo(self)
        }
        
        button.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
