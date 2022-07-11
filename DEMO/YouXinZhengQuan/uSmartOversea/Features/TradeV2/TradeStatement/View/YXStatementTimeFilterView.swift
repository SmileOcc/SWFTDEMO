//
//  YXStatementTimeFilterView.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/7/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx
import QMUIKit
import BRPickerView

class YXStatementTimeFilterView: UIControl {
    
    @objc var didHideBlock: ((Bool) -> Void)?
    
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
    
    var selectedTimeType: TradeStatementTimeType = .threeMonth
    var tempSelectedTimeType: TradeStatementTimeType = .threeMonth // 当点击dateflag按钮时，记录用户选中了哪个按钮，如果用户最终点击了取消，则需要把dateflag按钮回复到之前的（selectedBtnIndex）状态
    
    var statmentType:TradeStatementType = .all {
        didSet {
            if statmentType == .month {
                beginDatePicker.pickerMode = .YM
                endDatePicker.pickerMode = .YM
                formatter.dateFormat = "yyyy-MM"
            } else {
                beginDatePicker.pickerMode = .YMD
                endDatePicker.pickerMode = .YMD
                formatter.dateFormat = "yyyy-MM-dd"
            }
            if let beginDate = beginDate {
                beginDatePicker.selectDate = beginDate
                beginButton.setTitle(formatter.string(from: beginDate), for: .normal)
            }
            
            if let endDate = endDate {
                endDatePicker.selectDate = endDate
                endButton.setTitle(formatter.string(from: endDate), for: .normal)
            }
  
        }
    }
    
