//
//  YXHoldInfoView.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

let kHoldInfoSecretKey = "yx_hold_info_secret"

let kHoldInfoExpandKey = "yx_hold_info_expand"

class ChangeAccountView: UIView {
    
    lazy var changeAccountLabel: UILabel = {
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "day_margin_account")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().foregroundColor()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_change_intraday")
        return imageView
    }()
    
    override init(frame: CGRect) {
        var rect = CGRect(x: 0, y: 0, width: 120, height: 24)
        if YXUserManager.isENMode() {
            if YXConstant.screenWidth == 320 {
                rect = CGRect(x: 0, y: 0, width: 130, height: 24)
            } else {
                rect = CGRect(x: 0, y: 0, width: 160, height: 24)
            }
        }
        super.init(frame: rect)
        
        layer.cornerRadius = 12
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor

        let arrowView = UIImageView()
        arrowView.image = UIImage(named: "right_arrow")
        addSubview(arrowView)

        arrowView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-3)
            make.top.equalTo(5)
            make.size.equalTo(CGSize(width: 15, height: 15))
        }
        
        addSubview(changeAccountLabel)
        addSubview(iconView)

        iconView.snp.makeConstraints { (make) in
            make.left.equalTo(8)
            make.top.equalTo(5)
            make.size.equalTo(CGSize(width: 15, height: 15))
        }

        changeAccountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.top.equalTo(5)
            make.right.equalTo(arrowView.snp.left)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class YXHoldInfoView: UIView {
    
    typealias ClosureClick = () -> Void
    typealias ClosureAccount = (_ accountType: AssetAccountType) -> Void
    
    @objc enum AssetAccountType: Int {
        case cash = 0
        case margin = 1
        case intraday = 2
        case option = 3
        case shortSell = 4
        
        var title: String {
            switch self {
            case .cash:
                return YXLanguageUtility.kLang(key: "hold_cash_account")
            case .margin:
                return YXLanguageUtility.kLang(key: "hold_margin_account")
            case .intraday:
                return YXLanguageUtility.kLang(key: "day_margin_account")
            case .option:
                return YXLanguageUtility.kLang(key: "us_options_account")
            case .shortSell:
                return YXLanguageUtility.kLang(key: "short_selling_account")
            }
        }
        
        var changeTitle: String {
            switch self {
            case .cash:
                return YXLanguageUtility.kLang(key: "hold_cash_account")
            case .margin:
                return YXLanguageUtility.kLang(key: "hold_margin_account_change")
            case .intraday:
                return YXLanguageUtility.kLang(key: "day_margin_account")
            case .option:
                return YXLanguageUtility.kLang(key: "us_options_account")
            case .shortSell:
                return YXLanguageUtility.kLang(key: "short_selling_account")
            }
        }
    }
    
    // 市场类型
    private var exchangeType: YXExchangeType = .hk
    
    // 是否展开
    public static var isExpanded: Bool = MMKV.default().bool(forKey: "\(kHoldInfoExpandKey)\(YXUserManager.userUUID())", defaultValue: false)
    
    // 是否加密展示
    public static var isSecretDisplay: Bool = false
    
    // 展開或收起的點擊事件
    @objc var onClickExpand: ((Bool) -> Void)?
    //是否加密 点击事件
    @objc var onClickSecret: ClosureClick?
    @objc var onClickShare: ClosureClick?
    @objc var onClickQuestion: ClosureClick?
    @objc var onClickPurchase: ClosureClick?
    @objc var onClickOptionAssets: ClosureClick?
    @objc var onClickPurchaseIndex: ClosureClick?
    
    @objc var onClickChangeAccount: ClosureAccount?
    
    var accountType: AssetAccountType = .cash {
        didSet {
            if oldValue != accountType {
                if let index = otherAccountTypes.firstIndex(of: accountType) {
                    otherAccountTypes.replaceSubrange(index...index, with: [oldValue])
                }
                changeAccount()
            }
        }
    }
    
    var otherAccountTypes: [AssetAccountType] = []
    
    var canIntraday = false
    var canShortSell = false
    
    @objc func changeAccount() {
        resetUI()
        refreshUI()
        onClickChangeAccount?(accountType)
        
        //MMKV.default().set(Int64(accountType.rawValue), forKey: keyCurrentAccountType(market))
    }
    
    var assetModel: YXAssetModel? {
        didSet {
            if accountType == .cash || accountType == .margin {
                refreshUI()
            }
        }
    }
    
    var intradayAssetModel: YXAssetModel? {
        didSet {
            if accountType == .intraday {
                refreshUI()
            }
        }
    }
    
    var shortSellAssetModel: YXAssetModel? {
        didSet {
            if accountType == .shortSell {
                refreshUI()
            }
        }
    }
    
    var optionAssetModel: YXAssetModel? {
        didSet {
            if accountType == .option {
                refreshUI()
            }
        }
    }
    
    func resetUI() {
        subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        initView()
    }
    
    // 金额格式化
    fileprivate lazy var moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0.00";
        formatter.locale = Locale(identifier: "zh")
        return formatter;
    }()
    //展开收起 按钮
    lazy var expandButton: QMUIButton = {
        let expandButton = QMUIButton()
        return expandButton
    }()
    
//    lazy var tipView: YXIntradayTipView = {
//        let view = YXIntradayTipView()
//        view.tipType = .account
//        view.backgroundColor = .clear
//        view.isHidden = true
//        view.autoresizingMask = .flexibleBottomMargin
//
//        return view
//    }()
    
    // 背景色
    var gradientView: CAGradientView!
    
    lazy var accountImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var accountNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    @objc lazy var shareBtn: YXExpandAreaButton = {
        let btn = YXExpandAreaButton()
        btn.expandX = 10
        btn.expandY = 10
        btn.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        let imageView = UIImageView()
        imageView.image = UIImage(named: "hold_share_white")
        btn.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(13)
            make.right.equalToSuperview().offset(-8)
            make.top.bottom.equalToSuperview()
        }

        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "share_profit_loss")
        label.textColor = UIColor.white
        label.font = .systemFont(ofSize: 12)
        btn.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(imageView)
            make.right.equalTo(imageView.snp.left).offset(-5)
            make.left.equalToSuperview()
        }
        return btn
    }()

    @objc func shareAction() {
        self.onClickShare?()
    }
    
    // 港股/美股净资产【标题】
    lazy var totalAssetTitleLabel: UILabel = {
        let totalAssetTitleLabel = UILabel()
        totalAssetTitleLabel.font = UIFont.systemFont(ofSize: 14)
        totalAssetTitleLabel.textAlignment = .left
        totalAssetTitleLabel.adjustsFontSizeToFitWidth = true
        totalAssetTitleLabel.minimumScaleFactor = 0.3
        if self.exchangeType == .hk {
            totalAssetTitleLabel.text = YXLanguageUtility.kLang(key: "hold_hk_net_liquidation_value")
        } else if exchangeType == .us || exchangeType == .usop {
            totalAssetTitleLabel.text = YXLanguageUtility.kLang(key: "hold_us_net_liquidation_value")
        } else {
            totalAssetTitleLabel.text = YXLanguageUtility.kLang(key: "hold_cn_net_liquidation_value")
        }
        totalAssetTitleLabel.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.7)
        
        totalAssetTitleLabel.isUserInteractionEnabled = true
        let ges = UITapGestureRecognizer { [weak self] (tap) in
            guard let strongSelf = self else { return }
            if strongSelf.accountType == .option {
                strongSelf.onClickOptionAssets?()
            } else if strongSelf.accountType == .margin {
                strongSelf.onClickPurchase?()
            }
        }
        totalAssetTitleLabel.addGestureRecognizer(ges)
        
        return totalAssetTitleLabel
    }()
    
    
    // 显示或隐藏资产的眼睛
    lazy var displayOrHideBtn: QMUIButton = {
        let displayOrHideBtn = QMUIButton()
        displayOrHideBtn.setImage(UIImage(named: "display"), for: .normal)
        return displayOrHideBtn
    }()
    
    lazy var questionButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "question"), for: .normal)
        button.isHidden = true
        
        button.rx.tap.asObservable().subscribe(onNext: { [weak self] () in
            self?.onClickQuestion?()
        }).disposed(by: rx.disposeBag)
        
        return button
    }()
    
    lazy var lookArrowView: UIImageView = {
        let arrowView = UIImageView(image: UIImage(named: "common_arrow"))
        arrowView.contentMode = .center
        
        arrowView.isUserInteractionEnabled = true
        let ges = UITapGestureRecognizer { [weak self] (tap) in
            guard let strongSelf = self else { return }

            if strongSelf.accountType == .option {

                strongSelf.onClickOptionAssets?()
            } else {
                strongSelf.onClickPurchase?()
            }
        }
        arrowView.addGestureRecognizer(ges)
        
        return arrowView
    }()
    
    
    // 港股/美股实际总资产金额
    // 190,927.00
    lazy var totalAssetLabel: UILabel = {
        let totalAssetLabel = UILabel()
        totalAssetLabel.textAlignment = .left
        totalAssetLabel.textColor = QMUITheme().textColorLevel1()
        totalAssetLabel.text = "--"
        totalAssetLabel.adjustsFontSizeToFitWidth = true
        totalAssetLabel.minimumScaleFactor = 0.3
        return totalAssetLabel
    }()
    
    lazy var holdProfitLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = QMUITheme().foregroundColor()
        label.text = "--"
        return label
    }()
    
    lazy var todayProfitLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = QMUITheme().foregroundColor()
        label.text = "--"
        return label
    }()
    
    //盘前盘后标记
    lazy var openPreLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.baselineAdjustment = UIBaselineAdjustment.alignCenters
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 10)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.text = ""
        label.isHidden = true
        label.layer.cornerRadius = 2
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 0.5
        label.layer.masksToBounds = true
        
        return label
    }()

