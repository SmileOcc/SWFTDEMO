//
//  YXWarrantsMarketedSortView.swift
//  uSmartOversea
//
//  Created by 井超 on 2019/8/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXWarrantsMarketedSortView: YXNewStockMarketedSortView {
    var securityType: YXSecurityType? {
        didSet {
            if securityType == .stock {
                nameLabel.text = YXLanguageUtility.kLang(key: "market_codeName")
//                let width = YXNewStockMarketConfig.itemWidth
//                for (index, button) in self.buttons.enumerated() {
//                    button.snp.remakeConstraints { (make) in
//                        make.centerY.equalToSuperview()
//                        make.width.equalTo(width - 10)
//                        make.left.equalToSuperview().offset(width * CGFloat(index) + 10 + 10)
//                    }
//                }
//                scrollView.contentSize = CGSize(width: width * CGFloat(buttons.count) + YXNewStockMarketConfig.itemMargin, height: self.frame.height)
            }else if securityType == .bond {
                nameLabel.text = YXLanguageUtility.kLang(key: "bond_name")
            }
            
        }
    }
    override func sortButtonAction(sender: YXNewStockMarketedSortButton) {
        
        for (_, button) in self.buttons.enumerated() {
            if button.mobileBrief1Type == sender.mobileBrief1Type {
                if sender.sortState == .normal {
                    sender.sortState = .descending
                } else if sender.sortState == .descending {
                    sender.sortState = .ascending
                } else {
                    sender.sortState = .normal
                }
            } else {
                button.sortState = .normal
            }
        }
        
        self.onClickSort?(sender.sortState, sender.mobileBrief1Type)
    }
    
    func sortRocDescending() {
        for (_, button) in self.buttons.enumerated() {
            button.sortState = YXSortState.normal
            if button.mobileBrief1Type == .roc {
                button.sortState = .descending
            }
        }
    }
    
    func setDefaultSortTypeDescending(sortType: YXStockRankSortType) {
        for (_, button) in self.buttons.enumerated() {
            button.sortState = YXSortState.normal
            if button.mobileBrief1Type == sortType {
                button.sortState = .descending
            }
        }
    }
    
    
    func warrantResetViewFrame() {
        nameLabel.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(self.config.itemMargin)
            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.itemMargin)
        }
        
        scrollView.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(self.config.leftItemWidth + self.config.fixMargin)
            make.top.bottom.right.equalToSuperview()
        }
    
        self.backgroundColor = QMUITheme().foregroundColor()
        var width: CGFloat = self.config.itemWidth
        var totalWidth: CGFloat = 0
        for (index, button) in self.buttons.enumerated() {
            
            width = self.config.itemWidth
            if button.mobileBrief1Type == .endDate, YXUserManager.isENMode() {
                width = self.config.itemWidth + 20
            } else if button.mobileBrief1Type == .yxScore {
                width = self.config.itemWidth - 20
            }
  
            button.snp.remakeConstraints { (make) in
                make.centerY.equalTo(self)
                make.width.equalTo(width - 2)
                make.right.equalTo(scrollView.snp.left).offset(width + totalWidth)
                make.height.equalToSuperview()
            }
            
            totalWidth += width
        }
        
        scrollView.contentSize = CGSize(width: totalWidth + self.config.itemMargin, height: self.frame.height)
        
    }
}
