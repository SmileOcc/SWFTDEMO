//
//  YXNewStockMarketedSortView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXNewStockMarketedSortView: UIView {
    
    typealias YXSortBlock = (_ state: YXSortState, _ type: YXStockRankSortType) -> ()
    var sortTypes = [YXStockRankSortType]()
    var onClickSort: YXSortBlock?
    
    var buttons = [YXNewStockMarketedSortButton]()
    
    func setStatus(sortState: YXSortState, mobileBrief1Type: YXStockRankSortType) {
        
        for (_, button) in self.buttons.enumerated() {
            button.sortState = .normal
            if button.mobileBrief1Type == mobileBrief1Type {
                button.sortState = sortState
                self.onClickSort?(button.sortState, button.mobileBrief1Type)
            }
        }
    }
    
    @objc func sortButtonAction(sender: YXNewStockMarketedSortButton) {
        
        for (_, button) in self.buttons.enumerated() {
            if button.mobileBrief1Type == sender.mobileBrief1Type {
                if pageSource == .optionalList {
                    if sender.sortState == .descending {
                        sender.sortState = .ascending
                    } else if sender.sortState == .ascending {
                        sender.sortState = .normal
                    } else {
                        sender.sortState = .descending
                    }
                } else {
                    if sender.sortState != .descending {
                        sender.sortState = .descending
                    } else {
                        sender.sortState = .ascending
                    }
                }
            } else {
                button.sortState = .normal
            }
        }
        
        self.onClickSort?(sender.sortState, sender.mobileBrief1Type)
    }
    
    func scrollToSortType(sortType: YXStockRankSortType, animated: Bool) {
        let index = self.sortTypes.firstIndex(of: sortType) ?? 0
        let offsetX = Int(index - 1) * Int(config.itemWidth)
        self.scrollView.setContentOffset(CGPoint(x:offsetX > 0 ? offsetX : 0 , y: 0), animated: true)
    }
    
    //MARK: Initializition
    
    enum PageSource {
        case etf
        case market
        case warrants
        case holdList
        case optionalList
    }
    
    var pageSource: PageSource = .market
    
    var config: YXNewStockMarketConfig!
    
    init(frame: CGRect, sortTypes: [YXStockRankSortType], firstState: YXSortState? = .descending, source: PageSource = .market, config: YXNewStockMarketConfig) {
        super.init(frame: frame)
        self.sortTypes = sortTypes
        self.pageSource = source
        self.config = config
        for (index, value) in self.sortTypes.enumerated() {
            let button = YXNewStockMarketedSortButton.button(sortType: value, sortState: (index == 0 ? firstState ?? .normal : .normal))
            button.addTarget(self, action: #selector(sortButtonAction(sender:)), for: .touchUpInside)
            button.titleLabel?.numberOfLines = 2
            buttons.append(button)
        }
        initializeViews()
    }
    
    func initializeViews() {
        
        addSubview(nameLabel)
        addSubview(scrollView)
        
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(self.config.itemMargin)
            make.width.lessThanOrEqualTo(self.config.leftItemWidth - self.config.itemMargin)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(self.config.leftItemWidth + self.config.fixMargin)
            make.top.bottom.right.equalToSuperview()
        }
        
        self.backgroundColor = QMUITheme().foregroundColor()
        let width = self.config.itemWidth
        for (index, button) in self.buttons.enumerated() {
            scrollView.addSubview(button)
            
            button.snp.makeConstraints { (make) in
                make.centerY.equalTo(self)
                make.width.lessThanOrEqualTo(width - 2)
                make.right.equalTo(scrollView.snp.left).offset(width * CGFloat(index + 1))
                make.height.equalToSuperview()
            }
        }
        
        scrollView.contentSize = CGSize(width: width * CGFloat(buttons.count) + self.config.itemMargin, height: 40)
    }
    
    convenience init(sortTypes: [YXStockRankSortType], config: YXNewStockMarketConfig) {
        self.init(frame: CGRect.zero, sortTypes: sortTypes, config: config)
    }
    
    //MARK: lazy
    lazy var scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.showsHorizontalScrollIndicator = false
        return scrollview
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "market_codeName")
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

struct YXNewStockMarketConfig {
    let leftItemWidth: CGFloat //标题的宽度 = leftItemWidth - itemMargin
    let itemWidth: CGFloat //scrollView每个item的宽度
    let itemMargin: CGFloat //视图的左右间距
    let fixMargin: CGFloat //scrollView和标题之间的距离
    
    init(leftItemWidth: CGFloat = 118.0, itemWidth: CGFloat = 100.0, itemMargin: CGFloat = 16.0, fixMargin: CGFloat = 10.0) {
        self.leftItemWidth = leftItemWidth
        self.itemWidth = itemWidth
        self.itemMargin = itemMargin
        self.fixMargin = fixMargin
    }
}
