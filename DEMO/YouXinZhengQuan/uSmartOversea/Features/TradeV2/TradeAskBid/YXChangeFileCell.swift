//
//  YXChangeFileCell.swift
//  YouXinZhengQuan
//
//  Created by JC_Mac on 2019/1/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

@objcMembers class YXChangeFileCell: UITableViewCell {
    
    var quote : YXV2Quote?
    
    var askBidType = YXAskBidType.one
    lazy var buyFileLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    lazy var sellFileLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    @objc lazy var changeFileBtn: YXStockDetailAskBidPopoverButton = {
        let button = YXStockDetailAskBidPopoverButton(frame: .zero, titles: ["1", "5", "10"])
        
        button.setTitle("5", for: .normal)
        
        return button
    }()

    func initialUI() {
        
        self.selectionStyle = .none
        self.backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(buyFileLab)
        contentView.addSubview(sellFileLab)
        contentView.addSubview(changeFileBtn)
        
        buyFileLab.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(12)
            make.top.equalTo(self).offset(11)
        }
        
        sellFileLab.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-12)
            make.top.equalTo(self).offset(11)
        }
        
        changeFileBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(24)
            make.center.equalTo(self)
        }
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshUI() {
    
        switch self.askBidType {
        case .one  :
          self.changeFileBtn.setTitle("1", for: .normal)
        case .five :
            self.changeFileBtn.setTitle("5", for: .normal)
        default :
            self.changeFileBtn.setTitle("10", for: .normal)
        }

        
        buyFileLab.text = YXLanguageUtility.kLang(key: "stock_detail_bid_buy")
        sellFileLab.text = YXLanguageUtility.kLang(key: "stock_detail_ask_sell")
        
        if let quoteModel = quote,
            let market = quoteModel.market, market == YXMarketType.US.rawValue, let status = quoteModel.msInfo?.status?.value {
            if status == OBJECT_MARKETMarketStatus.msPreHours.rawValue {

                buyFileLab.text = YXLanguageUtility.kLang(key: "stock_detail_pre_bid")
                sellFileLab.text = YXLanguageUtility.kLang(key: "stock_detail_pre_ask")
            } else if status == OBJECT_MARKETMarketStatus.msAfterHours.rawValue ||
                status == OBJECT_MARKETMarketStatus.msClose.rawValue ||
                status == OBJECT_MARKETMarketStatus.msStart.rawValue {
                buyFileLab.text = YXLanguageUtility.kLang(key: "stock_detail_post_bid")
                sellFileLab.text = YXLanguageUtility.kLang(key: "stock_detail_post_ask")
            } else {
                buyFileLab.text = YXLanguageUtility.kLang(key: "stock_detail_bid_buy")
                sellFileLab.text = YXLanguageUtility.kLang(key: "stock_detail_ask_sell")
            }
        }
    }
}
