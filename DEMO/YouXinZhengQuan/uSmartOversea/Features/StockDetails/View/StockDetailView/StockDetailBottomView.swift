//
//  StockDetailBottomView.swift
//  
//
//  Created by chenmingmao on 2022/3/30.
//

import UIKit

let kLowAdrShowRiskWarnningKey = "kLowAdrShowRiskWarnningKey"

enum BottomTradeExpandType {
    case normalTrade
    case smart
    case fractional
    case dayMargin
    case option
}
extension BottomTradeExpandType {
    var text: String {
        switch self {
        case .normalTrade:
           return YXLanguageUtility.kLang(key: "hold_trade_title")
        case .smart:
           return YXLanguageUtility.kLang(key: "trading_smart_order")
        case .fractional:
           return YXLanguageUtility.kLang(key: "fractional_trading")
        case .dayMargin:
            return ""
        case .option:
            return YXLanguageUtility.kLang(key: "option_trade")
        }
    }
    var iconName: String {
        switch self {
        case .normalTrade:            
            return "stock_trade_expand_fractional_icon"
        case .smart:
            return "stock_trade_expand_smart_icon"
        case .fractional:
            return "stock_trade_expand_normal_icon"
        case .dayMargin:
            return ""
        case .option:
            return "stock_trade_expand_option_icon"
        }
    }
}


class StockDetailBottomView: UIView {
    typealias ClosureButtonAction = (UIControl?) -> Void
    @objc var monthlyClosure: ClosureButtonAction?
    @objc var newStcokClosure: ClosureButtonAction?
    @objc var buyEtfClosure: ClosureButtonAction?
    @objc var bondClosure: ClosureButtonAction?
    @objc var tradeClosure: ClosureButtonAction?
    @objc var remindClosure: ClosureButtonAction?
    @objc var warrantClosure: ClosureButtonAction?
    @objc var selfSelectClosure: ClosureButtonAction?
    @objc var shareClosure: ClosureButtonAction?
    @objc var optionChainClosure: ClosureButtonAction?
    
    @objc var normalTradeClosure: ClosureButtonAction?
    @objc var smartTradeClosure: ClosureButtonAction?
    @objc var dayMarginTradeClosure: ClosureButtonAction?
    @objc var fractionalTradeClosure: ClosureButtonAction?
    
    
    var tipClosure: ((String) -> Void)?
    
    private var expandList: [BottomTradeExpandType] = []
    
    private var isUnSupportTrade = false
    ///低级adr,且支持交易
    private var isLowAdrSupportTrade = false

