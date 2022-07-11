//
//  YXMarketFilterCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/2/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

class YXMarketFilterButton: QMUIButton {
    var type: YXStockRankSortType?
}

class YXMarketFilterCell: UICollectionReusableView, YXTabViewDelegate {
    
    var defaultSelectedItemButton: YXMarketFilterButton! // 默认选中的筛选项按钮
    var selectedFilterItemButton: YXMarketFilterButton! // 当前选中的筛选项按钮
    var selectedMoreFilterItemButton: YXMarketFilterButton! // 更多弹出界面选中的筛选项按钮
    var selectedFilterType: YXMobileBrief1Type = .roc // 当前选中的筛选项
    var moreItemButton: YXMarketFilterButton! // 点击触发弹出界面的按钮
    
    var tapFilterItemAction: ((_ direction: Int, _ type: YXStockRankSortType) -> Void)?
    var tapSortButtonAction: ((_ direction: Int, _ type: YXStockRankSortType) -> Void)?
    var tapMoreAction: (() -> Void)?
    let tapFilterSubject = PublishSubject<YXStockRankSortType>.init()
    let tapSortSubject = PublishSubject<YXStockRankSortType>.init()
    let filterItems: [YXStockRankSortType] = [.roc, .accer5, .volume, .amount, .mainInflow, .netInflow, .turnoverRate, .marketValue,.amp, .pe, .pb, .dividendYield, .volumeRatio]
    
    
    lazy var tabView: YXTabView = {
        let tabLayout = YXTabLayout.default()
        tabLayout.lineHidden = false
        tabLayout.lrMargin = 16
        tabLayout.tabMargin = 8
        tabLayout.tabPadding = 12
        tabLayout.lineHeight = 28
        tabLayout.leftAlign = true
        tabLayout.lineCornerRadius = 4
        tabLayout.lineColor = QMUITheme().themeTextColor().withAlphaComponent(0.1)
        tabLayout.linePadding = 6
        tabLayout.lineWidth = 0
        tabLayout.titleFont = .systemFont(ofSize: 14)
        tabLayout.titleSelectedFont = .systemFont(ofSize: 14)
        tabLayout.titleColor = QMUITheme().textColorLevel3()
        tabLayout.titleSelectedColor = QMUITheme().themeTextColor()
        tabLayout.isGradientTail = true
        tabLayout.gradientTailColor = QMUITheme().foregroundColor()
        let tabView = YXTabView(frame: .zero, with: tabLayout)
        tabView.backgroundColor = QMUITheme().foregroundColor()
        tabView.delegate = self
        tabView.titles = filterItems.map({ (sortType) -> String in
            return sortType.title
        })
        
        tabView.clipsToBounds = true
        
//        let gradientView = YXGradientLayerView()
//        gradientView.direction = .horizontal
//        gradientView.colors = [UIColor(hexString: "#FFFFFF")!.withAlphaComponent(0), UIColor(hexString: "#FFFFFF")!]
//        
//        tabView.addSubview(gradientView)
//        gradientView.snp.makeConstraints { (make) in
//            make.top.bottom.right.equalToSuperview()
//            make.width.equalTo(30)
//        }
        
        return tabView
    }()
    
    lazy var commonHeaderView: YXMarketCommonHeaderCell = {
        return YXMarketCommonHeaderCell()
    }()
    
