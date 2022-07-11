//
//  YXNewStockPreMarketSortView.swift
//  uSmartOversea
//
//  Created by Kelvin on 2019/2/19.
//  Copyright © 2019年 RenRenDai. All rights reserved.
//

import UIKit

class YXNewStockPreMarketSortView: UIView {

    typealias dateSortTypeClosure = (_ sortState: Int, _ mobileBrifeType: YXMobileBrief1Type) -> Void
    @objc var sortClosure: dateSortTypeClosure?
    
    var dateSortType: Int = 1
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().backgroundColor()
        return view
    }()
    
    @objc lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "market_codeName")
        label.textColor = QMUITheme().textColorLevel2()//QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    @objc lazy var purchaseMoneyLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "market_publishPirce")
        label.textColor = QMUITheme().textColorLevel2()//QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    @objc lazy var marketDateButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "sort_ascending"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "expected_listing_time"), for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.addTarget(self, action: #selector(dateEndButtonEvent), for: .touchUpInside)
        button.spacingBetweenImageAndTitle = 3
        button.imagePosition = .right

        return button
    }()
    
    @objc func dateEndButtonEvent() -> Void {
        
        switch dateSortType {
        case 2:
            dateSortType = 1
            marketDateButton.setImage(UIImage(named: "sort_descending"), for: .normal)
            break
        case 1:
            dateSortType = 2
            marketDateButton.setImage(UIImage(named: "sort_ascending"), for: .normal)
            break
        default:
            break
        }
        if let closure = sortClosure {
            closure(dateSortType, .marketDays)
        }
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() -> Void {
        backgroundColor = QMUITheme().foregroundColor()
        addSubview(lineView)
        addSubview(nameLabel)
        addSubview(purchaseMoneyLabel)
        addSubview(marketDateButton)
        
        lineView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self)
            make.height.equalTo(1)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.left.equalTo(self.snp.left).offset(18)
        }
        
        
        marketDateButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-130)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(20)
            make.width.lessThanOrEqualTo(130)
        }
        
        purchaseMoneyLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.right.equalTo(self.snp.right).offset(-12)
        }
    }
}
