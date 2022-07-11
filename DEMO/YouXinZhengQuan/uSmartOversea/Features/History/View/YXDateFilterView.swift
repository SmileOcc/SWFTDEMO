//
//  YXHistoryDateFilterView.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import YXKit

class YXDateFilterView: UIControl {
    let bag = DisposeBag()
    
    @objc var didHideBlock: ((Bool) -> Void)?

    @objc public enum YXDateFilterStyle: Int {
        // history：历史记录【出金、入金、货币兑换】
        // order：订单记录
        case history, order
    }
    
    var style: YXDateFilterStyle = .history
    
    var isExpanded: Bool = false {
        didSet {
            if isExpanded {
                // 显示datePicker
                self.unfoldDatePicker()
            } else {
                // 隐藏datePicker
                self.foldDatePicker()
            }
        }
    }
    
    @objc var selectedBtnIndex: Int = YXHistoryDateType.All.index
    var tempSelectedBtnIndex: Int = 0 // 当点击dateflag按钮时，记录用户选中了哪个按钮，如果用户最终点击了取消，则需要把dateflag按钮回复到之前的（selectedBtnIndex）状态
    
    var systemDate: String = "" {
        didSet {
            if self.style == .history {
                let date = self.formatter.date(from: self.systemDate)
                let minDate = self.formatter.date(from: "2019-01-01")
                var maxDate: Date?
                var beginDate: Date?
                
                self.beginDatePicker.minimumDate = minDate
                self.endDatePicker.minimumDate = minDate
                if date == nil || (date != nil && minDate != nil && date?.compare(minDate!) == .orderedAscending) {
                    // 如果服务器系统时间为空，或者服务器时间小于2019年，则设置为手机时间
                    // 如果手机时间小于2019年，则取最小值为2019年01月01日，最大值为2019年12月31日
                    // 如果手机时间大于或等于2019年，则取最小值为2019年01月01日，最大值为手机当前时间
                    let now = Date()
                    beginDate = now
                    if now.compare(minDate!) == .orderedAscending {
                        maxDate = self.formatter.date(from: "2019-12-31")
                    } else {
                        maxDate = now
                    }
                } else {
                    // 如果服务器系统时间不为空，且服务器时间大于或等于2019年，则取最小值为2019年01月01日，最大值为服务器系统时间
                    maxDate = date
                    beginDate = date
                }
                
                self.beginDatePicker.maximumDate = maxDate
                self.endDatePicker.maximumDate = maxDate
                
                // 设置时间选择器的当前日期
                // 如果开始时间的日期小于最小日期时，需要重新设置一下时间选择器的当前时间
                if self.beginButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_start_date") || self.beginDatePicker.date.compare(minDate!) == .orderedAscending {
                    self.beginDatePicker.date = beginDate!
                    
                    // 同时，如果开始日期的Button文字不是开始日期时，则也重新设置一下Button的文字
                    if self.beginButton.titleLabel?.text != YXLanguageUtility.kLang(key: "history_start_date") {
                        self.beginButton.setTitle(self.formatter.string(from: minDate!), for: .normal)
                    }
                }
                
                // 如果当前结束日期的Button文字是”结束日期“，或者结束日期的时间选择器的时间大于最大时间时，则需要重置一下结束日期时间选择器的当前时间
                if self.endButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_end_date") || self.endDatePicker.date.compare(maxDate ?? Date()) == .orderedDescending {
                    self.endDatePicker.date = maxDate ?? Date()
                    self.endButton.setTitle(self.formatter.string(from: maxDate ?? Date()), for: .normal)
                }
            }
        }
    }
    
    var beginDate: Date?, endDate: Date?
    var originBeginDate: Date?, originEndDate: Date?
    
    // 历史记录最长可查询5年，订单最长可查询1年
    var timeRange: TimeInterval {
        get {
            if self.style == .history {
                let fiveYear = ((5 * 365) - 1)
                let secondsPerDay = (24 * 60 * 60)
                return TimeInterval(fiveYear * secondsPerDay)
            } else {
                return 1 * 365 * 24 * 60 * 60
            }
        }
    }
    
    @objc var filter:((_ tag: Int, _ beginDate: Date?, _ endDate: Date?) -> Void)?
    
    var timeButtons: [YXDateFilterButton] = [YXDateFilterButton]()
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter.en_US_POSIX()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    lazy var container: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = self.contentColor
        return view
    }()

    lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = self.contentColor
        return contentView
    }()
    
    lazy var topSectionContainer: UIView = {
        let container = UIView()
        container.backgroundColor = self.contentColor
        return container
    }()
    
    lazy var filterButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    
    lazy var timeRangeLabel: UILabel = {
        let timeRangeLabel = UILabel()
        timeRangeLabel.text = self.timeRangeText
        timeRangeLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        timeRangeLabel.textColor = self.titleColor
        return timeRangeLabel
    }()
    
    lazy var customLabel: UILabel = {
        let customLabel = UILabel()
        customLabel.text = YXLanguageUtility.kLang(key: "history_custom_date")
        customLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        customLabel.textColor = self.titleColor
        return customLabel
    }()
    
    @objc lazy var customTipsLabel: UILabel = {
        let customTipsLabel = UILabel()
        customTipsLabel.text = YXLanguageUtility.kLang(key: "history_custom_date_tips")
        customTipsLabel.font = UIFont.systemFont(ofSize: 12)
        customTipsLabel.textColor = UIColor(red: 0.35, green: 0.41, blue: 0.5, alpha: 1)
        customTipsLabel.textAlignment = .right
        return customTipsLabel
    }()
    
    lazy var timeContainerView: UIView = {
        let timeContainerView = UIView()
        timeContainerView.backgroundColor = self.contentColor
        return timeContainerView
    }()
    
    lazy var toLabel: UILabel = {
        let toLabel = UILabel()
        toLabel.text = YXLanguageUtility.kLang(key: "history_to")
        toLabel.font = UIFont.systemFont(ofSize: 14)
        toLabel.textColor = self.toLabelTextColor
        return toLabel
    }()
    
    lazy var beginButton: YXDateFilterButton = {
        let beginButton = YXDateFilterButton(style: self.dateFilterButtonStyle)
        beginButton.setTitle(YXLanguageUtility.kLang(key: "history_start_date"), for: .normal)
        beginButton.setTitleColor(self.timeButtonTitleColor, for: .normal)
        beginButton.setTitleColor(self.timeButtonSelectedTitleColor, for: .selected)
        return beginButton
    }()
    
    lazy var endButton: YXDateFilterButton = {
        let endButton = YXDateFilterButton(style: self.dateFilterButtonStyle)
        endButton.setTitle(YXLanguageUtility.kLang(key: "history_end_date"), for: .normal)
        endButton.setTitleColor(self.timeButtonTitleColor, for: .normal)
        endButton.setTitleColor(self.timeButtonSelectedTitleColor, for: .selected)
        return endButton
    }()
    
    lazy var actionContainerView: UIView = {
        let actionContainerView = UIView()
        actionContainerView.backgroundColor = self.contentColor
        return actionContainerView
    }()
    
    lazy var cancelButton: QMUIButton = {
        let cancelButton = QMUIButton()
        cancelButton.setTitle(self.cancelButtonText, for: .normal)
        cancelButton.setTitleColor(self.cancelButtonTitleColor, for: .normal)
        cancelButton.backgroundColor = self.cancelButtonBgColor
        cancelButton.layer.borderColor = self.cancelButtonBorderColor
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.cornerRadius = 4
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return cancelButton
    }()
    
    lazy var confirmButton: QMUIButton = {
        let confirmButton = QMUIButton()
        confirmButton.setTitle(confirmButtonText, for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = QMUITheme().themeTextColor()
        confirmButton.layer.borderColor = QMUITheme().themeTextColor().cgColor
        confirmButton.layer.borderWidth = 1.0
        confirmButton.layer.cornerRadius = 4
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return confirmButton
    }()
    
    lazy var beginDatePicker: UIDatePicker = {
        let picker = UIDatePicker.init()
        picker.backgroundColor = self.contentColor
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        picker.locale = Locale(identifier: YXUserManager.curLanguage().identifier)
        
        if self.style == .order {
            picker.setValue(QMUITheme().textColorLevel1(), forKey: "textColor")
        } else {
            picker.minimumDate = Date.init(timeInterval: TimeInterval(-timeRange), since: Date())
        }
        return picker
    }()
    
    lazy var endDatePicker: UIDatePicker = {
        let picker = UIDatePicker.init()
        picker.backgroundColor = self.contentColor
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        picker.locale = Locale(identifier: YXUserManager.curLanguage().identifier)
        
        if self.style == .order {
            picker.setValue(QMUITheme().textColorLevel1(), forKey: "textColor")
        } else {
            picker.minimumDate = Date.init(timeInterval: TimeInterval(-timeRange), since: Date())
        }
        return picker
    }()
    
    /*
     Begin : 不同风格的配色、字体大小、文案配置
     */
    fileprivate var bgColor: UIColor? {
        get {
            QMUITheme().shadeLayerColor()
        }
    }
    
    fileprivate var contentColor: UIColor? {
        get {
            QMUITheme().foregroundColor()
        }
    }
    
    fileprivate var titles: [String] {
        get {
            self.style == .history
                ? [YXLanguageUtility.kLang(key: "history_date_type_all"),
                   YXLanguageUtility.kLang(key: "history_date_type_last_month"),
                   YXLanguageUtility.kLang(key: "history_date_type_last_three_month"),
                   YXLanguageUtility.kLang(key: "history_date_type_last_year"),
                   YXLanguageUtility.kLang(key: "history_date_type_within_this_year"),
                   YXLanguageUtility.kLang(key: "history_date_type_custom")]
                : [YXLanguageUtility.kLang(key: "hold_today"),
                   YXLanguageUtility.kLang(key: "history_date_type_last_week"),
                   YXLanguageUtility.kLang(key: "history_date_type_last_month"),
                   YXLanguageUtility.kLang(key: "history_date_type_last_three_month"),
                   YXLanguageUtility.kLang(key: "history_date_type_last_year"),
                   YXLanguageUtility.kLang(key: "history_date_type_within_this_year"),
                   YXLanguageUtility.kLang(key: "history_date_type_custom")]
        }
    }
    
    fileprivate var timeRangeText: String {
        get {
            self.style == .history ? YXLanguageUtility.kLang(key: "history_time_limit") : YXLanguageUtility.kLang(key: "history_trade_time")
        }
    }
    
    fileprivate var cancelButtonText: String {
        get {
            YXLanguageUtility.kLang(key: "common_cancel")
        }
    }
    
    fileprivate var confirmButtonText: String {
        get {
            self.style == .history ? YXLanguageUtility.kLang(key: "common_confirm2") : YXLanguageUtility.kLang(key: "common_confirm")
        }
    }
    
    fileprivate var titleColor: UIColor? {
        get {
            QMUITheme().textColorLevel1()
        }
    }
    
    fileprivate var selectedTitleColor: UIColor? {
        get {
            QMUITheme().themeTextColor()
        }
    }
    
    fileprivate var timeButtonTitleColor: UIColor? {
        get {
            QMUITheme().textColorLevel3()
        }
    }
    
    fileprivate var timeButtonSelectedTitleColor: UIColor? {
        get {
            QMUITheme().themeTextColor()
        }
    }
    
    fileprivate var toLabelTextColor: UIColor? {
        get {
            self.style == .history
                ? UIColor(red: 0.21, green: 0.21, blue: 0.28, alpha: 1)
                : QMUITheme().textColorLevel1()
        }
    }
    
    fileprivate var cancelButtonTitleColor: UIColor? {
        get {
            QMUITheme().textColorLevel1()
        }
    }
    
    fileprivate var cancelButtonBgColor: UIColor? {
        get {
            QMUITheme().foregroundColor()
        }
    }
    
    fileprivate var cancelButtonBorderColor: CGColor? {
        get {
            QMUITheme().separatorLineColor().cgColor
        }
    }
    
    fileprivate var dateFilterButtonStyle: YXDateFilterButton.DateFilterButtonStyle {
        get {
            .white
        }
    }
    /*
     End : 不同风格的配色、字体大小、文案配置
     */
    
    @objc required init(style: YXDateFilterStyle, defaultSelectedIndex: Int = YXHistoryDateType.All.index) {
        super.init(frame: CGRect.zero)
        self.style = style
        self.selectedBtnIndex = defaultSelectedIndex
        self.tempSelectedBtnIndex = defaultSelectedIndex

        weak var weakSelf = self

        self.clipsToBounds = true
        self.backgroundColor = self.bgColor

        self.addSubview(self.container)
        self.container.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(-309)

            // 适配4S分辨率
            // 如果展开了自定义时间,则高度更高一点；在4S上对这个高度进行限制
            // 在5s及以上分辨率的机型上则不限制
            if YXConstant.deviceScaleEqualTo4S {
                make.height.equalTo(self.isExpanded ? 349 : 309)
            } else {
                make.height.equalTo(self.isExpanded ? 436 : 309)
            }
            make.width.equalToSuperview()
        }

        self.container.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().priority(250)
            make.width.equalTo(self.snp.width)
            make.centerY.equalToSuperview().priority(250)
        }


        self.contentView.addSubview(self.topSectionContainer)
        self.topSectionContainer.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(207 + 29)
        }

        self.topSectionContainer.addSubview(self.timeRangeLabel)
        self.timeRangeLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(20)
        }

        
        let titles = self.titles.filter { str in
            return str != YXLanguageUtility.kLang(key: "history_date_type_custom")
        }
                
        self.topSectionContainer.addSubview(filterButtonView)
        
        var buttonViewHeight: CGFloat = 32
        if titles.count > 3 {
            var rows: Int = titles.count / 3
            if titles.count % 3 > 0 {
                rows = rows + 1
            }
            buttonViewHeight = CGFloat((rows - 1) * 12 + Int(buttonViewHeight) * rows)
        }
        filterButtonView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(timeRangeLabel.snp.bottom).offset(20)
            make.height.equalTo(buttonViewHeight)
        }

        var views: [UIButton] = []
