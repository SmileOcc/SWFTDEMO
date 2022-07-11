//
//  YXOrderFilterView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2020/4/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

@objc enum YXOrderFilterType: Int {
    case allOrder
    case conditionOrder
    case smartOrder
    case intradayHold
    case optionOrder
    case shortOrder
}

class YXOrderFilterView: UIView {

    var filterType: YXOrderFilterType

    var exchangeType: YXExchangeType

    var currentSecurityType: YXOrderSecurityFilterType

    var currentStatus: YXOrderFilterStatus

    var currentSmartOrderType: YXSmartOrderFilterType?

    var currentDateFlag: YXHistoryDateType
    var currentBeginDate: Date?
    var currentEndDate: Date?
    
    var orderStatusFilterAction:((_ orderStatus: YXOrderFilterStatus) -> Void)?

    @objc var filterConditionAction:((_ securityType: String, _ orderStatus: String, _ orderType: String) -> Void)?

    @objc var orderStatusValueFilterAction:((_ orderStatus: String) -> Void)?

    @objc var stockFilterAction:((_ stock: YXSearchItem) -> Void)?
    
    @objc var allSotckButtonAction:((_ btn: QMUIButton) -> Void)?
    
    @objc var dateFilterAction:((_ dateFlag: String, _ beginDate: String, _ endDate: String) -> Void)?

    lazy var orderFilter: YXHistoryFilterButton = {
        let button = filterButton()
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self, weak button] (btn) in
            guard let `self` = self else { return }
            
            self.unSelectedAllFilterButton()
            button?.isSelected = true
            