    private var stackView: UIStackView = {
        let view = UIStackView.init()
        view.axis = .horizontal
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var remindButton: QMUIButton = {
        let button = self.creatTemplate(with: YXLanguageUtility.kLang(key: "remind"), iconName: "stock_remind_normal")
        button.setImage(UIImage(named: "stock_remind_select"), for: .selected)
        button.qmui_tapBlock = { [weak self] sender in
            guard let `self` = self else { return }
            self.remindClosure?(sender)
        }
        return button
    }()
    
    private lazy var shareButton: QMUIButton = {
        let button = self.creatTemplate(with: YXLanguageUtility.kLang(key: "share"), iconName: "stok_share")
        button.qmui_tapBlock = { [weak self] sender in
            guard let `self` = self else { return }
            self.shareClosure?(sender)
        }
        return button
    }()
    
    private lazy var selfSelectButotn: QMUIButton = {
        let button = self.creatTemplate(with: YXLanguageUtility.kLang(key: "news_watchlist"), iconName: "new_like_unselect")
        button.setImage(UIImage(named: "new_like_select"), for: .selected)
        
        button.qmui_tapBlock = { [weak self] sender in
            guard let `self` = self else { return }
            self.selfSelectClosure?(sender)
        }
        
        return button
    }()
    
    private lazy var buyEtfButton: QMUIButton = {
        let button = self.creatTemplate(with: "买ETF基金", iconName: "buy_etf_icon")
        button.isHidden = true
        button.qmui_tapBlock = { [weak self] sender in
            guard let `self` = self else { return }
            self.buyEtfClosure?(sender)
        }
        return button
    }()
    private lazy var wheelButton: QMUIButton = {
        let button = self.creatTemplate(with: YXLanguageUtility.kLang(key: "warrants_warrants"), iconName: "stock_warrants")
        button.isHidden = true
        button.qmui_tapBlock = { [weak self] sender in
            guard let `self` = self else { return }
            self.warrantClosure?(sender)
        }
        return button
    }()
    
    private lazy var boundButton: QMUIButton = {
        let button = self.creatTemplate(with: YXLanguageUtility.kLang(key: "bond"), iconName: "us_bond")
        button.isHidden = true
        button.qmui_tapBlock = { [weak self] sender in
            guard let `self` = self else { return }
            self.bondClosure?(sender)
        }
        return button
    }()
    private lazy var monthlyButton: QMUIButton = {
        let button = self.creatTemplate(with: YXLanguageUtility.kLang(key: "stock_detail_monthly_payment"), iconName: "yuegong")
        button.isHidden = true
        button.qmui_tapBlock = { [weak self] sender in
            guard let `self` = self else { return }
            self.monthlyClosure?(sender)
        }
        return button
    }()
//    private lazy var optionChainButton: QMUIButton = {
//        let button = self.creatTemplate(with: YXLanguageUtility.kLang(key: "options"), iconName: "stock_options")
//        button.isHidden = true
//        button.qmui_tapBlock = { [weak self] sender in
//            guard let `self` = self else { return }
//            self.optionChainClosure?(sender)
//        }
//        return button
//    }()
    
    
    private lazy var tradeButton: UIButton = {
        let button = UIButton.init(type: .custom, title: YXLanguageUtility.kLang(key: "hold_trade_title"), font: UIFont.normalFont16(), titleColor: .white, target: self, action: #selector(self.tradeButtonClick(_:)))!
        button.backgroundColor = QMUITheme().themeTintColor()
        
        let arrowImage = UIImage(named: "stock_trade_expand_icon")
        button.setImage(arrowImage, for: .selected)
        button.setTitle("", for: .selected)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var menuView: QMUIPopupMenuView = {
        let menuView = QMUIPopupMenuView()
        menuView.automaticallyHidesWhenUserTap = true
        menuView.maskViewBackgroundColor = .clear
        menuView.backgroundColor = QMUITheme().themeTintColor()
        menuView.arrowSize = .zero
        menuView.preferLayoutDirection = .below
        menuView.shouldShowItemSeparator = true
        menuView.itemSeparatorColor = UIColor.qmui_color(withHexString: "#DDDDDD")!.withAlphaComponent(0.4)
        menuView.itemSeparatorInset = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        menuView.itemTitleFont = .systemFont(ofSize: 14)
        menuView.itemTitleColor = .white
        menuView.itemHeight = 49
        menuView.sourceView = self.tradeButton
        menuView.minimumWidth = 148
        menuView.safetyMarginsOfSuperview = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 16)
        menuView.cornerRadius = 6
        menuView.distanceBetweenSource = 8
        menuView.padding = .zero
        menuView.borderColor = .clear
        menuView.didHideBlock = { [weak self] _ in
            self?.tradeButton.isSelected = false
        }
        return menuView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        let maskView = UIView()
        maskView.backgroundColor = QMUITheme().foregroundColor()
        addSubview(maskView)
        maskView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        addSubview(stackView)
        addSubview(tradeButton)
                                        
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(50)
            make.right.equalToSuperview().offset(-142)
        }
        
        tradeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
            make.width.equalTo(108)
            make.top.equalToSuperview().offset(9)
        }
                                
//        stackView.addArrangedSubview(optionChainButton)
        stackView.addArrangedSubview(boundButton)
        stackView.addArrangedSubview(wheelButton)
        stackView.addArrangedSubview(shareButton)
        stackView.addArrangedSubview(remindButton)
        stackView.addArrangedSubview(selfSelectButotn)
        stackView.addArrangedSubview(monthlyButton)
        stackView.addArrangedSubview(buyEtfButton)
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func creatTemplate(with title: String, iconName: String) -> QMUIButton {
        let button = QMUIButton.init()
        
        button.titleLabel?.font = UIFont.normalFont14()
        button.setTitle(title, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.font = UIFont.normalFont10()
        button.titleLabel?.minimumScaleFactor = 0.3
        button.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        
        button.imagePosition = .top
        button.spacingBetweenImageAndTitle = 4
        button.setImage(UIImage(named: iconName), for: .normal)
        
        if YXUserManager.isENMode() {
            button.titleLabel?.numberOfLines = 2
        } else {
            button.titleLabel?.numberOfLines = 1
        }
        
        return button
    }
    

}

// MARK: - 给外部调用的方法
extension StockDetailBottomView {
    
    /// 赋值模型
    func setUpSubviews(quoteModel: YXV2Quote) {
        guard let market = quoteModel.market else { return }
        let stockType = quoteModel.stockType
        
        expandList.removeAll()
        
        // 设置默认值
        self.tradeButton.isUserInteractionEnabled = true
        
        self.remindButton.isHidden = false
        self.shareButton.isHidden = false
        self.selfSelectButotn.isHidden = false
        self.tradeButton.isHidden = false
                
        let greyFlag = quoteModel.greyFlag?.value ?? 0
        let trdStatus = OBJECT_QUOTETradingStatus.init(rawValue: quoteModel.trdStatus?.value ?? 0) ?? .none
        
        var isRemindExit = true
        if market == kYXMarketUsOption || greyFlag > 0 {
            isRemindExit = false
        }
        var isWheelExit = false
        if market == kYXMarketHK {
            if stockType == .stIndex || stockType == .hkStock || stockType == .fund {
                isWheelExit = true
            } else if stockType == .stWarrant || stockType == .stCbbc || stockType == .stInlineWarrant {
                isWheelExit = true
            }
        }
//        let isDayMarginExit = quoteModel.dailyMargin?.value ?? false
        let isFractionalExit = (quoteModel.fractionnalTrade?.value ?? false) && market == kYXMarketUS
        var isSmartTradeExit = true
        
        let type2 = OBJECT_SECUSecuType2.init(rawValue: quoteModel.type2?.value ?? 0) ?? .none
        if stockType == .bond && type2 == .stLowAdr {
            isSmartTradeExit = false
        }
        if trdStatus == .tsUnlisted && greyFlag > 0 {
            // 未上市且不是暗盘的票,没有智能下单
            isSmartTradeExit = false
        }
        if market == kYXMarketUS && type2 == .stLowAdr && (quoteModel.otcTradingType?.value ?? 0) == 0 {
            // 低级adr且这个不支持交易的时候
            isSmartTradeExit = false
        }
        if market == kYXMarketUsOption {
            isSmartTradeExit = false
        }

        let isBuyEtfExit = false
//        if stockType == .stIndex && (YXStockDetailTool.isHKThreeIndex(quoteModel) || market == kYXMarketUS) {
//            isBuyEtfExit = true
//        }
        
//        var isOptionChainExit = false
//        if market == kYXMarketUsOption {
//            isOptionChainExit = true
//        }
        
        var isTradeExit = true
        if stockType == .stIndex || stockType == .stSector {
            isTradeExit = false
        }
        
        self.remindButton.isHidden = !isRemindExit
        self.wheelButton.isHidden = !isWheelExit
        self.buyEtfButton.isHidden = !isBuyEtfExit
        self.shareButton.isHidden = market == kYXMarketCryptos
        
        expandList.append(.normalTrade)

        if isFractionalExit {
            expandList.append(.fractional)
        }
        
//        if isOptionChainExit {
//            expandList.append(.option)
//        }
//
        if isSmartTradeExit {
            expandList.append(.smart)
        }
//        if expandList.count > 0 {
//            // 可以展开
//            self.expandButton.isHidden = false
//        } else {
//            self.expandButton.isHidden = true
//        }
        
        if isTradeExit {
            self.tradeButton.isHidden = false
            self.stackView.snp.updateConstraints { make in
                make.right.equalToSuperview().offset(-142)
            }
        } else {
            self.tradeButton.isHidden = true
            self.stackView.snp.updateConstraints { make in
                make.right.equalToSuperview().offset(-16)
            }
        }
        
        self.resetSelfSelectState(with: quoteModel.market ?? "" , symbol: quoteModel.symbol ?? "")
                        
        if trdStatus == .tsUnlisted && market != kYXMarketHK {
            /// 美股的ipo
            self.refreshTradeButtonGrayStyle(with: YXLanguageUtility.kLang(key: "stock_detail_beforList"), isEnable: false)
        }
        if market == kYXMarketUS && type2 == .stLowAdr {
            if (quoteModel.otcTradingType?.value ?? 0) == 0 {
                // 低级adr且这个不支持交易的时候
                self.refreshTradeButtonGrayStyle(with: YXLanguageUtility.kLang(key: "hold_trade_title"), isEnable: true)
                isUnSupportTrade = true
            } else {
                isLowAdrSupportTrade = true
            }
        }
    }
    
    /// 刷新自选状态
    @objc func resetSelfSelectState(with market: String, symbol: String) {
        
        let item = YXStockDetailItem.init()
        item.market = market
        item.symbol = symbol
        
        self.selfSelectButotn.isSelected = YXSecuGroupManager.shareInstance().containsSecu(item)
    }
    /// 刷新债券状态
    @objc func resetBondStatus(with isShow: Bool) {
        self.boundButton.isHidden = !isShow
    }
    /// 刷新月供状态
    @objc func resetMonthlyStatus(with isShow: Bool) {
        self.monthlyButton.isHidden = !isShow
    }
    /// 刷新期权按钮状态
    @objc func resetOptionChainStatus(with isShow: Bool) {
//        self.optionChainButton.isHidden = !isShow
        if isShow {
            if !expandList.contains(.option) {
                /// 加在智能单前面, 否则就加在最后
                if expandList.contains(.smart), expandList.count > 1 {
                    let index = expandList.count - 1
                    expandList.insert(.option, at: index)
                } else {
                    expandList.append(.option)
                }
            }
        }
    }
    /// 刷新ipo状态
    func resetIpoStockButtons(with stockStatusInfoModel: YXNewStockDetailInfoModel) {
        let subscribeWayArr = stockStatusInfoModel.subscribeWay?.components(separatedBy: ",") ?? []
        let remindTime = stockStatusInfoModel.remainingTime ?? 0
        let status = YXNewStockPurcahseStatus.currentStatus(stockStatusInfoModel.status)
        let ecmStatus = YXNewStockPurcahseStatus.currentStatus(stockStatusInfoModel.ecmStatus)
        
        if subscribeWayArr.count == 1 && subscribeWayArr.contains(String(YXNewStockSubsType.internalSubs.rawValue)) && stockStatusInfoModel.ecmStatus == 13 {
            // 仅支持国际认购, 且国际认购是暂停状态
            self.refreshTradeButtonGrayStyle(with: YXLanguageUtility.kLang(key: "stock_detail_new_beforBug"), isEnable: false)
        } else {
            if remindTime <= 0 {
                // 认购结束
                self.refreshTradeButtonGrayStyle(with: YXLanguageUtility.kLang(key: "newStock_purchase_stop"), isEnable: false)
                
            } else if status == .purchasing || ecmStatus == .purchasing {
                // 认购中
                self.tradeButton.isUserInteractionEnabled = true
                self.tradeButton.setTitle(YXLanguageUtility.kLang(key: "hold_new_stock"), for: .normal)
            } else if status == .waited || ecmStatus == .waited {
                self.refreshTradeButtonGrayStyle(with: YXLanguageUtility.kLang(key: "stock_detail_new_beforBug"), isEnable: false)
            } else {
                //已经上市
                self.tradeButton.setTitle(YXLanguageUtility.kLang(key: "hold_trade_title"), for: .normal)
                self.tradeButton.isUserInteractionEnabled = true
            }
        }
        
    }
    
    @objc func refreshTradeButtonTitle(with title: String?) {
        self.tradeButton.setTitle(title, for: .normal)
    }
    
    func refreshTradeButtonEnable(with isEnable: Bool) {
        self.tradeButton.isEnabled = isEnable
    }
    
    func refreshTradeButtonOpenAccountStatus(with isOpenAccount: Bool) {
//        YXLanguageUtility.kLang(key: "tab_open_account")
        if !isOpenAccount {
            self.tradeButton.setTitle(YXLanguageUtility.kLang(key: "tab_open_account"), for: .normal)
        } else {
            self.tradeButton.setTitle(YXLanguageUtility.kLang(key: "hold_trade_title"), for: .normal)
        }
    }
    
    func refreshRemindButtonSelectStatus(with isSelect: Bool) {
        self.remindButton.isSelected = isSelect
    }
}

// MARK: - 按钮点击
extension StockDetailBottomView {
    @objc private func tradeButtonClick(_ sender: UIButton) {
        
        // 判断是不支持的交易
        if isUnSupportTrade {
            // 低级adr不支持的
            self.tipClosure?(YXLanguageUtility.kLang(key: "adr_trade_tips"))
            return
        }
        
        if self.expandList.count > 1 {
            menuView.items = expandList.map({ type -> QMUIPopupMenuButtonItem in
                let item = QMUIPopupMenuButtonItem(image: UIImage(named: type.iconName), title: type.text) { [weak self] (item) in
                    guard let `self` = self else { return }
                    self.menuView.hideWith(animated: false)
                    /// otc的票风险提醒
                    if self.isLowAdrSupportTrade {
                        let showed = MMKV.default().bool(forKey: kLowAdrShowRiskWarnningKey, defaultValue: false)
                        if !showed {
                            self.showRiskWarnningTip()
                            return
                        }
                    }
                    
                    if type == .smart {
                        self.smartTradeClosure?(item.button)
                    } else if type == .dayMargin {
                        self.dayMarginTradeClosure?(item.button)
                    } else if type == .normalTrade {
                        self.normalTradeClosure?(item.button)
                    } else if type == .fractional {
                        YXToolUtility.handleCanTradeFractional {
                            self.fractionalTradeClosure?(item.button)
                        }
                    } else if type == .option {
                        self.optionChainClosure?(item.button)
                    }
                }
                item.button.contentHorizontalAlignment = .left
                item.button.spacingBetweenImageAndTitle = 8
                item.highlightedBackgroundColor = .clear
                item.button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 8, bottom: 0, right: 0)
                item.button.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 8)
                return item
            })
            sender.isSelected = true
            menuView.showWith(animated: false)
        } else {
            self.normalTradeClosure?(sender)
        }
    }
    