//    // 日盈亏
//    lazy var dailyProfitLossView: YXHoldInfoTextView = {
//        let view = YXHoldInfoTextView()
//        view.setTitleLabelText(YXLanguageUtility.kLang(key: "hold_daily_profit_loss"))
//        return view
//    }()
//
    // 股票市值
    lazy var stockMarketValueView: YXHoldInfoTextView = {
        let view = YXHoldInfoTextView()
        view.setTitleLabelText(YXLanguageUtility.kLang(key: "hold_stock_market_value"))
        return view
    }()
    
    // 购买力
    lazy var purchasePowerView: YXHoldInfoTextView = {
        let view = YXHoldInfoTextView()
        //view.isUserInteractionEnabled = true
        view.setTitleLabelText(YXLanguageUtility.kLang(key: "hold_purchase_power"))
        return view
    }()
    
    lazy var dibitBalanceView: YXHoldInfoTextView = {
        let view = YXHoldInfoTextView()
        view.setTitleLabelText(YXLanguageUtility.kLang(key: "hold_margin_loans"))
        return view
    }()
    
    lazy var callMarginCallView: YXHoldInfoTextView = {
        let view = YXHoldInfoTextView()
        view.setTitleLabelText(YXLanguageUtility.kLang(key: "hold_margin_call"))
        return view
    }()
    
    
    // 风控水平
    lazy var riskLevelView: YXHoldInfoTextView = {
        let view = YXHoldInfoTextView()
        view.isUserInteractionEnabled = true
        view.setTitleLabelText(YXLanguageUtility.kLang(key: "hold_risk_level"))
        
        view.addSubview(self.riskStatusLabel)
        
        view.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
            guard let strongSelf = self else { return }
            
            if ges.state == .ended {
                YXHoldInfoView.showRiskLevelCustomView(ges)
            }
        }).disposed(by: rx.disposeBag)

        
        return view
    }()
    
    @objc class func showRiskLevelCustomView(_ ges: UITapGestureRecognizer) {
        ges.isEnabled = false;
        let requestModel = YXRiskInfoRequestModel()
        let request = YXRequest(request: requestModel)
        request.startWithBlock(success: { (responseModel) in
            if let model = responseModel as? YXRiskInfoResponseModel, model.code == .success, model.list.count > 3  {
                let alertView = YXAlertView()
                let action = YXAlertAction(title: YXLanguageUtility.kLang(key: "newStock_see_more"), style: YXAlertAction.YXAlertActionStyle.default) {(action) in
                    YXWebViewModel.pushToWebVC(YXH5Urls.YX_TRADE_ASSET_DESC_URL_FROM_RISKLEVEL())
                }
                let customView = UIView(frame: CGRect(x: 0, y: 0, width: 285, height: 130) )
                
                let layerView = UIView()
                layerView.frame = CGRect(x: 30, y: -20, width: 225, height: 26)
                // fillCode
                let bgLayer1 = CAGradientLayer()
                bgLayer1.colors = [UIColor(red: 0.59, green: 0.74, blue: 0.93, alpha: 1).cgColor, UIColor(red: 0.3, green: 0.43, blue: 0.7, alpha: 1).cgColor]
                bgLayer1.locations = [0, 1]
                bgLayer1.frame = layerView.bounds
                bgLayer1.startPoint = CGPoint(x: 0.23, y: -0.31)
                bgLayer1.endPoint = CGPoint(x: 1.4, y: 1.4)
                layerView.layer.addSublayer(bgLayer1)
                customView.addSubview(layerView)
                
                let label1 = UILabel()
                label1.text = YXLanguageUtility.kLang(key: "hold_risk_ratio")
                label1.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                label1.textAlignment = .center
                label1.textColor = UIColor.white
                layerView.addSubview(label1)
                label1.snp.makeConstraints { (make) in
                    make.left.equalTo(0)
                    make.centerY.equalToSuperview()
                    make.width.equalTo(135)
                }
                
                let label2 = UILabel()
                label2.text = YXLanguageUtility.kLang(key: "hold_risk_level")
                label2.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                label2.textAlignment = .center
                label2.textColor = UIColor.white
                layerView.addSubview(label2)
                label2.snp.makeConstraints { (make) in
                    make.right.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.width.equalTo(90)
                }
                
                let subView1 = UIView()
                subView1.frame = CGRect(x: 30, y: 10, width: 225, height: 26)
                subView1.backgroundColor = UIColor.qmui_color(withHexString: "#E1E1E1")?.withAlphaComponent(0.2)
                customView.addSubview(subView1)
                
                let subView2 = UIView()
                subView2.frame = CGRect(x: 30, y: 40, width: 225, height: 26)
                subView2.backgroundColor = UIColor.qmui_color(withHexString: "#E1E1E1")?.withAlphaComponent(0.2)
                customView.addSubview(subView2)
                
                let subView3 = UIView()
                subView3.frame = CGRect(x: 30, y: 70, width: 225, height: 26)
                subView3.backgroundColor = UIColor.qmui_color(withHexString: "#E1E1E1")?.withAlphaComponent(0.2)
                customView.addSubview(subView3)
                
                let subView4 = UIView()
                subView4.frame = CGRect(x: 30, y: 100, width: 225, height: 26)
                subView4.backgroundColor = UIColor.qmui_color(withHexString: "#E1E1E1")?.withAlphaComponent(0.2)
                customView.addSubview(subView4)
                
                let leftLabel1 = UILabel()
                leftLabel1.frame = CGRect(x: 0, y: 0, width: 135, height: 26)
                leftLabel1.text = model.list[0].radio
                leftLabel1.font = UIFont.systemFont(ofSize: 10)
                leftLabel1.textColor = .black
                leftLabel1.textAlignment = .center
                subView1.addSubview(leftLabel1)
                
                let leftLabel2 = UILabel()
                leftLabel2.frame = CGRect(x: 0, y: 0, width: 135, height: 26)
                leftLabel2.text = model.list[1].radio
                leftLabel2.font = UIFont.systemFont(ofSize: 10)
                leftLabel2.textColor = .black
                leftLabel2.textAlignment = .center
                subView2.addSubview(leftLabel2)
                
                let leftLabel3 = UILabel()
                leftLabel3.frame = CGRect(x: 0, y: 0, width: 135, height: 26)
                leftLabel3.text = model.list[2].radio
                leftLabel3.font = UIFont.systemFont(ofSize: 10)
                leftLabel3.textColor = .black
                leftLabel3.textAlignment = .center
                subView3.addSubview(leftLabel3)
                
                let leftLabel4 = UILabel()
                leftLabel4.frame = CGRect(x: 0, y: 0, width: 135, height: 26)
                leftLabel4.text = model.list[3].radio
                leftLabel4.font = UIFont.systemFont(ofSize: 10)
                leftLabel4.textColor = .black
                leftLabel4.textAlignment = .center
                subView4.addSubview(leftLabel4)
                
                let rightLabel1 = UILabel()
                rightLabel1.frame = CGRect(x: 135, y: 0, width: 90, height: 26)
                rightLabel1.text = model.list[0].name
                rightLabel1.font = UIFont.systemFont(ofSize: 10, weight: .medium)
                rightLabel1.textColor = UIColor.qmui_color(withHexString: "#41CA1E")
                rightLabel1.textAlignment = .center
                subView1.addSubview(rightLabel1)
                 
                let rightLabel2 = UILabel()
                rightLabel2.frame = CGRect(x: 135, y: 0, width: 90, height: 26)
                rightLabel2.text = model.list[1].name
                rightLabel2.font = UIFont.systemFont(ofSize: 10, weight: .medium)
                rightLabel2.textColor = UIColor.qmui_color(withHexString: "#FFBA00")
                rightLabel2.textAlignment = .center
                subView2.addSubview(rightLabel2)
                
                let rightLabel3 = UILabel()
                rightLabel3.frame = CGRect(x: 135, y: 0, width: 90, height: 26)
                rightLabel3.text = model.list[2].name
                rightLabel3.font = UIFont.systemFont(ofSize: 10, weight: .medium)
                rightLabel3.textColor = UIColor.qmui_color(withHexString: "##FF7127")
                rightLabel3.textAlignment = .center
                subView3.addSubview(rightLabel3)
                
                let rightLabel4 = UILabel()
                rightLabel4.frame = CGRect(x: 135, y: 0, width: 90, height: 26)
                rightLabel4.text = model.list[3].name
                rightLabel4.font = UIFont.systemFont(ofSize: 10, weight: .medium)
                rightLabel4.textColor = UIColor.qmui_color(withHexString: "#FF295A")
                rightLabel4.textAlignment = .center
                rightLabel4.adjustsFontSizeToFitWidth = true
                rightLabel4.minimumScaleFactor = 0.3
                subView4.addSubview(rightLabel4)
                
                alertView.addCustomView(customView)
                
                alertView.addAction(action)
                alertView.showInWindow(withBackgoundTapDismissEnable: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ges.isEnabled = true
            }
        }, failure: { (request) in
            ges.isEnabled = true
        })
    }
    
//    // 持仓盈亏
//    lazy var positionProfitLossView: YXHoldInfoTextView = {
//        let view = YXHoldInfoTextView()
//        view.setTitleLabelText(YXLanguageUtility.kLang(key: "hold_position_profit_loss"))
//        return view
//    }()
//
    // 冻结现金
    lazy var freezingCashView: YXHoldInfoTextView = {
        let view = YXHoldInfoTextView()
        view.setTitleLabelText(YXLanguageUtility.kLang(key: "hold_freezing_cash"))
        return view
    }()
    
    // 可取现金
    lazy var cashAvailableView: YXHoldInfoTextView = {
        let view = YXHoldInfoTextView()
        view.setTitleLabelText(YXLanguageUtility.kLang(key: "hold_cash_available"))
        return view
    }()
    
    // 剩余可融资金额
    lazy var remainMoneyView: YXHoldInfoTextView = {
        let view = YXHoldInfoTextView()
        view.setTitleLabelText(YXLanguageUtility.kLang(key: "trade_account_remainMoney"))
        return view
    }()
    
    lazy var mvPercentView: YXHoldInfoTextView = {
        let mvPercentView = YXHoldInfoTextView()
        mvPercentView.setTitleLabelText(YXLanguageUtility.kLang(key: "risk_ratio"))
        return mvPercentView
    }()
    
    lazy var initialMarginValueView: YXHoldInfoTextView = {
        let initialMarginValueView = YXHoldInfoTextView()
        initialMarginValueView.setTitleLabelText(YXLanguageUtility.kLang(key: "short_pos_init_margin_funds"))
        return initialMarginValueView
    }()
    
    lazy var maintenanceMarginView: YXHoldInfoTextView = {
        let maintenanceMarginView = YXHoldInfoTextView()
        maintenanceMarginView.setTitleLabelText(YXLanguageUtility.kLang(key: "short_term_maint_margin"))
        return maintenanceMarginView
    }()
    
    // 债券市值
    lazy var bondMarketValueView: YXHoldInfoTextView = {
        let bondMarketValueView = YXHoldInfoTextView()
        bondMarketValueView.setTitleLabelText(YXLanguageUtility.kLang(key: "account_bond_value"))
        return bondMarketValueView
    }()
    
    // 在途现金
    lazy var onWayValueView: YXHoldInfoTextView = {
        let onWayValueView = YXHoldInfoTextView()
//        onWayValueView.isUserInteractionEnabled = true
        onWayValueView.setTitleLabelText(YXLanguageUtility.kLang(key: "account_cash_in_transit"))
        
        if accountType == .cash {
            onWayValueView.isUserInteractionEnabled = true
            let infoButton = UIButton()
            infoButton.setImage(UIImage(named: "onway_about"), for: .normal)
            onWayValueView.addSubview(infoButton)
            
            onWayValueView.titleLabel.snp.remakeConstraints { (make) in
                make.left.top.equalToSuperview()
                make.height.equalTo(26)
                make.right.lessThanOrEqualToSuperview().offset(-25)
            }
            
            infoButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(onWayValueView.titleLabel).offset(1)
                make.left.equalTo(onWayValueView.titleLabel.snp.right).offset(2)
            }
            
            infoButton.rx.tap.asObservable().subscribe(onNext: { () in
                YXWebViewModel.pushToWebVC(YXH5Urls.YX_TRADE_ASSET_DESC_URL())
            }).disposed(by: rx.disposeBag)
        }

        
        return onWayValueView
    }()
    
    // 展开或收起的箭头
    lazy var expandArrow: QMUIButton = {
        let expandArrow = QMUIButton()
        expandArrow.setImage(UIImage(named: "down_arrow"), for: .normal)
        expandArrow.autoresizingMask = .flexibleBottomMargin
        return expandArrow
    }()
    
    lazy var riskStatusLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    lazy var holdProfitTextLabel: UILabel = {
        let holdProfitTextLabel = UILabel()
        holdProfitTextLabel.font = .systemFont(ofSize: 12)
        holdProfitTextLabel.text = YXLanguageUtility.kLang(key: "hold_position_profit_loss")
        holdProfitTextLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        holdProfitTextLabel.adjustsFontSizeToFitWidth = true
        holdProfitTextLabel.minimumScaleFactor = 0.3
        
        return holdProfitTextLabel
    }()
   
    
    lazy var purchaseInfoButton: UIButton = {
        let infoButton = UIButton()
        infoButton.setImage(UIImage(named: "onway_about"), for: .normal)

        
        infoButton.rx.tap.asObservable().subscribe(onNext: { [weak self] () in
            let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "purchase_power_tip"))
            let action = YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: YXAlertAction.YXAlertActionStyle.default) { (action) in
            }
            alertView.addAction(action)
            alertView.showInWindow()
            
        }).disposed(by: rx.disposeBag)
        return infoButton
    }()

    lazy var upgradeView: UIView = {
        let layerView = UIView()
        if YXUserManager.isENMode() {
            if YXConstant.screenWidth == 320 {
                layerView.frame = CGRect(x: 0, y: 0, width: 140, height: 24)
            } else {
                layerView.frame = CGRect(x: 0, y: 0, width: 160, height: 24)
            }
        } else {
            layerView.frame = CGRect(x: 0, y: 0, width: 100, height: 24)
        }
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(red: 0.05, green: 0.75, blue: 0.95, alpha: 1).cgColor, UIColor(red: 0.33, green: 0.35, blue: 0.94, alpha: 1).cgColor]
        bgLayer1.locations = [0, 1]
        bgLayer1.frame = layerView.bounds
        bgLayer1.startPoint = CGPoint(x: 0, y: -0.4)
        bgLayer1.endPoint = CGPoint(x: 1, y: 1)
        bgLayer1.cornerRadius = 12
        bgLayer1.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        bgLayer1.masksToBounds = true
        
        layerView.layer.cornerRadius = 12
        layerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        layerView.layer.masksToBounds = true
        layerView.layer.addSublayer(bgLayer1)
        
        let arrowView = UIImageView()
        arrowView.image = UIImage(named: "right_arrow")
        layerView.addSubview(arrowView)
        
        arrowView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-2)
            make.top.equalTo(5)
        }
        
        let label = UILabel()
        label.text = YXLanguageUtility.kLang(key: "hold_upgrade_margin_account")
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textColor = QMUITheme().foregroundColor()
        layerView.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.left.equalTo(8)
            make.top.equalTo(5)
            make.right.equalTo(arrowView.snp.left)
        }
        
        layerView.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
            guard let strongSelf = self else { return }
            
            if ges.state == .ended {
                if YXUserManager.isGray(with: YXGrayStatusBitType.margin) {                    YXWebViewModel.presentToWebVC(YXH5Urls.YX_TRADE_ACCOUNT_UPDATE_TO_MARGIN_URL(exchangeType: self?.exchangeType.rawValue ?? 0))
                } else {
                    let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "hold_margin_gray_tips"))
                    let action = YXAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: YXAlertAction.YXAlertActionStyle.default) { (action) in
                    }
                    alertView.addAction(action)
                    alertView.showInWindow()
                }
            }
        }).disposed(by: rx.disposeBag)
        
        return layerView
    }()
    
    required init(frame: CGRect, exchangeType: YXExchangeType) {
        super.init(frame: frame)
        // 当前市场类型
        self.exchangeType = exchangeType
        
        if exchangeType == .usop {
            accountType = .option
        } else {
            
            if YXUserManager.isFinancing(market: exchangeType.market) {
                accountType = .margin
            }
            
            var types: [AssetAccountType] = []

            if YXUserManager.isShortSell(exchangeType.market) {
                canShortSell = true
                //isShortSell = true //MMKV.default().bool(forKey: keyCurrentIsIntraday(exchangeType.market))
                types.append(.shortSell)
            }
            
            if exchangeType == .hk || exchangeType == .us {
                types.append(.intraday)
            }
            
            if YXUserManager.isIntraday(exchangeType.market) {
                canIntraday = true
                //isIntraday = MMKV.default().bool(forKey: keyCurrentIsIntraday(exchangeType.market))
            }
            otherAccountTypes = types
        }
        
        // 當前是否顯示***
        YXHoldInfoView.isSecretDisplay = MMKV.default().bool(forKey: "\(kHoldInfoSecretKey)\(YXUserManager.userUUID())", defaultValue: false)
//
//        YXHoldInfoView.isExpanded = MMKV.default().bool(forKey: "\(kHoldInfoExpandKey)\(YXUserManager.userUUID())", defaultValue: false)
        
        initView()
    }
    
    func keyCurrentIsIntraday(_ market: String) -> String {
        return market + "CurrentIsIntraday" + "\(YXUserManager.userUUID())"
    }
    
    func keyCurrentIsShortSell(_ market: String) -> String {
        return market + "CurrentIsShortSell" + "\(YXUserManager.userUUID())"
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initAsstsViews() {
        stockMarketValueView.setTitleLabelText(YXLanguageUtility.kLang(key: "hold_stock_market_value"))
        gradientView.addSubview(upgradeView)
        upgradeView.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.width.equalTo(upgradeView.bounds.width)
            make.centerY.equalTo(accountImageView)
            make.height.equalTo(24)
        }
        
        //第一行
//        gradientView.addSubview(self.dailyProfitLossView)
        gradientView.addSubview(purchasePowerView)
        gradientView.addSubview(cashAvailableView)
        gradientView.addSubview(freezingCashView)
        
        //第二行
        gradientView.addSubview(onWayValueView)
        gradientView.addSubview(stockMarketValueView)
        gradientView.addSubview(bondMarketValueView)

       // gradientView.addSubview(self.positionProfitLossView)
        
        let spacing: CGFloat = 14.0
        
        let firstViews = [purchasePowerView, cashAvailableView, freezingCashView]
        firstViews.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: spacing, leadSpacing: spacing, tailSpacing: spacing)
        firstViews.snp.makeConstraints { (make) in
            make.top.equalTo(self.totalAssetLabel.snp.bottom).offset(10)
            make.height.equalTo(43)
        }
        
        var secondViews = [onWayValueView, stockMarketValueView, bondMarketValueView]

        if exchangeType == .hs {
            secondViews = [stockMarketValueView, onWayValueView, bondMarketValueView]
            onWayValueView.isHidden = true
        }
        secondViews.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: spacing, leadSpacing: spacing, tailSpacing: spacing)
        secondViews.snp.makeConstraints { (make) in
            make.top.equalTo(purchasePowerView.snp.bottom).offset(28)
            make.height.equalTo(43)
        }
    }
    
    func initShortSellAsstsViews() {
        accountNameLabel.text = YXLanguageUtility.kLang(key: "short_selling_account")
        
        gradientView.addSubview(stockMarketValueView)
        stockMarketValueView.setTitleLabelText(YXLanguageUtility.kLang(key: "short_pos_mkt_value"))
        gradientView.addSubview(purchasePowerView)
        purchasePowerView.setTitleLabelText(YXLanguageUtility.kLang(key: "newStock_certified_funds"))

        gradientView.addSubview(mvPercentView)
        gradientView.addSubview(initialMarginValueView)
        gradientView.addSubview(maintenanceMarginView)
        gradientView.addSubview(callMarginCallView)
        
        let spacing: CGFloat = 14.0
        
        let firstViews = [stockMarketValueView, purchasePowerView, mvPercentView]
        firstViews.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: spacing, leadSpacing: spacing, tailSpacing: spacing)
        firstViews.snp.makeConstraints { (make) in
            make.top.equalTo(self.totalAssetLabel.snp.bottom).offset(10)
            make.height.equalTo(49)
        }
        
        let secondViews = [initialMarginValueView, maintenanceMarginView, callMarginCallView]
        secondViews.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: spacing, leadSpacing: spacing, tailSpacing: spacing)
        secondViews.snp.makeConstraints { (make) in
            if YXUserManager.isENMode() {
                make.top.equalTo(stockMarketValueView.snp.bottom).offset(32)
            } else {
                make.top.equalTo(stockMarketValueView.snp.bottom).offset(28)
            }

            make.height.equalTo(49)
        }
    }
    
    func initOptionAsstsViews() {
        accountNameLabel.text = YXLanguageUtility.kLang(key: "us_options_account")

        gradientView.addSubview(stockMarketValueView)
        stockMarketValueView.setTitleLabelText(YXLanguageUtility.kLang(key: "stock_detail_marketValue"))
        gradientView.addSubview(purchasePowerView)
        purchasePowerView.setTitleLabelText(YXLanguageUtility.kLang(key: "newStock_certified_funds"))

        gradientView.addSubview(freezingCashView)
        gradientView.addSubview(cashAvailableView)
        gradientView.addSubview(dibitBalanceView)
        
        let spacing: CGFloat = 14.0
        
        let firstViews = [stockMarketValueView, purchasePowerView, freezingCashView]
        firstViews.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: spacing, leadSpacing: spacing, tailSpacing: spacing)
        firstViews.snp.makeConstraints { (make) in
            make.top.equalTo(self.totalAssetLabel.snp.bottom).offset(10)
            make.height.equalTo(43)
        }

        cashAvailableView.snp.makeConstraints { (make) in
            make.top.equalTo(stockMarketValueView.snp.bottom).offset(28)
            make.height.equalTo(43)
            make.left.size.equalTo(stockMarketValueView)
        }
        
        dibitBalanceView.snp.makeConstraints { (make) in
            make.top.equalTo(purchasePowerView.snp.bottom).offset(28)
            make.height.equalTo(43)
            make.left.size.equalTo(purchasePowerView)
        }
    }
    
    func initIntradayAsstsViews() {
        stockMarketValueView.setTitleLabelText(YXLanguageUtility.kLang(key: "hold_stock_market_value"))
        gradientView.addSubview(stockMarketValueView)
        gradientView.addSubview(purchasePowerView)
        gradientView.addSubview(cashAvailableView)
        
        gradientView.addSubview(freezingCashView)
        gradientView.addSubview(dibitBalanceView)
        gradientView.addSubview(remainMoneyView)
        
        let spacing: CGFloat = 14.0
        
        let firstViews = [stockMarketValueView, purchasePowerView, cashAvailableView]
        firstViews.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: spacing, leadSpacing: spacing, tailSpacing: spacing)
        firstViews.snp.makeConstraints { (make) in
            make.top.equalTo(self.totalAssetLabel.snp.bottom).offset(10)
            make.height.equalTo(43)
        }

        freezingCashView.snp.makeConstraints { (make) in
            make.top.equalTo(stockMarketValueView.snp.bottom).offset(28)
            make.height.equalTo(43)
            make.left.size.equalTo(stockMarketValueView)
        }
        
        dibitBalanceView.snp.makeConstraints { (make) in
            make.top.equalTo(purchasePowerView.snp.bottom).offset(28)
            make.height.equalTo(43)
            make.left.size.equalTo(purchasePowerView)
        }
        
        remainMoneyView.snp.makeConstraints { (make) in
            make.top.equalTo(cashAvailableView.snp.bottom).offset(28)
            make.height.equalTo(43)
            make.left.size.equalTo(cashAvailableView)
        }
        
