//
//  YXWarrantsEntranceCell.swift
//  uSmartOversea
//
//  Created by youxin on 2019/9/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

enum YXWarrantsEntranceType {
    case warrantsCBBC
    case marketMakerScore
    case warrantsDayReport
    case warrantsCollege
    
    var title: String {
        switch self {
        case .warrantsCBBC:
            return YXLanguageUtility.kLang(key: "warrants_entrance")
        case .marketMakerScore:
            return YXLanguageUtility.kLang(key: "issuer_rating")
        case .warrantsDayReport:
            return YXLanguageUtility.kLang(key: "warrant_home_day_report")
        case .warrantsCollege:
            return YXLanguageUtility.kLang(key: "warrant_hoem_college")
        
        }
    }
    
    var image: UIImage {
        switch self {
        case .warrantsCBBC:
            return UIImage(named: "market_warrants_blue") ?? UIImage()
        case .marketMakerScore:
            return UIImage(named: "marketMaker_score_entrance") ?? UIImage()
        case .warrantsDayReport:
            return UIImage(named: "warrant_dayreport") ?? UIImage()
        case .warrantsCollege:
            return UIImage(named: "warrant_college") ?? UIImage()
        
        }
    }
}

class YXWarrantsEntranceCell: UICollectionViewCell {
    
    var tapAction: ((_ entranceType: YXWarrantsEntranceType) -> Void)?
    
    lazy var item: QMUIButton = {
        let button = QMUIButton()
        button.spacingBetweenImageAndTitle = 5
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        button.imagePosition = .top
        return button
    }()
    
    @objc lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = QMUITheme().textColorLevel1()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    @objc lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    fileprivate lazy var arrowView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "right_black_arrow")
        return imageView
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
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(arrowView)
//        contentView.addSubview(iconImageView)
        
        let stackView = UIStackView.init()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
        let items: [YXWarrantsEntranceType] = [.warrantsCBBC, .marketMakerScore, .warrantsDayReport, .warrantsCollege]
        
        items.forEach { (item) in
            
            let button = QMUIButton()
            button.spacingBetweenImageAndTitle = 5
            button.titleLabel?.font = .systemFont(ofSize: 12)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.3
            button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
            button.imagePosition = .top
            button.setTitle(item.title, for: .normal)
            button.setImage(item.image, for: .normal)
            
            _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe { [weak self](e) in
                self?.tapAction?(item)
            }

            
            stackView.addArrangedSubview(button)
        }
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
//        iconImageView.snp.makeConstraints { (make) in
//            make.left.equalTo(self).offset(12)
//            make.centerY.equalTo(self)
//            make.width.height.equalTo(20)
//        }
//
//        titleLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(iconImageView.snp.right).offset(10)
//            make.right.equalTo(arrowView.snp.left)
//            make.centerY.equalTo(self)
//        }
//
//        arrowView.snp.makeConstraints { (make) in
//            make.right.equalTo(self).offset(-12)
//            make.centerY.equalTo(self)
//        }
    }
    
}