    @objc private func refreshTradeButtonGrayStyle(with title: String, isEnable: Bool) {
        self.tradeButton.setTitle(title, for: .normal)
        self.tradeButton.backgroundColor = QMUITheme().textColorLevel3()
        self.isUserInteractionEnabled = isEnable
    }
    
    private func showRiskWarnningTip() {
        
        
        let customerView = OTCRiskTipView.init()
        customerView.frame = CGRect.init(x: 0, y: 0, width: customerView.containerW, height: customerView.totalHeight)
                
        let alertView = YXAlertView.alertView(title: YXLanguageUtility.kLang(key: "otc_risk_title"), message: nil)
        alertView.clickedAutoHide = false
        alertView.addCustomView(customerView)
        
        customerView.clickHighlightCallBack = { [weak alertView] in
            alertView?.hide()
            YXWebViewModel.pushToWebVC(YXH5Urls.otcRiskTipUrl())
        }
        
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView] _ in
            alertView?.hide()
        }))
        alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { [weak customerView, weak alertView] (action) in
            if customerView?.chooseBtn.isSelected ?? false {
                MMKV.default().set(true, forKey: kLowAdrShowRiskWarnningKey)
                alertView?.hide()
            } else {
                YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: "otc_risk_agree_tip"))
            }
        }))
        alertView.showInWindow()
    }
}