//        var alignLeftItem = self.topSectionContainer.snp.left
//        var firstButton:UIButton!
        for i in 0..<titles.count {
            let button = YXDateFilterButton(style: self.dateFilterButtonStyle)
            self.timeButtons.append(button)
            button.tag = i
            button.setTitle(titles[i], for: .normal)
            button.setTitleColor(self.titleColor, for: .normal)
            button.setTitleColor(self.selectedTitleColor, for: .selected)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.3
            if i == self.selectedBtnIndex {
                button.isSelected = true
            }
            
            button.addTarget(self, action: #selector(btnAction(sender:)), for: .touchUpInside)
            views.append(button)
            filterButtonView.addSubview(button)
            
        }
        views.snp.distributeSudokuViews(fixedLineSpacing: 16, fixedInteritemSpacing: 12, warpCount: 3)
        
        self.topSectionContainer.addSubview(self.customLabel)
        self.customLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(152)
            make.height.equalTo(20)
        }

        if self.style == .order {
            self.addSubview(self.customTipsLabel)
            self.customTipsLabel.snp.makeConstraints { (make) in
//                make.leading.equalTo(self.customLabel.snp.trailing).offset(8)
                make.centerY.equalTo(self.customLabel)
                make.trailing.equalToSuperview().offset(-16)
            }
        }

        self.topSectionContainer.addSubview(self.timeContainerView)
        self.timeContainerView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(self.customLabel.snp.bottom).offset(16)
            make.height.equalTo(32)
        }

        self.timeContainerView.addSubview(self.toLabel)
        self.toLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(14)
        }

        self.timeContainerView.addSubview(self.beginButton)
        self.beginButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(self.toLabel.snp.leading).offset(-19)
            make.bottom.top.equalToSuperview()
        }
        
        self.beginButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            if (self.beginButton.isSelected == true) {
                return;
            }
            self.beginButton.isSelected = true
            self.endButton.isSelected = false
            self.isExpanded = true
            if self.style == .order {
                if self.beginButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_start_date") {
                    let date = self.beginDatePicker.date
                    if let endDate = self.endDate, self.beginDatePicker.date.timeIntervalSince1970 > endDate.timeIntervalSince1970 {
                        QMUITips.showError(YXLanguageUtility.kLang(key: "history_date_not_allowed"), in: self, hideAfterDelay: 1)
                    } else {
                        self.beginButton.setTitle((self.formatter.string(from: date)) + YXLanguageUtility.kLang(key: "history_today"), for: .normal)
                        self.beginDate = date
                    }
                }
            } else {
                if self.beginButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_start_date") {
                    self.beginButton.setTitle(self.formatter.string(from: self.beginDatePicker.date), for: .normal)
                }
            }
            for button in (self.timeButtons) {
                button.isSelected = false
            }

        }.disposed(by: bag)

        self.timeContainerView.addSubview(self.endButton)
        self.endButton.snp.makeConstraints { (make) in
            make.leading.equalTo(self.toLabel.snp.trailing).offset(19)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.top.equalToSuperview()
        }
        
        self.endButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            if (self.endButton.isSelected == true) {
                return;
            }
            self.beginButton.isSelected = false
            self.endButton.isSelected = true
            self.isExpanded = true
            if self.style == .order {
                if self.endButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_end_date") {
                    let endDate = self.endDatePicker.date
                    
                    if let beginDate = self.beginDate,
                        endDate.timeIntervalSince1970 - beginDate.timeIntervalSince1970 >= TimeInterval(365 * 24 * 60 * 60)  {
                        QMUITips.showError(YXLanguageUtility.kLang(key: "history_time_range_not_allowed"))
                    } else {
                        self.endButton.setTitle((self.formatter.string(from: Date())) + YXLanguageUtility.kLang(key: "history_today"), for: .normal)
                        self.endDate = Date()
                    }
                }
            }
            for button in (self.timeButtons) {
                button.isSelected = false
            }
        }.disposed(by: bag)

        self.contentView.addSubview(self.actionContainerView)
        self.actionContainerView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }

        self.actionContainerView.addSubview(self.cancelButton)
        self.cancelButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
        }

        self.actionContainerView.addSubview(self.confirmButton)
        self.confirmButton.snp.makeConstraints { (make) in
            make.leading.equalTo(self.cancelButton.snp.trailing).offset(21)
            make.width.equalTo(self.cancelButton)
            make.trailing.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
        }

        self.cancelButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }
            
            self.hideFilterCondition()
            // 恢复成之前的选中按钮
            self.resetSelectedButton()
        }.disposed(by: bag)
        
        self.confirmButton.rx.tap.bind { [weak self] in
            guard let `self` = self else { return }

            self.selectedBtnIndex = self.tempSelectedBtnIndex

            let beginDate = self.beginDatePicker.date
            let endDate = self.endDatePicker.date

            if self.isExpanded == true {
                if self.beginButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_start_date") {
                    QMUITips.showError(YXLanguageUtility.kLang(key: "history_please_choose_start_date"), in: weakSelf!, hideAfterDelay: 1.5)
                    return
                } else if beginDate.compare(endDate) == .orderedDescending {
                    QMUITips.showError(YXLanguageUtility.kLang(key: "history_date_not_allowed"), in: weakSelf!, hideAfterDelay: 1.5)
                    return
                } else {
                    // beginDate 和 endDate的时间范围超过了上限，弹出Toast提示
                    if beginDate.compare(endDate.addingTimeInterval(TimeInterval(-self.timeRange))) == .orderedAscending {
                        switch self.style {
                        case .history:
                            QMUITips.showInfo(YXLanguageUtility.kLang(key: "history_max_date_range_5years"))
                        case .order:
                            QMUITips.showInfo(YXLanguageUtility.kLang(key: "history_time_range_not_allowed"))
                        }
                        return
                    }

                    self.selectedBtnIndex = self.style == .order ? YXHistoryDateType.Custom.orderIndex : YXHistoryDateType.Custom.index
                    self.beginDate = beginDate
                    self.endDate = endDate
                }
            }

            self.hideFilterCondition()

            if let filter = self.filter {
                var customIndex: Int
                if style == .order {
                    customIndex = YXHistoryDateType.Custom.orderIndex
                } else {
                    customIndex = YXHistoryDateType.Custom.index
                }
                if self.selectedBtnIndex == customIndex {
                    filter((self.selectedBtnIndex), beginDate, endDate)
                } else {
                    filter((self.selectedBtnIndex), nil, nil)
                }
            }
        }.disposed(by: bag)

        self.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.hideFilterCondition()
            // 恢复成之前的选中按钮
            self.resetSelectedButton()
        }).disposed(by: bag)
        
        self.contentView.insertSubview(self.beginDatePicker, at: 0)
        self.beginDatePicker.snp.makeConstraints { (make) in
            make.top.equalTo(self.topSectionContainer.snp.bottom).offset(-108)
            make.height.equalTo(108)
            make.leading.trailing.equalToSuperview()
        }

        self.beginDatePicker.rx.date.skip(1).subscribe(onNext: { [weak self] (date) in
            guard let `self` = self else { return }
            
            if style == .history {
                self.beginButton.setTitle(self.formatter.string(from: date as Date ), for: .normal)
            } else {
                let formatterString = (self.formatter.string(from: date as Date )) + (date.isToday() ? YXLanguageUtility.kLang(key: "history_today") : "")
                if self.endButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_end_date") {
                    self.beginDate = date as Date
                    self.beginButton.setTitle(formatterString, for: .normal)
                } else {
                    let endDate = self.endDatePicker.date
                    
                    if date.timeIntervalSince1970 > endDate.timeIntervalSince1970 {
                        QMUITips.showError(YXLanguageUtility.kLang(key: "history_date_not_allowed"))
                    } else if endDate.timeIntervalSince1970 - date.timeIntervalSince1970 >= TimeInterval(365 * 24 * 60 * 60) {
                        QMUITips.showError(YXLanguageUtility.kLang(key: "history_time_range_not_allowed"))
                    } else {
//                        self.beginDate = date as Date
//                        self.beginButton.setTitle(formatterString, for: .normal)
                    }
                    self.beginDate = date as Date
                    self.beginButton.setTitle(formatterString, for: .normal)
                }
            }
        }).disposed(by: bag)

        self.beginDatePicker.isHidden = true

        self.contentView.insertSubview(self.endDatePicker, at: 0)
        self.endDatePicker.snp.makeConstraints { (make) in
            make.top.equalTo(self.topSectionContainer.snp.bottom).offset(-108)
            make.height.equalTo(108)
            make.leading.trailing.equalToSuperview()
        }

        
        self.endDatePicker.rx.date.subscribe(onNext: { [weak self] (date) in
            guard let `self` = self else { return }
            
            if style == .history {
                self.endButton.setTitle(self.formatter.string(from: date as Date), for: .normal)
            } else {
                let formatterString = (self.formatter.string(from: date as Date )) + (date.isToday() ? YXLanguageUtility.kLang(key: "history_today") : "")
                if self.beginButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_start_date") {
                    self.endDate = date as Date
                    self.endButton.setTitle(formatterString, for: .normal)
                } else {
                    let beginDate = self.beginDatePicker.date
                    
                    if date.timeIntervalSince1970 < beginDate.timeIntervalSince1970 {
                        QMUITips.showError(YXLanguageUtility.kLang(key: "history_date_not_allowed2"))
                    } else if date.timeIntervalSince1970 - beginDate.timeIntervalSince1970 >= TimeInterval(365 * 24 * 60 * 60) {
                        QMUITips.showError(YXLanguageUtility.kLang(key: "history_time_range_not_allowed"))
                    } else {
//                        self.endDate = date as Date
//                        self.endButton.setTitle(formatterString, for: .normal)
                    }
                    self.endDate = date as Date
                    self.endButton.setTitle(formatterString, for: .normal)
                }
            }
        }).disposed(by: bag)

        self.endDatePicker.isHidden = true
    }
    
    
    @objc func btnAction(sender: YXDateFilterButton) {
        self.isExpanded = false
        for button in (self.timeButtons) {
            if sender == button {
                self.tempSelectedBtnIndex = sender.tag
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
        self.foldDatePicker()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.container.contentSize = CGSize.init(width: self.bounds.width, height: self.isExpanded ? 436 : 309)
        
        let maskPath = UIBezierPath(
            roundedRect: self.container.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 20, height: 20))

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.container.layer.mask = shape
    }
    
    fileprivate func resetDatePicker() -> Void {
        if style == .order {
            self.beginDatePicker.date = Date()
            self.endDatePicker.date = Date()
            self.beginButton.setTitle(YXLanguageUtility.kLang(key: "history_start_date"), for: .normal)
            self.beginDate = nil
            self.endDate = nil
            self.originBeginDate = nil
            self.originEndDate = nil
        }
        
        self.foldDatePicker()
    }
    
    @objc func resetSelectedButton() -> Void {
        var customIndex: Int
        if style == .order {
            customIndex = YXHistoryDateType.Custom.orderIndex
        }else {
            customIndex = YXHistoryDateType.Custom.index
        }
        for button in timeButtons {
            button.isSelected = false
        }
        if self.selectedBtnIndex != customIndex {
            if self.selectedBtnIndex >= 0 && self.selectedBtnIndex < self.timeButtons.count {
                self.timeButtons[self.selectedBtnIndex].isSelected = true
            }
            self.resetDatePicker()
        } else {
            if let beginDate = self.originBeginDate {
                self.beginDatePicker.date = beginDate
                self.beginButton.setTitle(self.formatter.string(from: beginDate), for: .normal)
                if style == .order {
                    let formatterString = (self.formatter.string(from: beginDate)) + (beginDate.isToday() ? YXLanguageUtility.kLang(key: "history_today") : "")
                    self.beginButton.setTitle(formatterString, for: .normal)
                }
                self.beginDate = self.originBeginDate
                self.originBeginDate = nil
            } else {
                self.beginDate = nil
                self.beginButton.setTitle(YXLanguageUtility.kLang(key: "history_start_date"), for: .normal)
                self.endDatePicker.date = Date()

            }
            
            if let endDate = self.originEndDate {
                self.endDatePicker.date = endDate
                self.endButton.setTitle(self.formatter.string(from: endDate), for: .normal)
                if style == .order {
                    let formatterString = (self.formatter.string(from: endDate)) + (endDate.isToday() ? YXLanguageUtility.kLang(key: "history_today") : "")
                    self.endButton.setTitle(formatterString, for: .normal)
                }
                self.endDate = self.originEndDate
                self.originEndDate = nil
            } else {
                self.endDate = nil
            }
            
            self.foldDatePicker()
        }
    }
    
    @objc func showFilterCondition(completion: ((Bool) -> Void)? = nil) -> Void {
        self.isHidden = false
        originBeginDate = beginDate
        originEndDate = endDate
        UIView.animate(withDuration: 0.3, animations: {
            self.container.snp.updateConstraints { (make) in
                make.top.equalToSuperview()
            }
            self.layoutIfNeeded()
        }) { (finished) in
            if (completion != nil) {
                completion!(finished)
            }
        }
    }
    
    @objc func hideFilterCondition(completion: ((Bool) -> Void)? = nil) -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.container.snp.updateConstraints { (make) in
                if YXConstant.deviceScaleEqualTo4S {
                    make.top.equalToSuperview().offset(self.isExpanded ? -349 : -309)
                } else {
                    make.top.equalToSuperview().offset(self.isExpanded ? -436 : -309)
                }
            }
            self.layoutIfNeeded()
        }) { (finished) in
            self.isHidden = true

            self.didHideBlock?(finished)

            if (completion != nil) {
                completion!(finished)
            }
        }
    }
    
    func foldDatePicker(completion: ((Bool) -> Void)? = nil) -> Void {
        // 隐藏datePicker
        UIView.animate(withDuration: 0.2, animations: {
            self.container.contentSize = CGSize.init(width: self.bounds.width, height: 309)
            self.contentView.snp.remakeConstraints({ (make) in
                make.leading.trailing.top.equalToSuperview()
                make.bottom.equalToSuperview().priority(250)
                make.width.equalTo(self.snp.width)
                make.centerY.equalToSuperview().priority(250)
            })
            self.container.snp.updateConstraints { (make) in
                // 适配4S分辨率
                // 如果展开了自定义时间,则高度更高一点；在4S上对这个高度进行限制
                // 在5s及以上分辨率的机型上则不限制
                make.height.equalTo(309)
            }
            
            self.beginDatePicker.snp.updateConstraints({ (make) in
                make.top.equalTo(self.topSectionContainer.snp.bottom).offset(-108)
            })
            
            self.endDatePicker.snp.updateConstraints({ (make) in
                make.top.equalTo(self.topSectionContainer.snp.bottom).offset(-108)
            })

            self.layoutIfNeeded()
        }) { (finished) in
            self.beginButton.isSelected = false
            self.endButton.isSelected = false
            self.beginDatePicker.isHidden = true
            self.endDatePicker.isHidden = true
            if completion != nil {
                completion!(finished)
            }
        }
    }
    
    func unfoldDatePicker(completion: ((Bool) -> Void)? = nil) -> Void {
        let needAnimation = self.beginDatePicker.isHidden && self.endDatePicker.isHidden
        if !needAnimation {
            if self.beginButton.isSelected {
                self.beginDatePicker.isHidden = false
                self.endDatePicker.isHidden = true
                self.beginDatePicker.snp.updateConstraints({ (make) in
                    make.top.equalTo(self.topSectionContainer.snp.bottom).offset(0)
                })
                self.endDatePicker.snp.updateConstraints({ (make) in
                    make.top.equalTo(self.topSectionContainer.snp.bottom).offset(-108)
                })
            } else if self.endButton.isSelected {
                self.beginDatePicker.isHidden = true
                self.endDatePicker.isHidden = false
                self.endDatePicker.snp.updateConstraints({ (make) in
                    make.top.equalTo(self.topSectionContainer.snp.bottom).offset(0)
                })
                self.beginDatePicker.snp.updateConstraints({ (make) in
                    make.top.equalTo(self.topSectionContainer.snp.bottom).offset(-108)
                })
            }
            self.layoutIfNeeded()
        } else {
            // 显示datePicker
            if self.beginButton.isSelected {
                self.beginDatePicker.isHidden = false
                self.endDatePicker.isHidden = true
            } else if self.endButton.isSelected {
                self.beginDatePicker.isHidden = true
                self.endDatePicker.isHidden = false
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.container.snp.updateConstraints { (make) in
                    // 适配4S分辨率
                    // 如果展开了自定义时间,则高度更高一点；在4S上对这个高度进行限制
                    // 在5s及以上分辨率的机型上则不限制
                    if YXConstant.deviceScaleEqualTo4S {
                        make.height.equalTo(349)
                    } else {
                        make.height.equalTo(436)
                    }
                }
                if self.beginButton.isSelected {
                    self.beginDatePicker.snp.updateConstraints({ (make) in
                        make.top.equalTo(self.topSectionContainer.snp.bottom).offset(0)
                    })
                } else if self.endButton.isSelected {
                    self.endDatePicker.snp.updateConstraints({ (make) in
                        make.top.equalTo(self.topSectionContainer.snp.bottom).offset(0)
                    })
                }

                self.layoutIfNeeded()
            }) { (finished) in
                self.container.contentSize = CGSize.init(width: self.bounds.width, height: 436)
                self.contentView.snp.remakeConstraints({ (make) in
                    make.leading.trailing.top.equalToSuperview()
                    make.bottom.equalToSuperview().priority(250)
                    make.width.equalTo(self.snp.width)
                    make.centerY.equalToSuperview().priority(250)
                    make.height.equalTo(436)
                })
                if completion != nil {
                    completion!(finished)
                }
            }
        }
    }
}

extension Date {
    func isToday() -> Bool{
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.day,.month,.year]
        let nowComps = calendar.dateComponents(unit, from: Date())
        let selfCmps = calendar.dateComponents(unit, from: self)
        
        return (selfCmps.year == nowComps.year) &&
            (selfCmps.month == nowComps.month) &&
            (selfCmps.day == nowComps.day)
    }
}
