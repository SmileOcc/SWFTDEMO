//
//  YXBullBearSectionHeaderView.swift
//  uSmartOversea
//
//  Created by youxin on 2020/4/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXBullBearSectionHeaderView: UIView {
    
    var sectionType: YXBullBearContractSectionType
    
    lazy var commonHeader: YXMarketCommonHeaderCell = {
        let view = YXMarketCommonHeaderCell()
        view.icon = nil
        return view
    }()
    
    lazy var subTitleView: YXBullBearSectionHeaderSubTitleView = {
        let view = YXBullBearSectionHeaderSubTitleView.init(frame: CGRect.zero, sectionType: sectionType)
        return view
    }()
    
    init(frame: CGRect, type: YXBullBearContractSectionType) {
        sectionType = type
        super.init(frame: frame)
        
        self.backgroundColor = QMUITheme().foregroundColor()
        let line = UIView.line()
        addSubview(commonHeader)
        addSubview(line)
        addSubview(subTitleView)

        commonHeader.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(55)
        }
        line.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalTo(commonHeader)
        }
        subTitleView.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(14)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(22)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class YXBullBearSectionHeaderSubTitleView: UIView {
    lazy var subTitleLabel1: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var subTitleLabel2: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.numberOfLines = 2
        return label
    }()
    
    lazy var subTitleLabel3: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var subTitleLabel4: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.text = "--"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    init(frame: CGRect, sectionType: YXBullBearContractSectionType) {
        super.init(frame: frame)
        self.backgroundColor = QMUITheme().foregroundColor()
        
        switch sectionType {
        case .street:
            addSubview(subTitleLabel1)
            addSubview(subTitleLabel2)
            addSubview(subTitleLabel3)
            subTitleLabel1.text = YXLanguageUtility.kLang(key: "bullbear_usmart_highlight")
            subTitleLabel2.text = YXLanguageUtility.kLang(key: "bullbear_price_range")
            subTitleLabel3.text = YXLanguageUtility.kLang(key: "bullbear_ratio")
            subTitleLabel1.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(11)
                make.centerY.equalToSuperview()
                make.right.equalTo(subTitleLabel2.snp.left).offset(-10)
            }
            subTitleLabel2.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(133/375.0*YXConstant.screenWidth)
                make.centerY.equalTo(subTitleLabel1)
                make.right.equalTo(subTitleLabel3.snp.left).offset(-15)
            }
            subTitleLabel3.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(226/375.0*YXConstant.screenWidth)
                make.centerY.equalTo(subTitleLabel1)
                make.right.equalToSuperview().offset(-5)
            }
        
        case .longShortSignal:
            subTitleLabel1.text = YXLanguageUtility.kLang(key: "stock_deal_time")
            subTitleLabel2.text = YXLanguageUtility.kLang(key: "bullbear_signal_category")
            subTitleLabel3.text = YXLanguageUtility.kLang(key: "bullbear_usmart_highlight")
            let stackView = UIStackView.init(arrangedSubviews: [subTitleLabel1, subTitleLabel2, subTitleLabel3])
            stackView.alignment = .top
            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            addSubview(stackView)
            
            subTitleLabel1.snp.makeConstraints { (make) in
                make.width.equalTo(80)
            }
            
            subTitleLabel2.snp.makeConstraints { (make) in
                make.width.equalTo((YXConstant.screenWidth - 80)*2/3)
            }
            
            subTitleLabel3.snp.makeConstraints { (make) in
                make.width.equalTo((YXConstant.screenWidth - 80)/3)
            }
            
            stackView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(11)
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-11)
            }
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
