//
//  YXTradeItemsView.swift
//  uSmartOversea
//
//  Created by Apple on 2020/4/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeItemsView: UIView {
    // 市场类型
    private var exchangeType: YXExchangeType = .hk
    
    typealias ClosureClick = () -> Void

    //交易
    @objc var onClickTrade: ClosureClick?
    //智能下单
    @objc var onClickSmartTrade: ClosureClick?
    //暗盘
    @objc var onClickGrey: ClosureClick?
    //全部订单
    @objc var onClickAllOrder: ClosureClick?
    //新股认购
    @objc var onClickIPO: ClosureClick?
    //债券
    @objc var onClickBond: ClosureClick?
    //入金
    @objc var onClickDeposit: ClosureClick?
    //更多
    @objc var onClickMore: ClosureClick?
    //货币兑换
    @objc var onClickExchange: ClosureClick?
    //历史记录
    @objc var onClickHistory: ClosureClick?
//    //条件单
//    @objc var onClickCondition: ClosureClick?
    //转入股票
    @objc var onClickShiftIn: ClosureClick?
    //资金流水
    @objc var onClickFund: ClosureClick?
    //IPO配售预约
    @objc var onClickIpoSub: ClosureClick?
    //PRO账户
    @objc var onClickPro: ClosureClick?
    
    @objc var onClickActivity: ClosureClick?
    
    @objc var onClickTradeFund: ClosureClick?
    
    var deletBtn: YXTradeItemSubView?
    
    var firstBtns: [YXTradeItemSubView] = []
    var secondBtns: [YXTradeItemSubView] = []
    // 买入
    lazy var tradeBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_trade", text: YXLanguageUtility.kLang(key: "hold_trade_title"))
        addTapGestureWith(view: view, sel: #selector(tradeAction))
        return view
    }()
    
    // 交易订单
    lazy var orderBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_order", text: YXLanguageUtility.kLang(key: "hold_orders"))
        addTapGestureWith(view: view, sel: #selector(orderAction))
        return view
    }()
    
    // 新股认购
    lazy var ipoBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_ipo", text: YXLanguageUtility.kLang(key: "hold_new_stock"))
        addTapGestureWith(view: view, sel: #selector(newStockAction))
        return view
    }()
    
    lazy var bondBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_bond", text: YXLanguageUtility.kLang(key: "hold_bond_buy"))
        addTapGestureWith(view: view, sel: #selector(bondAction))
        return view
    }()
    
    //智能下单
    lazy var smartTradeBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_smart", text: YXLanguageUtility.kLang(key: "hold_smart"))
        addTapGestureWith(view: view, sel: #selector(smartTradeAction))
        return view
    }()
    
    //入金
    lazy var depositBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_deposit_funds", text: YXLanguageUtility.kLang(key: "hold_deposit_funds"))
        addTapGestureWith(view: view, sel: #selector(depositAction))
        return view
    }()
    
    //货币兑换
    lazy var exchangeBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_exchange_currency", text: YXLanguageUtility.kLang(key: "hold_exchange_currency"))
        addTapGestureWith(view: view, sel: #selector(exchangeAction))
        return view
    }()

    //更多
    lazy var moreBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_more", text: YXLanguageUtility.kLang(key: "share_info_more"))
        addTapGestureWith(view: view, sel: #selector(moreAction))
        return view
    }()
    
    //历史记录
    lazy var historyBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_history", text: YXLanguageUtility.kLang(key: "hold_history"))
        addTapGestureWith(view: view, sel: #selector(historyAction))
        return view
    }()
    
    //暗盘
    lazy var greyBtn: YXTradeItemSubView = {        
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_grey", text: YXLanguageUtility.kLang(key: "grey_mkt"))
        addTapGestureWith(view: view, sel: #selector(greyAction))
        return view
    }()
    
    //pro账户
    lazy var proBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_gopro", text: YXLanguageUtility.kLang(key: "account_pro"))
        addTapGestureWith(view: view, sel: #selector(proAction))
        return view
    }()
    
    //ipo配售预约
    lazy var ipoSubBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_ipo", text: YXLanguageUtility.kLang(key: "hold_ipo_sub"))
        addTapGestureWith(view: view, sel: #selector(ipoSubAction))
        return view
    }()

    //资金流水
    lazy var fundBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_capital_flow", text: YXLanguageUtility.kLang(key: "hold_capital_flow"))
        addTapGestureWith(view: view, sel: #selector(fundAction))
        return view
    }()
    
    // 转入股票
    lazy var shiftInBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_shiftin", text: YXLanguageUtility.kLang(key: "hold_shiftin"))
        addTapGestureWith(view: view, sel: #selector(shiftInAction))
        return view
    }()
    
//    // 转入股票
//    lazy var activityCenterBtn: YXTradeItemSubView = {
//        let view = YXTradeItemSubView(frame: CGRect.zero)
//        view.updateWith("hold_activity", text: YXLanguageUtility.kLang(key: "user_activity"))
//        addTapGestureWith(view: view, sel: #selector(activityCenterAction))
//        return view
//    }()
    
    // 智選基金
    lazy var tradeFundBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_fund", text: YXLanguageUtility.kLang(key: "hold_trade_fund"))
        addTapGestureWith(view: view, sel: #selector(tradeFundAction))
        return view
    }()
    
    fileprivate lazy var ecmRedDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.isHidden = true
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    fileprivate lazy var actRedDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.isHidden = true
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    @objc var hideEcmRedDot: Bool = false {
        didSet {
            self.ecmRedDotView.isHidden = hideEcmRedDot
        }
    }
    
    @objc var hideActRedDot: Bool = false {
        didSet {
//            self.actRedDotView.isHidden = hideActRedDot
        }
    }

    //新股认购的标签
    lazy var newStockTagView: QMUIPopupContainerView = {
        let view = QMUIPopupContainerView()
        view.backgroundColor = UIColor.qmui_color(withHexString: "#F86D6D")
        view.shadowColor = UIColor.white
        view.borderColor = UIColor.qmui_color(withHexString: "#F86D6D")
        view.contentEdgeInsets = UIEdgeInsets(top: 1, left: 4, bottom: 1, right: 4)
        view.cornerRadius = 4
        view.safetyMarginsOfSuperview = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        view.textLabel?.font = .systemFont(ofSize: 10)
        view.textLabel?.textColor = UIColor.white
        view.arrowSize = CGSize(width: 4, height: 4)
        view.sourceView = self.ipoTagSourceView
        view.isUserInteractionEnabled = false
        view.isHidden = true
        self.addSubview(view)
        return view
    }()
    
    //新股认购的标签
    lazy var ipoTagSourceView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var defaultHeight: CGFloat = {
        if YXUserManager.isENMode() {
            return 70
        }
        return 50
    }()
    
    lazy var itemHeight: CGFloat = {
        if YXUserManager.isENMode() {
            return 70
        }
        return defaultHeight
    }()
    
    required init(frame: CGRect, exchangeType: YXExchangeType) {
        super.init(frame: frame)
        // 当前市场类型
        self.exchangeType = exchangeType
        
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        isUserInteractionEnabled = true
        
        addSubview(tradeBtn)
        addSubview(smartTradeBtn)
        addSubview(orderBtn)
        addSubview(depositBtn)
        
        addSubview(shiftInBtn)
        addSubview(proBtn)
        addSubview(moreBtn)
        
        if exchangeType == .hk || exchangeType == .us {
            if exchangeType == .us, YXUserManager.isGray(with: .bond) {
                addSubview(bondBtn)
                firstBtns = [tradeBtn, smartTradeBtn, orderBtn, bondBtn, depositBtn]
            } else {
                addSubview(ipoBtn)
                addSubview(ipoTagSourceView)
                ipoTagSourceView.snp.makeConstraints { (make) in
                    make.width.height.equalTo(1)
                    make.centerX.equalTo(self.ipoBtn)
                    make.top.equalTo(self.ipoBtn.snp.top).offset(12)
                }
                
                firstBtns = [tradeBtn, smartTradeBtn, orderBtn, ipoBtn, depositBtn]
            }
        } else {
            addSubview(exchangeBtn)
            firstBtns = [tradeBtn, smartTradeBtn, orderBtn, depositBtn, exchangeBtn]
        }
        
        firstBtns.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        firstBtns.snp.makeConstraints { (make) in
            make.top.equalTo(20);
            make.height.equalTo(defaultHeight)
        }
        
        
        if exchangeType == .hk, YXUserManager.isHighWorth() {
            addSubview(ipoSubBtn)

            addSubview(self.ecmRedDotView)
            let ipoImgView = ipoSubBtn.imageView
            ecmRedDotView.snp.makeConstraints { (make) in
                make.left.equalTo(ipoImgView.snp.right)
                make.centerY.equalTo(ipoImgView.snp.top)
                make.width.height.equalTo(8)
            }
            addSubview(exchangeBtn)
            secondBtns = [exchangeBtn, shiftInBtn, ipoSubBtn, proBtn,moreBtn]
        } else {
            if exchangeType == .hk || exchangeType == .us {
                addSubview(tradeFundBtn)
                addSubview(exchangeBtn)
                secondBtns = [exchangeBtn, shiftInBtn, proBtn, tradeFundBtn, moreBtn]
            } else {
                addSubview(historyBtn)
                addSubview(fundBtn)
                secondBtns = [shiftInBtn, proBtn, historyBtn, fundBtn, moreBtn]
            }
        }
        
        self.secondBtns.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        self.secondBtns.snp.makeConstraints { (make) in
            make.top.equalTo(40 + defaultHeight)
            make.height.equalTo(itemHeight)
        }
    }
    
    @objc func addGreyBtn() {
        let isContain = self.secondBtns.contains(greyBtn)
        if !isContain && (self.secondBtns.count > 3) {
            self.secondBtns.snp.removeConstraints()
            addSubview(greyBtn)
            var index = self.secondBtns.count - 2
            if exchangeType == .hk, YXUserManager.isHighWorth() {
                index = self.secondBtns.count - 3
            }
            let btn = self.secondBtns[index]
            self.deletBtn = btn
            btn.removeFromSuperview()
            
            self.secondBtns.remove(at: index)
            self.secondBtns.insert(greyBtn, at: 0)
            
//            if self.actRedDotView.superview != nil {
//                self.actRedDotView.removeFromSuperview()
//            }
            
            self.secondBtns.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
            self.secondBtns.snp.makeConstraints { (make) in
                make.top.equalTo(40 + defaultHeight)
                make.height.equalTo(itemHeight)
            }
        }
    }
    
    @objc func removeGreyBtn() {
        let isContain = self.secondBtns.contains(greyBtn)
        if isContain && (self.secondBtns.count > 2) {
            if let btn = self.deletBtn {
                self.secondBtns.snp.removeConstraints()
                addSubview(btn)
                greyBtn.removeFromSuperview()
                
                self.secondBtns.remove(at: 0)
                
                var index = self.secondBtns.count - 1
                if self.exchangeType == .hk, YXUserManager.isHighWorth() {
                   index = self.secondBtns.count - 2
                }
                
                self.secondBtns.insert(btn, at: index)

//                if self.actRedDotView.superview == nil {
//                    addSubview(self.actRedDotView)
//                    let actImgView = btn.imageView
//                    self.actRedDotView.snp.remakeConstraints { (make) in
//                        make.left.equalTo(actImgView.snp.right)
//                        make.centerY.equalTo(actImgView.snp.top)
//                        make.width.height.equalTo(8)
//                    }
//                }
                
                self.secondBtns.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
                self.secondBtns.snp.makeConstraints { (make) in
                    make.top.equalTo(self).offset(87);
                }
            }
        }
    }
    
    func addTapGestureWith(view: UIView, sel: Selector) {
        let tap = UITapGestureRecognizer.init(target: self, action: sel)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    
    @objc func fundAction() {
        if let closure = onClickFund {
            closure()
        }
    }
    
    @objc func proAction() {
        if let closure = onClickPro {
            closure()
        }
    }
    
    @objc func historyAction() {
        if let closure = onClickHistory {
            closure()
        }
    }
    
    @objc func moreAction() {
        if let closure = onClickMore {
            closure()
        }
    }
    
    @objc func exchangeAction() {
        if let closure = onClickExchange {
            closure()
        }
    }
    
    @objc func ipoSubAction() {
        if let closure = onClickIpoSub {
            closure()
        }
    }
    
    @objc func depositAction() {
        if let closure = onClickDeposit {
            closure()
        }
    }
    
    @objc func orderAction() {
        if let closure = onClickAllOrder {
            closure()
        }
    }
    
    @objc func smartTradeAction() {
        if let closure = onClickSmartTrade {
            closure()
        }
    }
    
    @objc func greyAction() {
        if let closure = onClickGrey {
            closure()
        }
    }
    
    @objc func tradeAction() {
        if let closure = onClickTrade {
            closure()
        }
    }

    @objc func newStockAction() {
        if let closure = onClickIPO {
            closure()
        }
    }

    @objc func shiftInAction() {
        if let closure = onClickShiftIn {
             closure()
         }
    }
    
    @objc func activityCenterAction() {
        if let closure = onClickActivity {
             closure()
         }
    }
    
    @objc func tradeFundAction() {
        if let closure = onClickTradeFund {
            closure()
        }
    }
    
    @objc func bondAction() {
        if let closure = onClickBond {
            closure()
        }
    }
}


class YXTradeItemSubView: UIView {
    
    var imageView: UIImageView = UIImageView()
    
    lazy var titleLab: QMUILabel = {
        let lab = QMUILabel()
        lab.numberOfLines = 0
        lab.textColor = QMUITheme().textColorLevel1()
        lab.font = UIFont.systemFont(ofSize: 13)
        lab.textAlignment = .center
        lab.isUserInteractionEnabled = true
        lab.adjustsFontSizeToFitWidth = true
        lab.minimumScaleFactor = 0.3
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func buildUI() {
        
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.top.equalToSuperview()
        }
        
        addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(2)
            make.trailing.equalToSuperview().offset(-2)
            make.top.equalTo(imageView.snp.bottom).offset(6)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
    }
    
    
    public func updateWith(_ imgName: String, text: String) {
        imageView.image = UIImage(named: imgName)
        titleLab.text = text

    }
    
}