class OTCRiskTipView: UIView {
    
    var totalHeight: CGFloat {
        return messageHeigh + bottomTipHeigh + 20 + topPadding
    }
    
    var clickHighlightCallBack: (()->())?
    
    private var messageHeigh: CGFloat = 0
    
    private var bottomTipHeigh: CGFloat = 0
    
    private var topPadding: CGFloat = 6
    
    let containerW: CGFloat = 286
    
    private lazy var messageLabel: YYLabel = {
        let label = YYLabel()
        label.textColor = QMUITheme().textColorLevel2()
        label.font = .systemFont(ofSize: 14)
        label.lineBreakMode = .byWordWrapping
        
        let string = YXLanguageUtility.kLang(key: "otc_risk_highlight_tip")
        let messageTip = YXLanguageUtility.kLang(key: "otc_risk_message_tip")
        let attributeString = NSMutableAttributedString(string: messageTip,
                                                        attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                     .foregroundColor: QMUITheme().textColorLevel3()])
        let range = (messageTip as NSString).range(of: string)
        attributeString.yy_setTextHighlight(range, color: QMUITheme().themeTintColor(), backgroundColor: nil) { [weak self] _, _, _, _ in
            self?.clickHighlightCallBack?()
        }
        attributeString.yy_setUnderlineColor(QMUITheme().themeTintColor(), range: range)
        attributeString.yy_setUnderlineStyle(.single, range: range)
        