//        gradientView.addSubview(tipView)
//        tipView.snp.makeConstraints { (make) in
//            make.left.right.equalToSuperview()
//            make.bottom.equalToSuperview()
//            make.height.equalTo(30)
//        }
    }
    
    func initMarginAsstsViews() {
        //第一行
        stockMarketValueView.setTitleLabelText(YXLanguageUtility.kLang(key: "hold_stock_market_value"))
        gradientView.addSubview(stockMarketValueView)
        gradientView.addSubview(purchasePowerView)
        gradientView.addSubview(riskLevelView)
        
        //第二行
        gradientView.addSubview(cashAvailableView)
        gradientView.addSubview(dibitBalanceView)
        gradientView.addSubview(freezingCashView)
        
        let spacing: CGFloat = 14.0
        
        let firstViews = [stockMarketValueView, purchasePowerView, riskLevelView]
        firstViews.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: spacing, leadSpacing: spacing, tailSpacing: spacing)
        firstViews.snp.makeConstraints { (make) in
            make.top.equalTo(self.totalAssetLabel.snp.bottom).offset(10)
            make.height.equalTo(43)
        }
        
        let secondViews = [cashAvailableView, dibitBalanceView, freezingCashView]
        secondViews.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: spacing, leadSpacing: spacing, tailSpacing: spacing)
        secondViews.snp.makeConstraints { (make) in
            make.top.equalTo(self.stockMarketValueView.snp.bottom).offset(28)
            make.height.equalTo(43)
        }
    }
    
    func initView() {
        if YXUserManager.isFinancing(market: exchangeType.market) == false && exchangeType != .usop {
            accountType = .cash
        }
        
        self.backgroundColor =  QMUITheme().backgroundColor()
        self.isUserInteractionEnabled = true
        
        gradientView = CAGradientView()
        gradientView.isUserInteractionEnabled = true
        self.addSubview(gradientView)
        gradientView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        gradientView.addSubview(accountImageView)
        gradientView.addSubview(accountNameLabel)
        accountImageView.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(15)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        if exchangeType == .hk {
            accountImageView.image = UIImage(named: "hk_icon")
        } else if exchangeType == .us || exchangeType == .usop {
            accountImageView.image = UIImage(named: "usa_icon")
        } else {
            accountImageView.image = UIImage(named: "cn_icon")
        }
        
        if accountType == .cash || accountType == .option {
            canIntraday = false
            canShortSell = false
            otherAccountTypes = []
        } else {
            canIntraday = YXUserManager.isIntraday(exchangeType.market)
            canShortSell = YXUserManager.isShortSell(exchangeType.market)
            
            if !otherAccountTypes.contains(.shortSell), canShortSell, accountType != .shortSell {
                otherAccountTypes.append(.shortSell)
            }
            
            if !otherAccountTypes.contains(.intraday), canIntraday, accountType != .intraday {
                otherAccountTypes.append(.intraday)
            }
        }
        
        gradientView.addSubview(self.expandButton)
        
        gradientView.addSubview(self.totalAssetTitleLabel)
        gradientView.addSubview(self.totalAssetLabel)
        gradientView.addSubview(self.displayOrHideBtn) // 显示或隐藏资产的眼睛
        gradientView.addSubview(self.questionButton)
        gradientView.addSubview(self.lookArrowView)
        gradientView.addSubview(self.expandArrow)
        gradientView.addSubview(self.shareBtn)
        
        for type in otherAccountTypes {
            let view = ChangeAccountView()
            view.changeAccountLabel.text = type.changeTitle
            gradientView.addSubview(view)
            let index = otherAccountTypes.firstIndex(of: type)!
            let top = index * 30 + 6
            view.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(1)
                make.width.equalTo(view.bounds.width + 1)
                make.top.equalTo(top)
                make.height.equalTo(24)
            }
            
            if type == .intraday, !canIntraday {
                view.iconView.image = UIImage(named: "icon_open_intraday")
                view.changeAccountLabel.text = YXLanguageUtility.kLang(key: "create_day_margin_account")
                view.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
                    guard let strongSelf = self else { return }
                    if ges.state == .ended {
                        YXWebViewModel.pushToWebVC(YXH5Urls.OPEN_DAILY_MARGIN_URL(strongSelf.exchangeType.rawValue))
                    }
                }).disposed(by: rx.disposeBag)
            } else {
                view.rx.tapGesture().subscribe(onNext: { [weak self] (ges) in
                    guard let strongSelf = self else { return }
                    if ges.state == .ended {
                        strongSelf.accountType = type
                        strongSelf.changeAccount()
                    }
                }).disposed(by: rx.disposeBag)
            }
        }
        
        self.shareBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalTo(66)
        }

        accountNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(accountImageView.snp.right).offset(6)
            make.centerY.equalTo(accountImageView)
        }
        
        self.totalAssetTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(10 + 35)
            make.height.equalTo(20)
            if YXUserManager.isENMode() {
                make.right.lessThanOrEqualTo(gradientView.snp.centerX).offset(-20)
            } else {
                make.right.lessThanOrEqualTo(gradientView.snp.centerX)
            }
        }
        
        // 显示或隐藏资产的眼睛
        self.displayOrHideBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self.totalAssetTitleLabel.snp.right).offset(8)
            make.centerY.equalTo(self.totalAssetTitleLabel.snp.centerY)
            make.width.height.equalTo(20)
        }
        
        questionButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.displayOrHideBtn.snp.right)
            make.centerY.equalTo(self.totalAssetTitleLabel.snp.centerY)
            make.width.height.equalTo(20)
        }
        
        lookArrowView.snp.makeConstraints { (make) in
            make.left.equalTo(displayOrHideBtn.snp.right).offset(4)
            make.centerY.equalTo(displayOrHideBtn)
            make.width.equalTo(14)
            make.height.equalTo(14)
        }
        
        gradientView.addSubview(holdProfitTextLabel)
        
        let todayProfitTextLabel = UILabel()
        todayProfitTextLabel.font = .systemFont(ofSize: 12)
        todayProfitTextLabel.text = YXLanguageUtility.kLang(key: "hold_daily_profit_loss")
        todayProfitTextLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        todayProfitTextLabel.adjustsFontSizeToFitWidth = true
        todayProfitTextLabel.minimumScaleFactor = 0.3
        gradientView.addSubview(todayProfitTextLabel)
        
        gradientView.addSubview(holdProfitLabel)
        gradientView.addSubview(todayProfitLabel)

        gradientView.addSubview(openPreLabel)
        holdProfitTextLabel.snp.makeConstraints { (make) in
            make.left.equalTo(gradientView.snp.right).offset(-143)
            make.top.equalTo(89)
            make.width.equalTo(56)
            make.height.equalTo(17)
        }
        
        openPreLabel.snp.makeConstraints { (make) in
            make.right.equalTo(holdProfitTextLabel.snp.left).offset(-6)
            make.width.equalTo(30)
            make.height.equalTo(15)
            make.centerY.equalTo(holdProfitTextLabel.snp.centerY)
        }
        
        todayProfitTextLabel.snp.makeConstraints { (make) in
            make.left.equalTo(holdProfitTextLabel)
            make.top.equalTo(holdProfitTextLabel.snp.bottom).offset(6)
            make.width.equalTo(56)
            make.height.equalTo(17)
        }
        
        holdProfitLabel.snp.makeConstraints({ (make) in
            make.centerY.equalTo(holdProfitTextLabel)
            make.left.equalTo(holdProfitTextLabel.snp.right).offset(2)
            make.right.equalToSuperview().offset(-12)
        })
        
        todayProfitLabel.snp.makeConstraints({ (make) in
            make.centerY.equalTo(todayProfitTextLabel)
            make.left.equalTo(holdProfitLabel)
            make.right.equalTo(holdProfitLabel)
        })
        
        switch accountType {
        case .option:
            holdProfitTextLabel.isHidden = false
            holdProfitLabel.isHidden = false
            questionButton.isHidden = true
            lookArrowView.isHidden = false
            shareBtn.isHidden = false
        case .intraday:
            holdProfitTextLabel.isHidden = true
            holdProfitLabel.isHidden = true
            questionButton.isHidden = false
            lookArrowView.isHidden = true
            shareBtn.isHidden = true
        case .shortSell:
            holdProfitTextLabel.isHidden = false
            holdProfitLabel.isHidden = false
            questionButton.isHidden = false
            lookArrowView.isHidden = true
            shareBtn.isHidden = true
        case .cash,
             .margin:
            if accountType == .margin {
                lookArrowView.isHidden = false
            } else {
                lookArrowView.isHidden = true
            }
            
            questionButton.isHidden = true
            holdProfitTextLabel.isHidden = false
            holdProfitLabel.isHidden = false
            if exchangeType == .hk || exchangeType == .us {
                shareBtn.isHidden = false
            } else {
                shareBtn.isHidden = true
            }
        }
        
        totalAssetLabel.snp.makeConstraints { (make) in
            make.left.equalTo(totalAssetTitleLabel)
            make.right.equalTo(holdProfitTextLabel.snp.left).offset(-10)
            make.top.equalTo(self.totalAssetTitleLabel.snp.bottom).offset(14)
            make.height.equalTo(49)
        }
        
        //let itemWidth = (self.bounds.size.width - spacing * 4) / 3.0
         
        self.expandButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        accountNameLabel.text = accountType.title
        
        switch accountType {
        case .cash:
            initAsstsViews()
        case .margin:
            initMarginAsstsViews()
        case .intraday:
            initIntradayAsstsViews()
        case .option:
            initOptionAsstsViews()
        case .shortSell:
            initShortSellAsstsViews()
        default:
            break
        }
        
        self.displayOrHideBtn.addTarget(self, action: #selector(displayOrHideAction(sender:)), for: .touchUpInside)
        
        self.expandButton.addTarget(self, action: #selector(expandArrowAction(sender:)), for: .touchUpInside)
        
        self.expandArrow.addTarget(self, action: #selector(expandArrowAction(sender:)), for: .touchUpInside)
        
        refreshUI()
    }
    
    @objc func displayOrHideAction(sender: UIButton) {
        YXHoldInfoView.isSecretDisplay = !YXHoldInfoView.isSecretDisplay
        
        self.refreshUI()
        
        MMKV.default().set(YXHoldInfoView.isSecretDisplay, forKey: "\(kHoldInfoSecretKey)\(YXUserManager.userUUID())")
        if let closure = self.onClickSecret {
            closure()
        }
    }
    
    @objc func expandArrowAction(sender: UIButton) {
        YXHoldInfoView.isExpanded = !YXHoldInfoView.isExpanded
        
        self.refreshUI()
        
        MMKV.default().set(YXHoldInfoView.isExpanded, forKey: "\(kHoldInfoExpandKey)\(YXUserManager.userUUID())")
        if let closure = self.onClickExpand {
            closure(YXHoldInfoView.isExpanded)
        }
        
        self.expandArrow.frame = CGRect(x: 0, y: self.height - 22, width: self.width, height: 16)
    }
    
    func addShadowLayer(view: UIView) {
        view.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
        view.layer.cornerRadius = 10
        view.layer.borderColor = QMUITheme().separatorLineColor().cgColor
        view.layer.borderWidth = 1
        view.layer.shadowColor = QMUITheme().separatorLineColor().cgColor
        view.layer.shadowOpacity = 1.0
    }
    
    //MARK: 刷新
    func refreshUI() {
        
        if exchangeType == .us, accountType == .cash, YXUserManager.isGray(with: .bond) {
            bondMarketValueView.isHidden = false
        } else {
            bondMarketValueView.isHidden = true
        }

        self.expandArrow.frame = CGRect(x: 0, y: self.height - 22, width: self.width, height: 16)

        self.displayOrHideBtn.setImage(UIImage(named: YXHoldInfoView.isSecretDisplay ? "hide" : "display"), for: .normal)

        self.expandArrow.setImage(UIImage(named: YXHoldInfoView.isExpanded ? "up_arrow" : "down_arrow"), for: .normal)
        
        self.totalAssetLabel.text = nil
        self.totalAssetLabel.attributedText = nil
        
        if YXHoldInfoView.isSecretDisplay {
            // 是否加密顯示
            self.totalAssetLabel.text = "***"
            self.todayProfitLabel.text = "***"
            self.holdProfitLabel.text = "***"
            self.stockMarketValueView.setValueLabelText("***")

            self.riskLevelView.setValueLabelText("***")
            self.riskStatusLabel.attributedText = nil
            self.purchasePowerView.setValueLabelText("***")

            self.freezingCashView.setValueLabelText("***")
            self.cashAvailableView.setValueLabelText("***")
            self.onWayValueView.setValueLabelText("***")

            self.bondMarketValueView.setValueLabelText("***")
            self.dibitBalanceView.setValueLabelText("***")
            self.callMarginCallView.setValueLabelText("***")
            
            self.mvPercentView.setValueLabelText("***")
            self.initialMarginValueView.setValueLabelText("***")
            self.maintenanceMarginView.setValueLabelText("***")
            
            self.remainMoneyView.setValueLabelText("***")
            
            var model = assetModel
            switch accountType {
            case .intraday:
                model = intradayAssetModel
            case .option:
                model = optionAssetModel
            case .shortSell:
                model = shortSellAssetModel
            default:
                break
            }
            if let assetModel = model {
                //美股盘前盘后 标记显示（且不是即日孖展 显示）
                if (self.exchangeType == .us && (assetModel.sessionType == 1 || assetModel.sessionType == 2) && (accountType == .margin || accountType == .cash)){
                    let panName : String = (assetModel.sessionType == 1 ) ? "common_pre_opening" : "common_after_opening"
                    openPreLabel.text = YXLanguageUtility.kLang(key: panName)
                    openPreLabel.isHidden = false
                    totalAssetLabel.snp.updateConstraints { (make) in
                        make.right.equalTo(self.holdProfitTextLabel.snp.left).offset(-38)
                    }
                }else{
                    openPreLabel.text = ""
                    openPreLabel.isHidden = true
                    totalAssetLabel.snp.updateConstraints { (make) in
                        make.right.equalTo(self.holdProfitTextLabel.snp.left).offset(-10)
                    }
                }
            }else{
                openPreLabel.text = ""
                openPreLabel.isHidden = true
                totalAssetLabel.snp.updateConstraints { (make) in
                    make.right.equalTo(self.holdProfitTextLabel.snp.left).offset(-10)
                }
            }
        } else {
            //总资产
            var model = assetModel
            switch accountType {
            case .intraday:
                model = intradayAssetModel
            case .option:
                model = optionAssetModel
            case .shortSell:
                model = shortSellAssetModel
            default:
                break
            }
            
            guard let assetModel = model else {
                self.totalAssetLabel.text = "--"
                self.todayProfitLabel.text = "--"
                self.holdProfitLabel.text = "--"
                self.stockMarketValueView.setValueLabelText("--")

                self.riskLevelView.setValueLabelText("--")
                self.riskStatusLabel.attributedText = nil
                self.purchasePowerView.setValueLabelText("--")

                self.freezingCashView.setValueLabelText("--")
                self.cashAvailableView.setValueLabelText("--")
                self.onWayValueView.setValueLabelText("--")

                self.bondMarketValueView.setValueLabelText("--")
                self.dibitBalanceView.setValueLabelText("--")
                self.callMarginCallView.setValueLabelText("--")
                
                self.mvPercentView.setValueLabelText("--")
                self.initialMarginValueView.setValueLabelText("--")
                self.maintenanceMarginView.setValueLabelText("--")
                self.callMarginCallView.setValueLabelText("--")
                
                self.remainMoneyView.setValueLabelText("--")
                
                openPreLabel.text = ""
                openPreLabel.isHidden = true
                totalAssetLabel.snp.updateConstraints { (make) in
                    make.right.equalTo(self.holdProfitTextLabel.snp.left).offset(-10)
                }
            
                return
            }
            
            if accountType == .shortSell {
                if let asset = Double(assetModel.elvBalance ?? "") {
                    let formatString = moneyFormatter.string(from: NSNumber(value: asset))
                    let attributeString = NSMutableAttributedString(string: formatString!, attributes: [.font: UIFont.systemFont(ofSize: 38, weight: .medium), .foregroundColor: QMUITheme().textColorLevel1()]);

                    if  let formatString = formatString,
                        let location = formatString.range(of: ".", options: [])?.lowerBound {
                        // 判断是否存在"."字符
                        // 如果存在，则将"."和"."之后的字符，都设置为小号字体
                        // 例如  100,000.24  ，则distance = 7的位置开始，到length这个范围内的字符都用小号字体
                        let distance = formatString.distance(from: formatString.startIndex, to: location)
                        let length = formatString.distance(from: location, to: formatString.endIndex)
                        attributeString.addAttributes([.font: UIFont.systemFont(ofSize: 20, weight: .medium)], range: NSRange(location: distance, length: length))
                    }
                    self.totalAssetLabel.attributedText = attributeString
                } else {
                    self.totalAssetLabel.text = "--"
                }
                
                if let stockMarketValue = Double(assetModel.totalMarketValue ?? "") {
                    let formatString = moneyFormatter.string(from: NSNumber(value: stockMarketValue))
                    self.stockMarketValueView.setValueLabelText(formatString!)
                }
                
                if let usabeleMoney = Double(assetModel.afBalance ?? "") {
                    let formatString = moneyFormatter.string(from: NSNumber(value: usabeleMoney))
                    self.purchasePowerView.setValueLabelText(formatString!)
                }
                
                if let mvRate = NSNumber(string: assetModel.mvRate ?? "") {
                    let string = String(format: "%.2f%%",  mvRate.doubleValue * 100.0)
                    self.mvPercentView.setValueLabelText(string)
                }

                if let totalIMBalance = Double(assetModel.totalIMBalance ?? "") {
                    let formatString = moneyFormatter.string(from: NSNumber(value: totalIMBalance))
                    self.initialMarginValueView.setValueLabelText(formatString!)
                }
                
                if let totalMMBalance = Double(assetModel.totalMMBalance ?? "") {
                    let formatString = moneyFormatter.string(from: NSNumber(value: totalMMBalance))
                    self.maintenanceMarginView.setValueLabelText(formatString!)
                }
                
                if let totalCMBalance = Double(assetModel.totalCMBalance ?? "") {
                    let formatString = moneyFormatter.string(from: NSNumber(value: totalCMBalance))
                    self.callMarginCallView.setValueLabelText(formatString!)
                }
                
                if let holdProfit = Double(assetModel.totalHoldingProfit ?? "") {
                    var formatString = moneyFormatter.string(from: NSNumber(value: holdProfit))!
                    formatString = (holdProfit > 0 ? "+\(formatString)" : formatString)
                    self.holdProfitLabel.text = formatString
                }
                
                if let todayProfit = Double(assetModel.totalTodayProfit ?? "") {
                    var formatString = moneyFormatter.string(from: NSNumber(value: todayProfit))!
                    formatString = (todayProfit > 0 ? "+\(formatString)" : formatString)
                    todayProfitLabel.text = formatString
                }
                
                return
            }
            
            if let asset = Double(assetModel.asset ?? "") {
                let formatString = moneyFormatter.string(from: NSNumber(value: asset))
                let attributeString = NSMutableAttributedString(string: formatString!, attributes: [.font: UIFont.systemFont(ofSize: 38, weight: .medium), .foregroundColor: QMUITheme().textColorLevel1()]);

                if  let formatString = formatString,
                    let location = formatString.range(of: ".", options: [])?.lowerBound {
                    // 判断是否存在"."字符
                    // 如果存在，则将"."和"."之后的字符，都设置为小号字体
                    // 例如  100,000.24  ，则distance = 7的位置开始，到length这个范围内的字符都用小号字体
                    let distance = formatString.distance(from: formatString.startIndex, to: location)
                    let length = formatString.distance(from: location, to: formatString.endIndex)
                    attributeString.addAttributes([.font: UIFont.systemFont(ofSize: 20, weight: .medium)], range: NSRange(location: distance, length: length))
                }
                self.totalAssetLabel.attributedText = attributeString
            } else {
                self.totalAssetLabel.text = "--"
            }
            // 日盈亏
            if accountType == .intraday || accountType == .option {
                if let dailyProfitLoss = Double(assetModel.dailyBalance ?? "") {
                      var formatString = moneyFormatter.string(from: NSNumber(value: dailyProfitLoss))
                      formatString = (dailyProfitLoss > 0 ? "+\(formatString!)" : "\(formatString!)")
                      self.todayProfitLabel.text = formatString
                  } else {
                      self.todayProfitLabel.text = "--"
                  }
            } else {
                if let dailyProfitLoss = Double(assetModel.totalDailyBalance ?? "") {
                    var formatString = moneyFormatter.string(from: NSNumber(value: dailyProfitLoss))
                    formatString = (dailyProfitLoss > 0 ? "+\(formatString!)" : "\(formatString!)")
                    self.todayProfitLabel.text = formatString
                } else {
                    self.todayProfitLabel.text = "--"
                }
            }
            // 股票市值
            if accountType == .option {
                if let stockMarketValue = Double(assetModel.totalMarketValue ?? "") {
                    let formatString = moneyFormatter.string(from: NSNumber(value: stockMarketValue))
                    self.stockMarketValueView.setValueLabelText(formatString!)
                } else {
                    self.stockMarketValueView.setValueLabelText("--")
                }
            } else if accountType == .intraday {
                if let stockMarketValue = Double(assetModel.marketValue ?? "") {
                    let formatString = moneyFormatter.string(from: NSNumber(value: stockMarketValue))
                    self.stockMarketValueView.setValueLabelText(formatString!)
                } else {
                    self.stockMarketValueView.setValueLabelText("--")
                }
                
                if let remainingMoney = NSNumber(string: assetModel.userQuote ?? "") {
                    let formatString = moneyFormatter.string(from: remainingMoney)
                    self.remainMoneyView.setValueLabelText(formatString!)
                } else {
                    self.remainMoneyView.setValueLabelText("--")
                }
            } else {
                if let stockMarketValue = Double(assetModel.stockMarketValue ?? "") {
                    let formatString = moneyFormatter.string(from: NSNumber(value: stockMarketValue))
                    self.stockMarketValueView.setValueLabelText(formatString!)
                } else {
                    self.stockMarketValueView.setValueLabelText("--")
                }
            }

            if let mv = assetModel.mv, let mvValue = Double(mv) {
                let value = String(format: "%.2f", mvValue * 100) + "%"
                self.riskLevelView.setValueLabelText(value)

                if let riskStatusCode = assetModel.riskStatusCode, let riskStatusName = assetModel.riskStatusName {
                    var color = UIColor.qmui_color(withHexString: "#41CA1E")
                    if riskStatusCode == 2 {
                        color = UIColor.qmui_color(withHexString: "#FFBA00")
                    } else if riskStatusCode == 3 {
                        color = UIColor.qmui_color(withHexString: "#FF7127")
                    } else if riskStatusCode == 4 {
                        color = UIColor.qmui_color(withHexString: "#FF295A")
                    }
                    let riskStatusText = NSAttributedString(string: " " + riskStatusName + " ", attributes: [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.white, .backgroundColor: color ?? UIColor.clear])
                    riskStatusLabel.attributedText = riskStatusText

                    let width = (value as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium)]).width
                    riskStatusLabel.snp.remakeConstraints { (make) in
                        make.centerY.equalTo(self.riskLevelView.valueLabel).offset(2)
                        make.left.equalTo(width + 5)
                        make.right.lessThanOrEqualToSuperview()
                    }
                }
            } else {
                self.riskLevelView.setValueLabelText("--")
            }

            // 购买力
            if accountType == .margin || accountType == .option {
                self.purchasePowerView.setTitleLabelText(YXLanguageUtility.kLang(key: "newStock_certified_funds"))
                if let enableBalance = Double(assetModel.enableBalance ?? "") {
                    let formatString = moneyFormatter.string(from: NSNumber(value: enableBalance))
                    self.purchasePowerView.setValueLabelText(formatString!)
                } else {
                    self.purchasePowerView.setValueLabelText("--")
                }

                if YXUserManager.shared().curLoginUser?.openUpPurchasePower == true, accountType == .margin {
                    self.purchasePowerView.setTitleLabelText(YXLanguageUtility.kLang(key: "hold_buying_power"))
                    if let purchasePower = Double(assetModel.purchasePower ?? "") {
                        let formatString = moneyFormatter.string(from: NSNumber(value: purchasePower))
                        self.purchasePowerView.setValueLabelText(formatString!)
                    } else {
                        self.purchasePowerView.setValueLabelText("--")
                    }
                    
                    purchasePowerView.isUserInteractionEnabled = true
                    purchasePowerView.addSubview(purchaseInfoButton)

                    purchasePowerView.titleLabel.snp.remakeConstraints { (make) in
                        make.left.top.equalToSuperview()
                        make.height.equalTo(26)
                        if YXUserManager.isENMode() {
                            make.right.lessThanOrEqualToSuperview().offset(-10)
                        } else {
                            make.right.lessThanOrEqualToSuperview().offset(-25)
                        }
                    }
                    purchaseInfoButton.snp.remakeConstraints { (make) in
                        make.centerY.equalTo(purchasePowerView.titleLabel)
                        make.left.equalTo(purchasePowerView.titleLabel.snp.right).offset(2)
                    }
                }

            } else {
                self.purchasePowerView.setTitleLabelText(YXLanguageUtility.kLang(key: "hold_purchase_power"))
                if let purchasePower = Double(assetModel.enableBalance ?? "") {
                    let formatString = moneyFormatter.string(from: NSNumber(value: purchasePower))
                    self.purchasePowerView.setValueLabelText(formatString!)
                } else {
                    self.purchasePowerView.setValueLabelText("--")
                }
            }

            // 持仓盈亏
            if accountType == .option {
                if let positionProfitLoss = Double(assetModel.holdingBalance ?? "") {
                    var formatString = moneyFormatter.string(from: NSNumber(value: positionProfitLoss))
                    formatString = (positionProfitLoss > 0 ? "+\(formatString!)" : "\(formatString!)")
                    self.holdProfitLabel.text = formatString
                } else {
                    self.holdProfitLabel.text = "--"
                }
            } else {
                if let positionProfitLoss = Double(assetModel.totalHoldingBalance ?? "") {
                    var formatString = moneyFormatter.string(from: NSNumber(value: positionProfitLoss))
                    formatString = (positionProfitLoss > 0 ? "+\(formatString!)" : "\(formatString!)")
                    self.holdProfitLabel.text = formatString
                } else {
                    self.holdProfitLabel.text = "--"
                }
            }
            //美股盘前盘后标记显示
            if self.exchangeType == .us && (assetModel.sessionType == 1 || assetModel.sessionType == 2) && (accountType == .margin || accountType == .cash) {
                let panName : String = (assetModel.sessionType == 1 ) ? "common_pre_opening" : "common_after_opening"
                openPreLabel.text = YXLanguageUtility.kLang(key: panName)
                openPreLabel.isHidden = false
                totalAssetLabel.snp.updateConstraints { (make) in
                    make.right.equalTo(self.holdProfitTextLabel.snp.left).offset(-38)
                }
            }else{
                openPreLabel.text = ""
                openPreLabel.isHidden = true
                totalAssetLabel.snp.updateConstraints { (make) in
                    make.right.equalTo(self.holdProfitTextLabel.snp.left).offset(-10)
                }
            }
            // 冻结现金
            if let freezingCash = Double(assetModel.frozenBalance ?? "") {
                let formatString = moneyFormatter.string(from: NSNumber(value: freezingCash))
                self.freezingCashView.setValueLabelText(formatString!)
            } else {
                self.freezingCashView.setValueLabelText("--")
            }
            // 可取现金
            if let cashAvailable = Double(assetModel.withdrawBalance ?? "") {
                let formatString = moneyFormatter.string(from: NSNumber(value: cashAvailable))
                self.cashAvailableView.setValueLabelText(formatString!)
            } else {
                self.cashAvailableView.setValueLabelText("--")
            }

            if let onWayValue = Double(assetModel.onWayBalance ?? "") {
                let formatString = moneyFormatter.string(from: NSNumber(value: onWayValue))
                self.onWayValueView.setValueLabelText(formatString!)
            } else {
                self.onWayValueView.setValueLabelText("--")
            }

            if let bondMarketValue = Double(assetModel.bondMarketValue ?? "") {
                let formatString = moneyFormatter.string(from: NSNumber(value: bondMarketValue))
                self.bondMarketValueView.setValueLabelText(formatString!)
            } else {
                self.bondMarketValueView.setValueLabelText("--")
            }
            
            if let debit = NSNumber(string: assetModel.debitBalance ?? "") {
                let formatString = moneyFormatter.string(from: debit)
                self.dibitBalanceView.setValueLabelText(formatString!)
            } else {
                self.dibitBalanceView.setValueLabelText("--")
            }
            
            if let callMarginCall = NSNumber(string: assetModel.callMarginCall ?? "") {
                let formatString = moneyFormatter.string(from: callMarginCall)
                self.callMarginCallView.setValueLabelText(formatString!)
            } else {
                self.callMarginCallView.setValueLabelText("--")
            }
        }
    }
}

extension Reactive where Base: YXHoldInfoView {
    
    internal var assetModel: Binder<YXAssetModel?> {
        Binder(self.base) { holdInfo, model in
            holdInfo.assetModel = model
        }
    }
    
    internal var intradayAssetModel: Binder<YXAssetModel?> {
        Binder(self.base) { holdInfo, model in
            holdInfo.intradayAssetModel = model
        }
    }
    
    
    internal var optionAssetModel: Binder<YXAssetModel?> {
        Binder(self.base) { holdInfo, model in
            holdInfo.optionAssetModel = model
        }
    }
    
    internal var shortSellAssetModel: Binder<YXAssetModel?> {
        Binder(self.base) { holdInfo, model in
            holdInfo.shortSellAssetModel = model
        }
    }
    
}
