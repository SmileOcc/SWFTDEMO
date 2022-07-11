//
//  YXStatementHeaderView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import QMUIKit

class YXStatementHeaderView: UIView {
    
    
    var statementAccountType: TradeStatementAccountType = .stock
    
    var statementType: TradeStatementType = .all
    
    var statementTimeType: TradeStatementTimeType = .threeMonth
    
    var currentBeginDate: Date?
    var currentEndDate: Date?
    
    typealias FilterBlock = () -> Void
    var clickAccountFileter:((TradeStatementAccountType) -> Void)?
    var clickStatementFileter:((TradeStatementType) -> Void)?
    var clickTimeFilter:((TradeStatementTimeType, Date?, Date?) -> Void)?
    
    
    func filterButton() -> YXHistoryFilterButton {
        let filter = YXHistoryFilterButton(type: .custom)
        filter.titleLabel?.adjustsFontSizeToFitWidth = true
        filter.titleLabel?.minimumScaleFactor = 0.3
        filter.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        filter.setTitleColor(QMUITheme().themeTextColor(), for: .selected)
        filter.setTitleColor(QMUITheme().themeTextColor(), for: .highlighted)
        
        filter.setImage(UIImage(named: "icon_all_order_down"), for: .normal)
        filter.setImage(UIImage(named: "icon_all_order_down_select"), for: .selected)
        filter.setImage(UIImage(named: "icon_all_order_down_select"), for: .highlighted)
        return filter
    }
    
    // 装所有下拉菜单按钮的stackview
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 9

        return stackView
    }()
    
    // 取消所有菜单下拉按钮的选中状态
    @objc func unSelectedAllFilterButton() {
        for view in stackView.arrangedSubviews {
            if let btn = view as? YXHistoryFilterButton {
                btn.isSelected = false
            }
        }
    }

    // 隐藏所有的筛选面板
    @objc func hideAllFilterView() {
        accountFilterView.isHidden = true
        statementFilterView.isHidden = true
        timeFilterView.isHidden = true
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superView = self.superview {
            superView.insertSubview(accountFilterView, belowSubview: self)
            superView.insertSubview(statementFilterView, belowSubview: self)
            superView.insertSubview(timeFilterView, belowSubview: self)
            
            accountFilterView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(stackView.snp.bottom)
            }
            
            statementFilterView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(stackView.snp.bottom)
            }
            
            timeFilterView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(stackView.snp.bottom)
            }
            
        }
    }
    
    lazy var accountFilter: YXHistoryFilterButton = {
        let button = filterButton()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.qmui_tapBlock = { [weak self] sender in
            guard let `self` = self else { return }
            
            self.unSelectedAllFilterButton()
            sender?.isSelected = true
            
            if self.accountFilterView.isHidden {
                self.hideAllFilterView()
                self.accountFilterView.show(accountType: self.statementAccountType)
            }else {
                self.accountFilterView.hidden()
                self.unSelectedAllFilterButton()
            }
        }
        return button
    }()
    
    private func setupAccountFilter() {
        accountFilter.setTitle(statementAccountType.text, for: .normal)
    }

    lazy var accountFilterView:YXStatementAccountFilterView = {
        let arr:[TradeStatementAccountType] = [.stock]
        let filterView = YXStatementAccountFilterView.init(frame: .zero, types: arr)
        filterView.isHidden = true
        filterView.selectedBlock = {[weak self, weak filterView] type in
            guard let `self` = self else { return }

            self.statementAccountType = type
            self.clickAccountFileter?(type)
            self.layoutIfNeeded()
            filterView?.hidden()
            self.unSelectedAllFilterButton()
            self.setupAccountFilter()
        }
        return filterView
    }()
    
    lazy var statementTypeFilter: YXHistoryFilterButton = {
        let button = filterButton()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.qmui_tapBlock = { [weak self] sender in
            guard let `self` = self else { return }
            
            self.unSelectedAllFilterButton()
            sender?.isSelected = true
            
            if self.statementFilterView.isHidden {
                self.hideAllFilterView()
                self.statementFilterView.show(statementType: self.statementType)
            }else {
                self.statementFilterView.hidden()
                self.unSelectedAllFilterButton()
            }
        }
        return button
    }()
    
    private func setupStatementTypeFilter() {
        statementTypeFilter.setTitle(statementType.text, for: .normal)
    }
    
    lazy var statementFilterView:YXStatementFilterView = {
        let arr:[TradeStatementType] = [.all, .day, .month]
        let filterView = YXStatementFilterView.init(frame: .zero, types: arr)
        filterView.isHidden = true
        filterView.selectedBlock = {[weak self, weak filterView] type in
            guard let `self` = self else { return }

            
            self.timeFilterView.statmentType = type
            self.statementType = type
            self.clickStatementFileter?(type)
            self.layoutIfNeeded()
            filterView?.hidden()
            self.unSelectedAllFilterButton()
            self.setupStatementTypeFilter()
        }
        return filterView
    }()

    lazy var timeFilter: YXHistoryFilterButton = {
        let button = filterButton()
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        button.qmui_tapBlock = { [weak self] sender in
            guard let `self` = self else { return }
            
            self.unSelectedAllFilterButton()
            sender?.isSelected = true
            
            if self.timeFilterView.isHidden {
                self.hideAllFilterView()
                self.timeFilterView.showFilterCondition()
            }else {
                self.timeFilterView.hideFilterCondition()
                self.unSelectedAllFilterButton()
            }
        }
        return button    }()
    
    lazy var timeFilterView: YXStatementTimeFilterView = {
        let filterView = YXStatementTimeFilterView.init(defaultSelectedType: .threeMonth)
        filterView.statmentType = .all
        filterView.isHidden = true
        filterView.filter = { [ weak self] type, beginDate, endDate in
            guard let `self` = self else { return }
            var filterBeginDate: Date?
            var filterEndDate: Date?
            
            if type == .custom {
                if let beginDate = beginDate, let endDate = endDate {
                    filterBeginDate = beginDate
                    filterEndDate = endDate
                }
            }

            self.statementTimeType = type
            self.currentBeginDate = beginDate
            self.currentEndDate = endDate

            self.clickTimeFilter?(type, filterBeginDate, filterEndDate)
            self.layoutIfNeeded()
            self.unSelectedAllFilterButton()
            self.setupTimeFilter()
        }
        return filterView
    }()
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    private func setupTimeFilter() {
        timeFilter.setTitle(statementTimeType.text, for: .normal)
        
//        if let beginDate = currentBeginDate, let endDate = currentEndDate {
//            let filterBeginDate = self.formatter.string(from: beginDate)
//            let filterEndDate = self.formatter.string(from: endDate)
//            let string = "\(filterBeginDate)-\n\(filterEndDate)"
//            timeFilter.setTitle(string, for: .normal)
//        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        setupAccountFilter()
        setupStatementTypeFilter()
        setupTimeFilter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.height.equalTo(40)
        }
        
        stackView.addArrangedSubview(accountFilter)
        stackView.addArrangedSubview(statementTypeFilter)
        stackView.addArrangedSubview(timeFilter)
        
        accountFilter.snp.makeConstraints { (make) in
            make.width.lessThanOrEqualTo(YXConstant.screenWidth/3.0)
        }
        
        statementTypeFilter.snp.makeConstraints { (make) in
            make.width.lessThanOrEqualTo(YXConstant.screenWidth/3.0)
        }
        
        timeFilter.snp.makeConstraints { (make) in
            make.width.lessThanOrEqualTo(YXConstant.screenWidth/3.0)
        }
        
        let lineView = UIView.line()
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
  
    
}