        label.textVerticalAlignment = .top
        label.numberOfLines = 0
        label.attributedText = attributeString

        let layout = YYTextLayout.init(containerSize: CGSize(width: containerW - 32, height: CGFloat.greatestFiniteMagnitude), text: attributeString)
        self.messageHeigh = layout?.textBoundingSize.height ?? 0
        
        return label
    }()
    
    private lazy var chooseLab: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.normalFont14()
        label.text = YXLanguageUtility.kLang(key: "otc_risk_message_agree_tip")
//        label.textAlignment = .center
        label.numberOfLines = 0
        bottomTipHeigh = YXToolUtility.getStringSize(with: label.text!, andFont: UIFont.normalFont14(), andlimitWidth: Float(containerW - 68)).height
        return label
    }()
    
    lazy var chooseBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setImage(UIImage(named: "yx_v2_small_select"), for: .normal)
        btn.setImage(UIImage(named: "yx_v2_small_selected_empty"), for: .selected)
        btn.isSelected = true
        btn.qmui_tapBlock = { sender in
            let value = sender?.isSelected ?? false
            sender?.isSelected = !value
        }
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: containerW, height: 100))
        
        initialUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialUI() {
        addSubview(messageLabel)
        addSubview(chooseBtn)
        addSubview(chooseLab)
        
        messageLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(self.topPadding)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(self.messageHeigh)
        }
        
        chooseLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(52)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
        }
        
        chooseBtn.snp.makeConstraints { make in
            make.left.equalTo(messageLabel)
            make.width.height.equalTo(20)
            make.centerY.equalTo(chooseLab)
        }
    }
}