            if self.orderFilterView.isHidden {
                self.hideAllFilterView()
                self.orderFilterView.show(
                    withSecurityType: self.currentSecurityType,
                    orderStatus: self.currentStatus,
                    orderType: self.currentSmartOrderType
                )
            }else {
                self.orderFilterView.hidden()
                self.unSelectedAllFilterButton()
            }
        })
        return button
    }()

    lazy var orderFilterView: YXOrderMutipleConditionsFilterView = {
        let filterView = YXOrderMutipleConditionsFilterView.init(frame: frame, type: self.filterType)
        filterView.isHidden = true
        filterView.didSelectConditionBlock = { [weak self, weak filterView] (securityType, orderStatus, orderType) in
            guard let `self` = self else { return }

            self.currentSecurityType = securityType
            self.currentStatus = orderStatus
            self.currentSmartOrderType = orderType

            let securityTypeRequestVlaue = securityType.requestValue(self.filterType)
            let orderStatusRequestValue = orderStatus.requestValue(self.filterType)
            self.filterConditionAction?(securityTypeRequestVlaue, orderStatusRequestValue, orderType?.requestValue ?? "")

            self.layoutIfNeeded()
            filterView?.hidden()
            self.unSelectedAllFilterButton()
            self.setupOrderFilter()
        }

        filterView.didHideBlock = { [weak self] _ in
            self?.unSelectedAllFilterButton()
        }

        return filterView
    }()
    
    // 股票搜索态菜单下拉按钮
    @objc lazy var stockFilter: YXHistoryFilterButton = {
        let button = filterButton()
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self, weak button] (btn) in
            guard let `self` = self else { return }
            
            self.unSelectedAllFilterButton()
            button?.isSelected = true
            
            if self.stockFilterView.isHidden {
                self.hideAllFilterView()
                self.stockFilterView.show()
            }else {
                self.stockFilterView.hidden()
                self.unSelectedAllFilterButton()
            }
            
        })
        return button
    }()
    
    // 日期态菜单下拉按钮
    @objc lazy var dateFilter: YXHistoryFilterButton = {
        let button = filterButton()
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.3
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self, weak button] (btn) in
            guard let `self` = self else { return }
            
            self.unSelectedAllFilterButton()
            button?.isSelected = true
            
            if self.dateFilterView.isHidden {
                self.hideAllFilterView()
                self.dateFilterView.showFilterCondition()
            }else {
                self.dateFilterView.hideFilterCondition()
                self.unSelectedAllFilterButton()
            }
        })
        return button
    }()
    
    // 装所有下拉菜单按钮的stackview
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 9
        
        return stackView
    }()

    // 搜索股票筛选面板
    @objc lazy var stockFilterView: YXStockFilterView = {
        let view = YXStockFilterView()
        view.isHidden = true
        //监听点击cell
        _ = view.searchViewModel.resultViewModel.cellDidSelected.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self, weak view](item) in
            view?.hidden()
            if let action = self?.stockFilterAction {
                action(item)
            }
            self?.layoutIfNeeded()
        })
        _ = view.allStockButton.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self, weak view](btn) in
            guard let view = view else { return }

            if view.allStockButton.isSelected {
                
            }else {
                self?.hideAllFilterView()
                view.hideResultView()
                self?.layoutIfNeeded()

                self?.setupStockFilter()
            }
            view.allStockButton.isSelected = !view.allStockButton.isSelected
            view.searchBar.textField.text = ""
            if let action = self?.allSotckButtonAction {
                action(view.allStockButton)
            }
        })

        view.didHideBlock = { [weak self] _ in
            self?.unSelectedAllFilterButton()
        }

        return view
    }()
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter.en_US_POSIX()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    // 日期筛选面板
    @objc lazy var dateFilterView: YXDateFilterView = {
        let dateFilter = YXDateFilterView.init(style: YXDateFilterView.YXDateFilterStyle.order, defaultSelectedIndex: self.currentDateFlag.orderIndex)
        dateFilter.isHidden = true
        dateFilter.filter = {[weak self] tag, beginDate, endDate in
            guard let `self` = self else { return }
            var dateFlag: YXHistoryDateType = .Week
            var filterBeginDate = ""
            var filterEndDate = ""
            
            if tag == YXHistoryDateType.Today.orderIndex {
                dateFlag = YXHistoryDateType.Today
            }else if tag == YXHistoryDateType.Week.orderIndex {
                dateFlag = YXHistoryDateType.Week
            }else if tag == YXHistoryDateType.LastMonth.orderIndex {
                dateFlag = YXHistoryDateType.LastMonth
            } else if tag == YXHistoryDateType.LastThreeMonth.orderIndex {
                dateFlag = YXHistoryDateType.LastThreeMonth
            } else if tag == YXHistoryDateType.LastYear.orderIndex {
                dateFlag = YXHistoryDateType.LastYear
            } else if tag == YXHistoryDateType.WithinThisYear.orderIndex {
                dateFlag = YXHistoryDateType.WithinThisYear
            } else if tag == YXHistoryDateType.Custom.orderIndex {
                dateFlag = YXHistoryDateType.Custom

                if let beginDate = beginDate, let endDate = endDate {
                    filterBeginDate = self.formatter.string(from: beginDate)
                    filterEndDate = self.formatter.string(from: endDate)
                }
            }

            self.currentDateFlag = dateFlag
            self.currentBeginDate = beginDate
            self.currentEndDate = endDate

            self.setupDateFilter()

            self.layoutIfNeeded()
            
            if let action = self.dateFilterAction {
                if self.filterType == .smartOrder {
                    action(dateFlag.smartOrderFilterRequestValue, filterBeginDate, filterEndDate)
                } else {
                    action(dateFlag.orderFilterRequestValue, filterBeginDate, filterEndDate)
                }
            }

            self.unSelectedAllFilterButton()
        }

        dateFilter.didHideBlock = { [weak self] _ in
            self?.unSelectedAllFilterButton()
        }

        return dateFilter
    }()
    
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
    
    @objc func updateStockFilterButtonTitle(title: String) {
        stockFilter.setTitle(title, for: .normal)
        stockFilterView.allStockButton.isSelected = false
        self.layoutIfNeeded()
    }
    
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
        self.orderFilterView.isHidden = true
        self.stockFilterView.isHidden = true
        self.dateFilterView.isHidden = true
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superView = self.superview {
            superView.insertSubview(self.orderFilterView, belowSubview: self)
            superView.insertSubview(self.stockFilterView, belowSubview: self)
            superView.insertSubview(self.dateFilterView, belowSubview: self)
            
            self.orderFilterView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(stackView.snp.bottom)
            }
            
            self.stockFilterView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(stackView.snp.bottom)
            }
            
            self.dateFilterView.snp.makeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(stackView.snp.bottom)
            }
        }
    }
    
    @objc init(frame: CGRect, type: YXOrderFilterType, exchangeType: YXExchangeType = .hk) {
        self.filterType = type
        self.exchangeType = exchangeType
        self.currentSecurityType = .all

        if type == .smartOrder {
            self.currentStatus = .active
            self.currentSmartOrderType = .all
        } else {
            self.currentStatus = .all
        }

        if type == .smartOrder {
            self.currentDateFlag = .LastThreeMonth
        } else {
            self.currentDateFlag = .Week
        }

        super.init(frame: frame)

        self.backgroundColor = QMUITheme().foregroundColor()

        initSubviews()

        setupOrderFilter()
        setupDateFilter()
        setupStockFilter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.height.equalTo(57)
        }

        stackView.addArrangedSubview(orderFilter)
        stackView.addArrangedSubview(dateFilter)
        stackView.addArrangedSubview(stockFilter)

        stockFilter.snp.makeConstraints { (make) in
            make.width.lessThanOrEqualTo(YXConstant.screenWidth/2.0)
        }

        let lineView = UIView.line()
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    private func setupOrderFilter() {
        let isAll =
            currentSecurityType == .all
            && currentStatus == .all
            && (currentSmartOrderType == .all || currentSmartOrderType == nil)

        orderFilter.setTitle(
            isAll ? YXLanguageUtility.kLang(key: "orderfilter_all_order") : YXLanguageUtility.kLang(key: "orderfilter_filter_result"),
            for: .normal
        )
    }

    private func setupStockFilter() {
        if filterType == .optionOrder {
            stockFilter.setTitle(YXLanguageUtility.kLang(key: "options_all_options"), for: .normal)
        } else {
            stockFilter.setTitle(YXLanguageUtility.kLang(key: "orderfilter_all_stock"), for: .normal)
        }
    }

    private func setupDateFilter() {
        dateFilter.setTitle(currentDateFlag.title, for: .normal)

        if let beginDate = currentBeginDate, let endDate = currentEndDate {
            let filterBeginDate = self.formatter.string(from: beginDate)
            let filterEndDate = self.formatter.string(from: endDate)
            let string = "\(filterBeginDate)-\n\(filterEndDate)"
            self.dateFilter.setTitle(string, for: .normal)
        }
    }

    @objc func resetStockFilter() {
        setupStockFilter()
        stockFilterView.allStockButton.isSelected = true
    }
}


