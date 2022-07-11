//
//  YXMarketCollectionHeaderCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXMarketCollectionHeaderCell: UICollectionViewCell, HasDisposeBag {
    
    @objc var icon: UIImage? = nil {
        didSet {
            self.iconView.image = icon
            if icon == nil {
                titleLabel.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview().offset(18)
                    make.centerY.equalTo(self)
                }
            } else {
                titleLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(iconView.snp.right).offset(10)
                    make.centerY.equalTo(self)
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
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()
    
    fileprivate lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel3()
        return label
    }()
    
    fileprivate lazy var arrowView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "right_black_arrow")
        return imageView
    }()
    
    lazy var button: UIButton = {
        let button = UIButton()
//        button.rx.tap.subscribe(onNext: { [weak self](_) in
//            if let action = self?.action {
//                action()
//            }
//        }).disposed(by: disposeBag)
        return button
    }()
    
    fileprivate lazy var iconView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initializeViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(arrowView)
        contentView.addSubview(iconView)
        contentView.addSubview(redDotView)
        contentView.addSubview(button)
        
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(10)
            make.centerY.equalTo(self)
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
            make.right.equalTo(self).offset(-12)
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