    // 代码名称
    lazy var nameTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "market_codeName")
        return label
    }()
    
    lazy var delayLabel: UILabel = {
        let label = UILabel.delay()!
        label.isHidden = true
        label.text = YXLanguageUtility.kLang(key: "common_delay")
        return label
    }()
    
    // 最新价
    lazy var priceTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.text = YXLanguageUtility.kLang(key: "market_now")
        return label
    }()
    
    // 涨跌幅
    lazy var rocSortButton: YXNewStockMarketedSortButton = {
        let sortButton = YXNewStockMarketedSortButton.button(sortType: .roc, sortState: .descending)//YXNewStockMarketedSortButton.init(mobileBrief1Type: .roc, sortState: .descending)
        sortButton.sortState = .descending
        sortButton.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        sortButton.addTarget(self, action: #selector(tapSortButton(button:)), for: .touchUpInside)
        
        return sortButton
    }()
    
    // 其他排序指标
    lazy var sortButton: YXNewStockMarketedSortButton = {
        let sortButton = YXNewStockMarketedSortButton.button(sortType: .roc, sortState: .descending)//YXNewStockMarketedSortButton.init(mobileBrief1Type: .accer3, sortState: .descending)
        sortButton.addTarget(self, action: #selector(tapSortButton(button:)), for: .touchUpInside)
        sortButton.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        sortButton.titleLabel?.numberOfLines = 2
        sortButton.titleLabel?.textAlignment = .right
        sortButton.titleLabel?.font = .systemFont(ofSize: 12)
        return sortButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func filterButton(type: YXStockRankSortType) -> YXMarketFilterButton {
        let title = type.title
        let button = YXMarketFilterButton()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.setTitle(title, for: .normal)
        button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .selected)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.imagePosition = .right
        button.spacingBetweenImageAndTitle = 2
        if title.count > 16 {
            button.titleLabel?.numberOfLines = 2
        }
        button.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 3, bottom: 0, right: 3)

        button.type = type
        
        return button
    }
    
//    @objc func setButtonSelected(button: YXMarketFilterButton) {
//        if button.isSelected {
//            if button === moreItemButton {
//                popover.show(moreFilterView, from: button)
//            }
//        }else {
//            selectedFilterItemButton.isSelected = false
//            button.isSelected = true
//            selectedFilterItemButton = button
//
//            if button.type == .roc {
//                sortButton.isHidden = true
//                rocSortButton.snp.remakeConstraints { (make) in
//                    make.right.equalToSuperview().offset(-20)
//                    make.top.equalTo(nameTitleLabel)
//                }
//                rocSortButton.isUserInteractionEnabled = true
//            }else {
//                sortButton.isHidden = false
//                rocSortButton.sortState = .normal
//                rocSortButton.snp.remakeConstraints { (make) in
//                    make.right.equalToSuperview().offset(-115)
//                    make.top.equalTo(nameTitleLabel)
//                }
//
//                rocSortButton.setImage(nil, for: .normal)
//                rocSortButton.isUserInteractionEnabled = false
//            }
//            updateSortButton(filterButton: button)
//            if let action = tapFilterItemAction {
//                action(1, button.type ?? .roc)
//            }
//
//            tapFilterSubject.onNext(button.type ?? .roc)
//        }
//    }
    
//    @objc func setMoreFilterButtonSelected(button: YXMarketFilterButton) {
//        if button.isSelected {
//            return
//        }else {
//            self.selectedMoreFilterItemButton.isSelected = false
//            button.isSelected = true
//            self.selectedMoreFilterItemButton = button
//            moreItemButton.setTitle(button.titleLabel?.text, for: .normal)
//            moreItemButton.type = button.type
////            moreItemButton.setButtonImagePostion(.right, interval: 2)
//            updateSortButton(filterButton: button)
//
//            if let action = tapFilterItemAction {
//                action(1, button.type ?? .roc)
//            }
//        }
//
//        self.popover.dismiss()
//    }
    
    @objc func tapSortButton(button: YXNewStockMarketedSortButton) {
        var direction = 1
        if button.sortState == .descending {
            button.sortState = .ascending
            direction = 0
        }else {
            button.sortState = .descending
            direction = 1
        }
        if let action = tapSortButtonAction {
            action(direction, button.mobileBrief1Type)
        }
        tapSortSubject.onNext(button.mobileBrief1Type)
    }
    
    func updateSortButton(filterButton: YXMarketFilterButton) {
        var button = sortButton
        if filterButton.type == .roc {
            button = rocSortButton
        }
        button.mobileBrief1Type = filterButton.type ?? .roc
        button.sortState = .descending
//        button.setButtonImagePostion(.right, interval: 4)
    }
    
    func tabView(_ tabView: YXTabView, didSelectedItemAt index: UInt, withScrolling scrolling: Bool) {
        let selectedFilterItem = filterItems[Int(index)]
        if selectedFilterItem == sortButton.mobileBrief1Type {
            return
        }
        sortButton.mobileBrief1Type = selectedFilterItem
        sortButton.sortState = .descending
        tapFilterItemAction?(1, selectedFilterItem)
    }
    
    fileprivate func initializeViews() {
        
        addSubview(commonHeaderView)
        addSubview(tabView)
        addSubview(nameTitleLabel)
        addSubview(delayLabel)
        addSubview(priceTitleLabel)
        addSubview(sortButton)
        
        commonHeaderView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(40)
        }
        
        tabView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(commonHeaderView.snp.bottom)
            make.height.equalTo(40)
        }
        
        nameTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(tabView.snp.bottom).offset(8)
        }
        
        delayLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameTitleLabel.snp.right).offset(4)
            make.centerY.equalTo(nameTitleLabel)
        }
        
        priceTitleLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-130)
            make.centerY.equalTo(nameTitleLabel)
        }
        
        sortButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(nameTitleLabel)
            make.width.lessThanOrEqualTo(90)
            make.height.equalTo(40)
        }
    }
}