    var systemDate: String = "" {
        didSet {
            let date = self.formatter.date(from: self.systemDate)
            let minDate = self.formatter.date(from: "2019-01-01")
            var maxDate: Date?
            var beginDate: Date?
            
            self.beginDatePicker.minDate = minDate
            self.endDatePicker.minDate = minDate
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
            
            self.beginDatePicker.maxDate = maxDate
            self.endDatePicker.maxDate = maxDate
            
            // 设置时间选择器的当前日期
            // 如果开始时间的日期小于最小日期时，需要重新设置一下时间选择器的当前时间
            if self.beginButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_start_date") || self.beginDatePicker.selectDate?.compare(minDate!) == .orderedAscending {
                self.beginDatePicker.selectDate = beginDate!
                
                // 同时，如果开始日期的Button文字不是开始日期时，则也重新设置一下Button的文字
                if self.beginButton.titleLabel?.text != YXLanguageUtility.kLang(key: "history_start_date") {
                    self.beginButton.setTitle(self.formatter.string(from: minDate!), for: .normal)
                }
            }
            
            // 如果当前结束日期的Button文字是”结束日期“，或者结束日期的时间选择器的时间大于最大时间时，则需要重置一下结束日期时间选择器的当前时间
            if self.endButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_end_date") || self.endDatePicker.selectDate?.compare(maxDate ?? Date()) == .orderedDescending {
                self.endDatePicker.selectDate = maxDate ?? Date()
                self.endButton.setTitle(self.formatter.string(from: maxDate ?? Date()), for: .normal)
            }
        }
    }
    
    var beginDate: Date?, endDate: Date?
    var originBeginDate: Date?, originEndDate: Date?
    
    //最长可查询6个月
    var timeRange: TimeInterval {
        get {
            let a = 6 * 30
            let b = 24 * 60 * 60
            return TimeInterval(a * b)
        }
    }
    
    @objc var filter:((_ type: TradeStatementTimeType, _ beginDate: Date?, _ endDate: Date?) -> Void)?
    
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
        customTipsLabel.text = YXLanguageUtility.kLang(key: "statement_pik_tip")
        customTipsLabel.font = UIFont.systemFont(ofSize: 12)
        customTipsLabel.textColor = QMUITheme().textColorLevel3()
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
    
    lazy var dateView = UIView()
    
    lazy var beginDatePicker: BRDatePickerView = {
        let picker = BRDatePickerView()
        if statmentType == .month {
            picker.pickerMode = .YM
        } else {
            picker.pickerMode = .YMD
        }
        picker.backgroundColor = self.contentColor
        picker.maxDate = Date()
        
        picker.pickerStyle?.language = YXUserManager.curLanguage().identifier
        picker.pickerStyle?.pickerTextColor = QMUITheme().textColorLevel1()
        picker.pickerStyle?.pickerTextFont = .systemFont(ofSize: 14)
        picker.pickerStyle?.selectRowColor = QMUITheme().backgroundColor()
        picker.pickerStyle?.separatorColor = .clear
        
        picker.changeBlock = { [weak self] date, _ in
            guard let `self` = self else { return }
            guard let date = date else { return }
            
            let formatterString = (self.formatter.string(from: date)) + ((date.isToday() && self.statmentType != .month) ? YXLanguageUtility.kLang(key: "history_today") : "")
            if self.endButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_end_date") {
                self.beginDate = date
                self.beginButton.setTitle(formatterString, for: .normal)
            } else {
                if let endDate = self.endDate {
                    if date.timeIntervalSince1970 > endDate.timeIntervalSince1970 {
                        QMUITips.showError(YXLanguageUtility.kLang(key: "history_date_not_allowed"), in: self, hideAfterDelay: 1)
                    } else if endDate.timeIntervalSince1970 - date.timeIntervalSince1970 >=  self.timeRange {
                        QMUITips.showError(YXLanguageUtility.kLang(key: "statement_pik_tip"), in: self, hideAfterDelay: 1)
                    } else {
                        
                    }
                }

                self.beginDate = date
                self.beginButton.setTitle(formatterString, for: .normal)
            }
        }
        
        return picker
    }()
    
    lazy var endDatePicker: BRDatePickerView = {
        let picker = BRDatePickerView()
        if statmentType == .month {
            picker.pickerMode = .YM
        } else {
            picker.pickerMode = .YMD
        }
        picker.backgroundColor = self.contentColor
        picker.maxDate = Date()
        
        picker.pickerStyle?.language = YXUserManager.curLanguage().identifier
        picker.pickerStyle?.pickerTextColor = QMUITheme().textColorLevel1()
        picker.pickerStyle?.pickerTextFont = .systemFont(ofSize: 14)
        picker.pickerStyle?.selectRowColor = QMUITheme().backgroundColor()
        picker.pickerStyle?.separatorColor = .clear
        
        picker.changeBlock = { [weak self] date, _ in
            guard let `self` = self else { return }
            guard let date = date else { return }
            
            let formatterString = (self.formatter.string(from: date)) + ((date.isToday() && self.statmentType != .month) ? YXLanguageUtility.kLang(key: "history_today") : "")
            if self.beginButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_start_date") {
                self.endDate = date as Date
                self.endButton.setTitle(formatterString, for: .normal)
            } else {
                if let beginDate = self.beginDate {
                    if date.timeIntervalSince1970 < beginDate.timeIntervalSince1970 {
                        QMUITips.showError(YXLanguageUtility.kLang(key: "history_date_not_allowed2"), in: self, hideAfterDelay: 1)
                    } else if date.timeIntervalSince1970 - beginDate.timeIntervalSince1970 >= self.timeRange {
                        QMUITips.showError(YXLanguageUtility.kLang(key: "statement_pik_tip"), in: self, hideAfterDelay: 1)
                    } else {
                        //                        self.endDate = date as Date
                        //                        self.endButton.setTitle(formatterString, for: .normal)
                    }
                    self.endDate = date
                    self.endButton.setTitle(formatterString, for: .normal)
                }
            }
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
    
//    fileprivate var types: [String] {
//        get {
//            return [YXLanguageUtility.kLang(key: "six_month"), YXLanguageUtility.kLang(key: "history_date_type_last_three_month"), YXLanguageUtility.kLang(key: "history_date_type_last_month")]
//
//        }
//    }
    
    fileprivate var timeRangeText: String {
        get {
            YXLanguageUtility.kLang(key: "history_time_limit")
        }
    }
    
    fileprivate var cancelButtonText: String {
        get {
            YXLanguageUtility.kLang(key: "common_cancel")
        }
    }
    
    fileprivate var confirmButtonText: String {
        get {
            YXLanguageUtility.kLang(key: "common_confirm2")
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
            QMUITheme().textColorLevel1()
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
    
    @objc required init(defaultSelectedType: TradeStatementTimeType = .threeMonth) {
        super.init(frame: CGRect.zero)
        
        self.selectedTimeType = defaultSelectedType
        self.tempSelectedTimeType = defaultSelectedType

        weak var weakSelf = self

        self.clipsToBounds = true
        self.backgroundColor = self.bgColor

        self.addSubview(self.container)
        self.container.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(-280)

            // 适配4S分辨率
            // 如果展开了自定义时间,则高度更高一点；在4S上对这个高度进行限制
            // 在5s及以上分辨率的机型上则不限制
            if YXConstant.deviceScaleEqualTo4S {
                make.height.equalTo(self.isExpanded ? 310 : 280)
            } else {
                make.height.equalTo(self.isExpanded ? 376 : 280)
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
            make.height.equalTo(196)
        }

        self.topSectionContainer.addSubview(self.timeRangeLabel)
        self.timeRangeLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(20)
        }

        
        let types = TradeStatementTimeType.allCases.filter { type in
            return type != .custom
        }
                
        self.topSectionContainer.addSubview(filterButtonView)
        
        var buttonViewHeight: CGFloat = 32
        if types.count > 3 {
            var rows: Int = types.count / 3
            if types.count % 3 > 0 {
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
        for type in types {
            let button = YXDateFilterButton(style: self.dateFilterButtonStyle)
            self.timeButtons.append(button)
            button.tag = type.rawValue
            button.setTitle(type.text, for: .normal)
            button.setTitleColor(self.titleColor, for: .normal)
            button.setTitleColor(self.selectedTitleColor, for: .selected)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.3
            if type == selectedTimeType {
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
            make.top.equalToSuperview().offset(115)
            make.height.equalTo(20)
        }

        self.addSubview(self.customTipsLabel)
        self.customTipsLabel.snp.makeConstraints { (make) in
            //                make.leading.equalTo(self.customLabel.snp.trailing).offset(8)
            make.centerY.equalTo(self.customLabel)
            make.trailing.equalToSuperview().offset(-16)
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
        
        self.beginButton.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            
            if (self.beginButton.isSelected == true) {
                return;
            }
            self.beginButton.isSelected = true
            self.endButton.isSelected = false
            self.isExpanded = true
            
            if self.beginButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_start_date") {
                if let endDateValue = self.endDate{
                    self.beginDatePicker.selectDate = endDateValue
                } else {
                    if let beginDate = self.beginDatePicker.selectDate {
                        self.beginButton.setTitle((self.formatter.string(from: beginDate)), for: .normal)
                        self.beginDate = beginDate
                    } else {
                        let date = Date()
                        self.beginButton.setTitle((self.formatter.string(from: date)) + (self.statmentType != .month ? YXLanguageUtility.kLang(key: "history_today") : ""), for: .normal)
                        self.beginDate = date
                    }
                }
            } else{
                if let textValue = self.beginButton.titleLabel?.text, textValue.count > 0 {
                    let date:Date = self.formatter.date(from: textValue) ?? Date()
                    self.beginDatePicker.selectDate = date
                    self.beginDate = date
                }
            }
    
            for button in (self.timeButtons) {
                button.isSelected = false
            }
        }
        
        self.timeContainerView.addSubview(self.endButton)
        self.endButton.snp.makeConstraints { (make) in
            make.leading.equalTo(self.toLabel.snp.trailing).offset(19)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.top.equalToSuperview()
        }
        
        self.endButton.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            
            if (self.endButton.isSelected == true) {
                return;
            }
            self.beginButton.isSelected = false
            self.endButton.isSelected = true
            self.isExpanded = true
            if self.endButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_end_date") {
                if let endDate = self.endDatePicker.selectDate,
                   let beginDate = self.beginDate,
                   endDate.timeIntervalSince1970 - beginDate.timeIntervalSince1970 >= self.timeRange  {
                    QMUITips.showError(YXLanguageUtility.kLang(key: "statement_pik_tip"), in: self, hideAfterDelay: 1)
                } else {
                    self.endButton.setTitle((self.formatter.string(from: Date())) + (self.statmentType != .month ? YXLanguageUtility.kLang(key: "history_today") : ""), for: .normal)
                    self.endDate = Date()
                }
            }
            for button in (self.timeButtons) {
                button.isSelected = false
            }
        }

        self.contentView.addSubview(self.actionContainerView)
        self.actionContainerView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
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

        self.cancelButton.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            
            self.hideFilterCondition()
            // 恢复成之前的选中按钮
            self.resetSelectedButton()
        }
        
        self.confirmButton.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            
            if self.tempSelectedTimeType == .custom {
                if let endDate = self.endDate,
                   let beginDate = self.beginDate,
                   endDate.timeIntervalSince1970 - beginDate.timeIntervalSince1970 >= self.timeRange {
                    QMUITips.showError(YXLanguageUtility.kLang(key: "statement_pik_tip"), in: self, hideAfterDelay: 1)
                    return
                }
            }
            
            self.selectedTimeType = self.tempSelectedTimeType

            let beginDate = self.beginDate
            let endDate = self.endDate
            
            if self.isExpanded == true {
                if self.beginButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_start_date") {
                    QMUITips.showError(YXLanguageUtility.kLang(key: "history_please_choose_start_date"), in: weakSelf!, hideAfterDelay: 1.5)
                    return
                } else if self.endButton.titleLabel?.text == YXLanguageUtility.kLang(key: "history_end_date") {
                    QMUITips.showError(YXLanguageUtility.kLang(key: "history_please_choose_end_date"), in: weakSelf!, hideAfterDelay: 1.5)
                    return
                }
                self.selectedTimeType = .custom
            }
            self.hideFilterCondition()
            if let filter = self.filter {
                if self.selectedTimeType == .custom {
                    filter(.custom, beginDate, endDate)
                } else {
                    filter(self.selectedTimeType, nil, nil)
                }
            }
        }

        self.qmui_tapBlock = { [weak self] _ in
            guard let `self` = self else { return }
            self.hideFilterCondition()
            // 恢复成之前的选中按钮
            self.resetSelectedButton()
        }
        
        contentView.addSubview(dateView)
        dateView.snp.makeConstraints { (make) in
            make.top.equalTo(topSectionContainer.snp.bottom).offset(-108)
            make.height.equalTo(108)
            make.leading.trailing.equalToSuperview()
        }
        
        beginDatePicker.addPicker(to: dateView)
        endDatePicker.addPicker(to: dateView)
        
        dateView.isHidden = true
        beginDatePicker.isHidden = true
        endDatePicker.isHidden = true
    }
    
    
    @objc func btnAction(sender: YXDateFilterButton) {
        self.isExpanded = false
        for button in timeButtons {
            if sender == button {
                if let type = TradeStatementTimeType(rawValue: sender.tag) {
                    self.tempSelectedTimeType = type
                }
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
        
        self.container.contentSize = CGSize.init(width: self.bounds.width, height: self.isExpanded ? 376 : 280)
        
        let maskPath = UIBezierPath(
            roundedRect: self.container.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 20, height: 20))

        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        self.container.layer.mask = shape
    }
    
    fileprivate func resetDatePicker() -> Void {
        self.beginDatePicker.selectDate = Date()
        self.endDatePicker.selectDate = Date()
        self.beginButton.setTitle(YXLanguageUtility.kLang(key: "history_start_date"), for: .normal)
        self.beginDate = nil
        self.endDate = nil
        self.originBeginDate = nil
        self.originEndDate = nil
        
        self.foldDatePicker()
    }
    
    @objc func resetSelectedButton() -> Void {
        for button in timeButtons {
            button.isSelected = false
        }
        if self.selectedTimeType != .custom {
//            for button in timeButtons {
//                if button.tag == selectedTimeType.rawValue {
//                    button.isSelected = true
//                }
//            }
            self.resetDatePicker()
        } else {
            if let beginDate = self.originBeginDate {
                self.beginDatePicker.selectDate = beginDate
                self.beginButton.setTitle(self.formatter.string(from: beginDate), for: .normal)
                let formatterString = (self.formatter.string(from: beginDate)) + ((beginDate.isToday() && self.statmentType != .month) ? YXLanguageUtility.kLang(key: "history_today") : "")
                self.beginButton.setTitle(formatterString, for: .normal)
                self.beginDate = self.originBeginDate
                self.originBeginDate = nil
            } else {
                self.beginDate = nil
                self.beginButton.setTitle(YXLanguageUtility.kLang(key: "history_start_date"), for: .normal)
                self.endDatePicker.selectDate = Date()

            }
            
            if let endDate = self.originEndDate {
                self.endDatePicker.selectDate = endDate
                self.endButton.setTitle(self.formatter.string(from: endDate), for: .normal)
                let formatterString = (self.formatter.string(from: endDate)) + ((endDate.isToday() && self.statmentType != .month) ? YXLanguageUtility.kLang(key: "history_today") : "")
                self.endButton.setTitle(formatterString, for: .normal)
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
                    make.top.equalToSuperview().offset(self.isExpanded ? -310 : -280)
                } else {
                    make.top.equalToSuperview().offset(self.isExpanded ? -376 : -280)
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
            self.container.contentSize = CGSize.init(width: self.bounds.width, height: 280)
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
                make.height.equalTo(280)
            }
            
            self.dateView.snp.updateConstraints({ (make) in
                make.top.equalTo(self.topSectionContainer.snp.bottom).offset(-108)
            })

            self.layoutIfNeeded()
        }) { (finished) in
            self.beginButton.isSelected = false
            self.endButton.isSelected = false
            self.dateView.isHidden = true
            self.beginDatePicker.isHidden = true
            self.endDatePicker.isHidden = true
            if completion != nil {
                completion!(finished)
            }
        }
    }
    
    func unfoldDatePicker(completion: ((Bool) -> Void)? = nil) -> Void {
        if !dateView.isHidden {
            if beginButton.isSelected {
                beginDatePicker.isHidden = false
                endDatePicker.isHidden = true
            } else if self.endButton.isSelected {
                beginDatePicker.isHidden = true
                endDatePicker.isHidden = false
            }
            self.layoutIfNeeded()
        } else {
            // 显示datePicker
            dateView.isHidden = false
            if beginButton.isSelected {
                beginDatePicker.isHidden = false
                endDatePicker.isHidden = true
            } else if self.endButton.isSelected {
                beginDatePicker.isHidden = true
                endDatePicker.isHidden = false
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.container.snp.updateConstraints { (make) in
                    // 适配4S分辨率
                    // 如果展开了自定义时间,则高度更高一点；在4S上对这个高度进行限制
                    // 在5s及以上分辨率的机型上则不限制
                    if YXConstant.deviceScaleEqualTo4S {
                        make.height.equalTo(310)
                    } else {
                        make.height.equalTo(376)
                    }
                }
                self.dateView.snp.updateConstraints({ (make) in
                    make.top.equalTo(self.topSectionContainer.snp.bottom).offset(0)
                })

                self.layoutIfNeeded()
            }) { (finished) in
                self.container.contentSize = CGSize.init(width: self.bounds.width, height: 376)
                self.contentView.snp.remakeConstraints({ (make) in
                    make.leading.trailing.top.equalToSuperview()
                    make.bottom.equalToSuperview().priority(250)
                    make.width.equalTo(self.snp.width)
                    make.centerY.equalToSuperview().priority(250)
                    make.height.equalTo(376)
                })
                if completion != nil {
                    completion!(finished)
                }
            }
        }
    }
}
