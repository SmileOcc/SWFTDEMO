//
//  YXStockDetailParameterView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/8/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit
import TYAlertController


class YXStockDetailParameterSubTitleView: UIView {

    var tipActionBlock: (() -> Void)?
    var alignment: NSTextAlignment = .left
    var axis: NSLayoutConstraint.Axis = .horizontal

    convenience init(alignment: NSTextAlignment, axis: NSLayoutConstraint.Axis = .horizontal) {
        self.init(frame: CGRect.zero, alignment: alignment, axis: axis)
    }

    init(frame: CGRect, alignment: NSTextAlignment, axis: NSLayoutConstraint.Axis) {
        super.init(frame: frame)
        self.alignment = alignment
        self.axis = axis
        initUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func initUI() {
        addSubview(titleLabel)
        addSubview(valueLabel)

        if self.axis == .vertical {
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(8)
                make.left.right.equalToSuperview()
                make.height.equalTo(18)
            }

            valueLabel.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom)
                make.height.equalTo(20)
                make.left.right.equalToSuperview()
            }

            titleLabel.textAlignment = alignment
            valueLabel.textAlignment = alignment
        } else {
            titleLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview()
                make.height.equalTo(17)
            }

            valueLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(titleLabel)
                make.height.equalTo(17)
                make.right.equalToSuperview()
                make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(5)
            }
            titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

            titleLabel.textAlignment = .left
            valueLabel.textAlignment = .right
        }

    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()

    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()

    lazy var tipButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "stock_about"), for: .normal)
        button.setImage(UIImage(named: "stock_about"), for: .highlighted)
        button.addTarget(self, action: #selector(tipButtonAction), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    @objc func tipButtonAction() {
        tipActionBlock?()
    }

    var showTip: Bool = false {
        didSet {
            if showTip, tipButton.superview == nil {
                addSubview(tipButton)
                tipButton.alpha = 0.7
                if self.axis == .vertical {
                    
                    if alignment == .left {
                        titleLabel.snp.remakeConstraints { (make) in
                            make.top.equalToSuperview().offset(6)
                            make.left.equalToSuperview()
                            make.height.equalTo(18)
                            make.right.lessThanOrEqualToSuperview().offset(-14)
                        }

                        tipButton.snp.makeConstraints { (make) in
                            make.centerY.equalTo(titleLabel)
                            make.left.equalTo(titleLabel.snp.right).offset(2)
                            make.width.height.equalTo(12)
                        }
                    } else {
                        
                        tipButton.snp.makeConstraints { (make) in
                            make.centerY.equalTo(titleLabel)
                            make.right.equalToSuperview()
                            make.width.height.equalTo(12)
                        }
                        
                        titleLabel.snp.remakeConstraints { (make) in
                            make.top.equalToSuperview().offset(6)
                            make.right.equalTo(tipButton.snp.left).offset(-2)
                            make.height.equalTo(18)
                            make.left.greaterThanOrEqualToSuperview()
                        }

                    }
                    
                } else {
                    tipButton.snp.makeConstraints { (make) in
                        make.centerY.equalTo(titleLabel)
                        make.left.equalTo(titleLabel.snp.right).offset(2)
                        make.width.height.equalTo(12)
                    }

                    valueLabel.snp.remakeConstraints { (make) in
                        make.centerY.equalTo(titleLabel)
                        make.height.equalTo(17)
                        make.right.equalToSuperview()
                        make.left.greaterThanOrEqualTo(tipButton.snp.right).offset(3)
                    }
                }

            }
            tipButton.isHidden = !showTip
        }
    }
}

class YXStockDetailParameterView: UIView {

    var quoteModel: YXV2Quote? {
        didSet {
            refreshUI()
        }
    }

    var parameterHeightBlock: ((_ height: CGFloat, _ animated: Bool) -> Void)?

    var kSubParameterHeight: CGFloat = 54
        
    let perLineCount = 3
    fileprivate var parameterViews: [YXStockDetailParameterSubTitleView] = [YXStockDetailParameterSubTitleView]()
    fileprivate var titles: [YXStockDetailBasicType] = [YXStockDetailBasicType]()

    //MARK: 刷新视图数据
    func refreshUI() {

        refreshParametersView()
    }
    
    var contentHeight: CGFloat {
        let row = (self.titles.count + 1) / perLineCount
        
        return CGFloat(row) * kSubParameterHeight
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    //MARK: 布局子视图
    func initUI() {

        self.backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(parameterView)
        parameterView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    //MARK: 懒加载视图
    
    lazy var parameterView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.rx.tapGesture().subscribe(onNext: {
            [weak self] ges in
            guard let `self` = self else { return }
            if ges.state == .ended {

            }
        }).disposed(by: rx.disposeBag)
        return view
    }()

    lazy var warrantAlertView: UIView = {
        let view = UIView()
        let width = YXConstant.screenWidth - 2 * uniHorLength(28) - 2 * 20.0

        let upperLabel = UILabel()
        upperLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        upperLabel.textColor = QMUITheme().textColorLevel1()
        upperLabel.text = YXLanguageUtility.kLang(key: "warrants_to_upper_strike")

        let upperDesLabel = UILabel()
        upperDesLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        upperDesLabel.textColor = QMUITheme().textColorLevel3()
        upperDesLabel.numberOfLines = 0
        upperDesLabel.text = YXLanguageUtility.kLang(key: "warrants_upper_strike_desc")

        let lowerLabel = UILabel()
        lowerLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lowerLabel.textColor = QMUITheme().textColorLevel1()
        lowerLabel.text = YXLanguageUtility.kLang(key: "warrants_to_lower_strike")

        let lowerDesLabel = UILabel()
        lowerDesLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lowerDesLabel.textColor = QMUITheme().textColorLevel3()
        lowerDesLabel.numberOfLines = 0
        lowerDesLabel.text = YXLanguageUtility.kLang(key: "warrants_lower_strike_desc")

        view.addSubview(upperLabel)
        view.addSubview(upperDesLabel)
        view.addSubview(lowerLabel)
        view.addSubview(lowerDesLabel)
        upperLabel.snp.makeConstraints({ (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(4)
        })

        upperDesLabel.snp.makeConstraints({ (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(upperLabel.snp.bottom).offset(7)
        })

        lowerLabel.snp.makeConstraints({ (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(upperDesLabel.snp.bottom).offset(20)
        })

        lowerDesLabel.snp.makeConstraints({ (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(lowerLabel.snp.bottom).offset(7)
        })

        var height: CGFloat = 80

        height += YXToolUtility.getStringSize(with: upperDesLabel.text!, andFont: upperDesLabel.font!, andlimitWidth: Float(width), andLineSpace: 2).height

        height += YXToolUtility.getStringSize(with: lowerDesLabel.text!, andFont: lowerDesLabel.font!, andlimitWidth: Float(width), andLineSpace: 2).height

        view.frame = CGRect(x: 0, y: 0, width: width, height: height)

        return view
    }()
    
}




//MARK: 盘口相关逻辑
extension YXStockDetailParameterView {

    //MARK: 初始化盘口字段
    func setTitles(_ titles: [YXStockDetailBasicType]) {
        
        let isNeedRefresh = titles.count != self.titles.count
        self.titles = titles
        
        if isNeedRefresh{
            parameterHeightBlock?(self.contentHeight ,true)
        }
        
        for view in parameterViews {
            view.removeFromSuperview()
        }
        parameterViews.removeAll()

        let leftMargin: CGFloat = 16
        let columnSpace: CGFloat = 15
        let viewWidth: CGFloat = (YXConstant.screenWidth - 2 * leftMargin - columnSpace * CGFloat(perLineCount - 1)) / CGFloat(perLineCount)
        for x in 0..<self.titles.count {
            let type = self.titles[x]
            let alignment: NSTextAlignment = ((x + 1) % perLineCount == 0) ? .right : .left
            let paramView = YXStockDetailParameterSubTitleView(alignment: alignment, axis: .vertical)
            parameterViews.append(paramView)
            self.parameterView.addSubview(paramView)
            //5行2列(一行一行的约束)
            let paramX = CGFloat(x % perLineCount) * (viewWidth + columnSpace) + leftMargin
            let paramY = CGFloat(x / perLineCount) * (kSubParameterHeight)
            
            paramView.frame = CGRect.init(x: paramX, y: paramY, width: viewWidth, height: kSubParameterHeight)
            
            if YXUserManager.isENMode() {
                paramView.titleLabel.text = type.title.uppercased()
            } else {
                paramView.titleLabel.text = type.title
            }
            paramView.valueLabel.text = "--"

            if type == .toUpperStrike || type == .toLowerStrike {

                paramView.showTip = true
                paramView.tipActionBlock = {
                    [weak self] in
                    guard let `self` = self else { return }
                    self.showStInlineWarrantAlert()
                }
            } else if quoteModel?.market == YXMarketType.US.rawValue, type == .amount {
                paramView.showTip = true
                paramView.tipActionBlock = {
                    [weak self] in
                    guard let `self` = self else { return }
                    self.showUSAmountAlert()
                }
            }

        }

        if quoteModel != nil {
            refreshUI()
        }
    }

    //MARK: 盘口字段赋值
    func refreshParametersView() -> Void {

        guard let quoteModel = quoteModel else {
            return
        }
        if self.titles.count > 0 {
            setParamentersValue(quoteModel, typeTitles: titles, viewsArray: parameterViews)
        }
    }

    
    func updateCittenValue(_ posBroker: PosBroker?) {
        for x in 0..<titles.count {
            if titles[x] == .cittthan {
                if let cittthan = posBroker?.pos?.cittThan?.value {
                    parameterViews[x].valueLabel.text = String(format: "%.02f%%", Double(cittthan) * 1.0 / 100)
                } else {
                    parameterViews[x].valueLabel.text = "--"
                }
            }
        }
    }

    func setParamentersValue(_ quoteModel: YXV2Quote, typeTitles: [YXStockDetailBasicType], viewsArray: [YXStockDetailParameterSubTitleView]) {

        var priceBasic = 1
        if let priceBase = quoteModel.priceBase?.value, priceBase > 0  {
            priceBasic = Int(priceBase)
        }
        for x in 0..<typeTitles.count {
            let type = typeTitles[x]
            if type == .cittthan {
                continue
            }
            viewsArray[x].valueLabel.text = "--"
            switch type {
                case .now, .open: //今开
                    if let open = quoteModel.open?.value {
                        if open > 0 {
                            let openString = YXToolUtility.stockPriceData(Double(open), deciPoint: priceBasic, priceBase: priceBasic)
                            viewsArray[x].valueLabel.text = openString

                            if let pclose = quoteModel.preClose?.value {
                                viewsArray[x].valueLabel.textColor = YXToolUtility.changeColor(Double(open - pclose))
                            }
                        } else {
                            viewsArray[x].valueLabel.text = "--"
                        }
                    }
                case .pclose: //昨收
                    if let pclose = quoteModel.preClose?.value {
                        if pclose > 0 {
                            let pcloseString = YXToolUtility.stockPriceData(Double(pclose), deciPoint: priceBasic, priceBase: priceBasic)
                            viewsArray[x].valueLabel.text = pcloseString
                        } else {
                            viewsArray[x].valueLabel.text = "--"
                        }
                    }
                case .high: //今日最高
                    if let high = quoteModel.high?.value {
                        if high > 0 {
                            let highString = YXToolUtility.stockPriceData(Double(high), deciPoint: priceBasic, priceBase: priceBasic)
                            viewsArray[x].valueLabel.text = highString
                            if let pclose = quoteModel.preClose?.value {
                                viewsArray[x].valueLabel.textColor = YXToolUtility.changeColor(Double(high - pclose))
                            }
                        } else {
                            viewsArray[x].valueLabel.text = "--"
                        }
                    }
                case .low: //今日最低
                    if let low = quoteModel.low?.value {
                        if low > 0 {
                            let lowString = YXToolUtility.stockPriceData(Double(low), deciPoint: priceBasic, priceBase: priceBasic)
                            viewsArray[x].valueLabel.text = lowString
                            if let pclose = quoteModel.preClose?.value {
                                viewsArray[x].valueLabel.textColor = YXToolUtility.changeColor(Double(low - pclose))
                            }
                        } else {
                            viewsArray[x].valueLabel.text = "--"
                        }
                    }

                case .highLow:

                    if let low = quoteModel.low?.value, let high = quoteModel.high?.value {
                        if low > 0, high > 0 {
                            let lowString = YXToolUtility.stockPriceData(Double(low), deciPoint: priceBasic, priceBase: priceBasic) ?? ""
                            let highString = YXToolUtility.stockPriceData(Double(high), deciPoint: priceBasic, priceBase: priceBasic) ?? ""
                            viewsArray[x].valueLabel.text = lowString + "-" + highString

                        } else {
                            viewsArray[x].valueLabel.text = "--"
                        }
                    }
                case .pe: //市盈率（静态）
                    if let pe = quoteModel.pe?.value {
                        if pe < 0 {
                            viewsArray[x].valueLabel.text = YXLanguageUtility.kLang(key: "stock_detail_loss")
                        } else if pe == 0 {
                            viewsArray[x].valueLabel.text = "--"
                        } else {
                            viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(pe), deciPoint: 2, priceBase: 4)
                        }
                    }
                case .peTTM: //市盈率（TTM)
                    if let peTtm = quoteModel.peTTM?.value {
                        if peTtm < 0 {
                            viewsArray[x].valueLabel.text = YXLanguageUtility.kLang(key: "stock_detail_loss")
                        } else if peTtm == 0 {
                            viewsArray[x].valueLabel.text = "--"
                        } else {
                            viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(peTtm), deciPoint: 2, priceBase: 4)
                        }
                    }
                case .gx: //股息率

                    if let yieldRatio = quoteModel.divYield?.value, yieldRatio > 0 {
                        let yieldString = String.init(format: "%.2f%@", Double(yieldRatio) / 100, "%")
                        viewsArray[x].valueLabel.text = yieldString
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }

                case .volume: //成交量

                    var unitString = YXLanguageUtility.kLang(key: "stock_unit_en")
                    if let market = quoteModel.market, market == kYXMarketUsOption {
                        unitString = YXLanguageUtility.kLang(key: "options_page")
                    }
                    if let volume = quoteModel.volume?.value, volume > 0 {
                        let volumeString = YXToolUtility.stockData(Double(volume), deciPoint: 2, stockUnit: unitString, priceBase: 0)
                        viewsArray[x].valueLabel.text = volumeString
                    } else {
                        viewsArray[x].valueLabel.text = "0.00" + unitString
                       
                        if YXStockDetailOCTool.isUSIndex(quoteModel){
                            viewsArray[x].valueLabel.text = "--"
                        }
                    }
                case .amount: //成交额
                    if let amount = quoteModel.amount?.value, amount > 0 {
                        let amountString = YXToolUtility.stockData(Double(amount), deciPoint: 2, stockUnit: "", priceBase: priceBasic)
                        viewsArray[x].valueLabel.text = amountString
                    } else {
                        viewsArray[x].valueLabel.text = "0.00"
                        if YXStockDetailOCTool.isUSIndex(quoteModel){
                            viewsArray[x].valueLabel.text = "--"
                        }
                    }
                case .circulationValue: //流通值
                    if let circulationValue = quoteModel.floatCap?.value, circulationValue > 0 {
                        let circulationValueString = YXToolUtility.stockData(Double(circulationValue), deciPoint: 2, stockUnit: "", priceBase: priceBasic)
                        viewsArray[x].valueLabel.text = circulationValueString
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .marketValue: //总市值

                    if let marketValue = quoteModel.mktCap?.value, marketValue > 0 {
                        let marketValueString = YXToolUtility.stockData(Double(marketValue), deciPoint: 2, stockUnit: "", priceBase: priceBasic)
                        viewsArray[x].valueLabel.text = marketValueString
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }

                case .tradingUnit: //每手
                    if let tradingUnit = quoteModel.trdUnit?.value, tradingUnit != 0 {
                        let str = "\(tradingUnit)" + YXLanguageUtility.kLang(key: "stock_unit_en")
                        viewsArray[x].valueLabel.text = str
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .outstanding_pct: //街货比
                    let outstandingPct = quoteModel.outstandingPct?.value ?? 0
                    var outstandingPctString = YXToolUtility.stockPercentData(Double(outstandingPct), priceBasic: priceBasic, deciPoint: 2) ?? "0"
                    // 去掉"+"号
                    if outstandingPctString.contains("+") {
                        outstandingPctString = outstandingPctString.replacingOccurrences(of: "+", with: "")
                    }
                    viewsArray[x].valueLabel.text = outstandingPctString
                case .impliedVolatility: //引伸波幅
                    if let impliedVolatility = quoteModel.impliedVolatility?.value, impliedVolatility != 0 {
                        let impliedVolatilityString = YXToolUtility.stockData(Double(impliedVolatility), deciPoint: 2, stockUnit: "", priceBase: priceBasic)

                        viewsArray[x].valueLabel.text = impliedVolatilityString
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }

                case .optionImpliedVolatility: // 期权：隐含波动率

                    if let impliedVolatility = quoteModel.impliedVolatility?.value, impliedVolatility != 0 {
                        viewsArray[x].valueLabel.text = String(format: "%.02f%%", Double(impliedVolatility) / 100.0)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }

                case .convertPrice: //换股价
                    if let convertPrice = quoteModel.convertPrice?.value, convertPrice > 0 {
                        let convertPriceString = YXToolUtility.stockData(Double(convertPrice), deciPoint: priceBasic, stockUnit: "", priceBase: priceBasic)
                        viewsArray[x].valueLabel.text = convertPriceString
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .callPrice: //回收价
                    if let callPrice = quoteModel.callPrice?.value, callPrice != 0 {
                        let callPriceString = YXToolUtility.stockPriceData(Double(callPrice), deciPoint: 3, priceBase: priceBasic)
                        viewsArray[x].valueLabel.text = callPriceString
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .diffRatio: //距回收价
                    if let value = quoteModel.diffRatio?.value, value != 0 {
                        viewsArray[x].valueLabel.text = String(format: "%.02f%%", Double(value) * 1.0 / 100)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .turnoverRate: //换手率
                    if let turnoverRate = quoteModel.turnoverRate?.value, turnoverRate > 0 {
                        viewsArray[x].valueLabel.text = String(format: "%.02f%%", Double(turnoverRate) * 1.0 / 100)
                    } else {
                        viewsArray[x].valueLabel.text = "0.00%"
                       // viewsArray[x].valueLabel.text = "--"
                    }
                case .upperStrike: //上限价
                    var tempPriceBasic = 3
                    if let basic = quoteModel.underlingSEC?.priceBase?.value {
                        tempPriceBasic = Int(basic)
                    }
                    if let strikeUpper = quoteModel.strikeUpper?.value, strikeUpper != 0 {
                        let strikeUpperString = YXToolUtility.stockPriceData(Double(strikeUpper), deciPoint: tempPriceBasic, priceBase: priceBasic)
                        viewsArray[x].valueLabel.text = strikeUpperString
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .lowerStrike: //下限价
                    var tempPriceBasic = 3
                    if let basic = quoteModel.underlingSEC?.priceBase?.value {
                        tempPriceBasic = Int(basic)
                    }
                    if let strikeLower = quoteModel.strikeLower?.value, strikeLower != 0 {
                        let strikeLowerString = YXToolUtility.stockPriceData(Double(strikeLower), deciPoint: tempPriceBasic, priceBase: priceBasic)
                        viewsArray[x].valueLabel.text = strikeLowerString
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .toUpperStrike: //距上限
                    if let fromUpper = quoteModel.fromUpper?.value, fromUpper != 0 {
                        viewsArray[x].valueLabel.text = String(format: "%.02f%%", Double(fromUpper) * 1.0 / 100.0)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .toLowerStrike: //距下限
                    if let fromLower = quoteModel.fromLower?.value, fromLower != 0 {
                        viewsArray[x].valueLabel.text = String(format: "%.02f%%", Double(fromLower) * 1.0 / 100.0)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .issue_vol: //发行数量
                    if let issueShares = quoteModel.issueShares?.value, issueShares != 0 {
                        let issueSharesString = YXToolUtility.stockData(Double(issueShares), deciPoint: 2, stockUnit: "", priceBase: 0)
                        viewsArray[x].valueLabel.text = issueSharesString
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .last_trade_day:
                    if let lastTrdDate = quoteModel.lastTrdDate?.value, String(lastTrdDate).count >= 8 {
                        viewsArray[x].valueLabel.text = YXDateHelper.commonDateStringWithNumber(UInt64(lastTrdDate))
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .maturity_date: //到期日期
                    if let maturityDate = quoteModel.maturityDate?.value, String(maturityDate).count >= 8 {
                        viewsArray[x].valueLabel.text = YXDateHelper.commonDateStringWithNumber(UInt64(maturityDate))
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .expDate: //期权 到期日期
                    if let expDate = quoteModel.expDate?.value, String(expDate).count >= 8 {
                        viewsArray[x].valueLabel.text = YXDateHelper.commonDateStringWithNumber(UInt64(expDate))
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .wc_trading_unit: //每手分数
                    if let tradingUnit = quoteModel.trdUnit?.value, tradingUnit != 0 {
                        viewsArray[x].valueLabel.text = "\(tradingUnit)"
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .highP1Y: //52周最高
                    if let highP1Y = quoteModel.week52High?.value, highP1Y != 0 {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(highP1Y), deciPoint: priceBasic, priceBase: priceBasic)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .lowP1Y: //52周最低
                    if let lowP1Y = quoteModel.week52Low?.value, lowP1Y != 0 {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(lowP1Y), deciPoint: priceBasic, priceBase: priceBasic)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .highLowP1Y: //52周高低
                    if let lowP1Y = quoteModel.week52Low?.value, let highP1Y = quoteModel.week52High?.value {
                        let highString = YXToolUtility.stockPriceData(Double(highP1Y), deciPoint: priceBasic, priceBase: priceBasic) ?? ""
                        let lowString = YXToolUtility.stockPriceData(Double(lowP1Y), deciPoint: priceBasic, priceBase: priceBasic) ?? ""
                        viewsArray[x].valueLabel.text = lowString + "-" + highString
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .cittthan: //委比
//                    if let cittthan = quoteModel.pos?.cittThan?.value {
//                        viewsArray[x].valueLabel.text = String(format: "%.02f%%", Double(cittthan) * 1.0 / 100)
//                    } else {
//                        viewsArray[x].valueLabel.text = "--"
//                    }
                    // 委比放到外面更新
                    print("")
                case .volumeRatio: //量比
                    if let volumeRatio = quoteModel.volumeRatio?.value {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockData(Double(volumeRatio), deciPoint: 2, stockUnit: "", priceBase: 4)
                    } else {
                      //  viewsArray[x].valueLabel.text = "0.00"
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .amp: //振幅
                    if let amp = quoteModel.amp?.value {
                        viewsArray[x].valueLabel.text = String(format: "%.02f%%", Double(amp) * 1.0 / 100)
                    } else {
                      //  viewsArray[x].valueLabel.text = "0.00%"
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .pb: //市净率
                    if let pb = quoteModel.pb?.value, pb != 0 {
                        let pbString = YXToolUtility.stockData(Double(pb), deciPoint: 2, stockUnit: "", priceBase: 4)
                        viewsArray[x].valueLabel.text = pbString
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .total: //总股本
                    if let total = quoteModel.issuedShare?.value, total != 0 {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockData(Double(total), deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .share: //流通股本
                    if let share = quoteModel.floatShare?.value, share != 0 {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockData(Double(share), deciPoint: 2, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .outstandingQty: //街货量
                    if let outstandingQty = quoteModel.outstandingQty?.value {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockData(Double(outstandingQty), deciPoint: 2, stockUnit: "", priceBase: 0)
                    } else {
                        viewsArray[x].valueLabel.text = "0.00"
                    }
                case .premium: //溢价

                    var value: Int32 = 0
                    if let premium = quoteModel.premium?.value {
                        viewsArray[x].valueLabel.text = String(format: "%.02f%%", Double(premium) * 1.0 / 100)
                        value = premium
                    } else {
                        viewsArray[x].valueLabel.text = "0.00%"
                    }

                    if let type3 = quoteModel.type3?.value, (type3 == OBJECT_SECUSecuType3.stEtf.rawValue || type3 == OBJECT_SECUSecuType3.stFundUsEtn.rawValue) {

                        viewsArray[x].valueLabel.textColor = YXToolUtility.stockChangeColor(Double(value))
                    }

                case .strike: //行权价
                    if let strike = quoteModel.strikePrice?.value, strike != 0 {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(strike), deciPoint: priceBasic, priceBase: priceBasic)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .breakevenPoint: //打和点
                    if let breakevenPoint = quoteModel.breakevenPoint?.value, breakevenPoint != 0 {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(breakevenPoint), deciPoint: priceBasic, priceBase: priceBasic)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .conversionRatio: //换股比例
                    if quoteModel.adr != nil {
                        if let conversionRatio = quoteModel.adr?.convRatio?.value, let priceBase = quoteModel.adr?.priceBase?.value  {
                            viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(conversionRatio), deciPoint: 2, priceBase: Int(priceBase))
                        } else {
                            viewsArray[x].valueLabel.text = "--"
                        }
                    } else {
                        if let conversionRatio = quoteModel.conversionRatio?.value {
                            viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(conversionRatio), deciPoint: 2, priceBase: priceBasic)
                        } else {
                            viewsArray[x].valueLabel.text = "--"
                        }
                    }

                case .effgearing: //实际杠杆
                    if let effgearing = quoteModel.effgearing?.value, effgearing != 0 {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(effgearing), deciPoint: 2, priceBase: priceBasic)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .gearing: //杠杆比率
                    if let gearing = quoteModel.gearing?.value, gearing != 0 {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(gearing), deciPoint: 2, priceBase: priceBasic)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .postVolume: //盘后量
                    if let postVolume = quoteModel.postVolume?.value, postVolume > 0 {
                        var deciPoint = 2
                        if YXUserManager.isENMode() {
                            if (postVolume < 1000) {
                                deciPoint = 0;
                            }
                        } else {
                            if (postVolume < 10000) {
                                deciPoint = 0;
                            }
                        }
                        viewsArray[x].valueLabel.text = YXToolUtility.stockData(Double(postVolume), deciPoint: deciPoint, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .postAmount: //盘后价
                    if let postAmount = quoteModel.postAmount?.value, postAmount > 0 {
                        let amountString = YXToolUtility.stockData(Double(postAmount), deciPoint: 2, stockUnit: "", priceBase: priceBasic)
                        viewsArray[x].valueLabel.text = amountString
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .register: //是否注册制

                    if let value = quoteModel.aStockFlag?.value, (value & 0x1) > 0 {
                        viewsArray[x].valueLabel.text = YXLanguageUtility.kLang(key: "mine_yes")
                    } else {
                        viewsArray[x].valueLabel.text = YXLanguageUtility.kLang(key: "mine_no")
                    }

                case .votingRights: //表决权差异
                    if let value = quoteModel.aStockFlag?.value, (value & 0x4) > 0 {
                        viewsArray[x].valueLabel.text = YXLanguageUtility.kLang(key: "mine_yes")
                    } else {
                        viewsArray[x].valueLabel.text = YXLanguageUtility.kLang(key: "mine_no")
                    }

                case .controlArc: //协议控制架构
                    if let value = quoteModel.aStockFlag?.value, (value & 0x8) > 0 {
                        viewsArray[x].valueLabel.text = YXLanguageUtility.kLang(key: "mine_yes")
                    } else {
                        viewsArray[x].valueLabel.text = YXLanguageUtility.kLang(key: "mine_no")
                    }

                case .profitable: //是否盈利
                    if let value = quoteModel.aStockFlag?.value, (value & 0x2) > 0 {
                        viewsArray[x].valueLabel.text = YXLanguageUtility.kLang(key: "mine_no")
                    } else {
                        viewsArray[x].valueLabel.text = YXLanguageUtility.kLang(key: "mine_yes")
                    }

                case .SharesEqualRights: //是否同股同权
                    if let value = quoteModel.aStockFlag?.value, (value & 0x4) > 0 {
                        viewsArray[x].valueLabel.text = YXLanguageUtility.kLang(key: "mine_no")
                    } else {
                        viewsArray[x].valueLabel.text = YXLanguageUtility.kLang(key: "mine_yes")
                    }
                case .upperLimit: //涨停价
                    if let value = quoteModel.upperLimit?.value, value > 0 {
                        let valueString = YXToolUtility.stockPriceData(Double(value), deciPoint: priceBasic, priceBase: priceBasic)
                        viewsArray[x].valueLabel.text = valueString
                    }
                case .lowerLimit: //跌停价
                    if let value = quoteModel.lowerLimit?.value, value > 0 {
                        let valueString = YXToolUtility.stockPriceData(Double(value), deciPoint: priceBasic, priceBase: priceBasic)
                        viewsArray[x].valueLabel.text = valueString
                    }
                case .dividend: //股息
                    if let value = quoteModel.dividend?.value, value > 0 {
                        let valueString = YXToolUtility.stockPriceData(Double(value), deciPoint: 3, priceBase: priceBasic)
                        viewsArray[x].valueLabel.text = valueString
                    }
                case .up: //涨家数
                    if let value = quoteModel.up?.value {
                        viewsArray[x].valueLabel.text = "\(value)"
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .down: //跌家数
                    if let value = quoteModel.down?.value {
                        viewsArray[x].valueLabel.text = "\(value)"
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .unchange: //平家数
                    if let value = quoteModel.unchange?.value {
                        viewsArray[x].valueLabel.text = "\(value)"
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .moneyness: //价内价外
                    if let value = quoteModel.diffRatio?.value {
                        viewsArray[x].valueLabel.text = String(format: "%.02f%%", Double(value) * 1.0 / 100)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .historyHigh: //历史最高
                    if let value = quoteModel.historyHigh?.value, value != 0 {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(value), deciPoint: priceBasic, priceBase: priceBasic)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .historyLow: //历史最低
                    if let value = quoteModel.historyLow?.value, value != 0 {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(value), deciPoint: priceBasic, priceBase: priceBasic)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .avg:   //均价
                    if let value = quoteModel.avg?.value, value != 0 {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(value), deciPoint: priceBasic, priceBase: priceBasic)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .delta: //对冲值
                    if let value = quoteModel.delta?.value {
                        let text =  YXToolUtility.stockPriceData(Double(value), deciPoint: priceBasic, priceBase: priceBasic)
                        viewsArray[x].valueLabel.text = text?.replacingOccurrences(of: "+", with: "")
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .openInt: //未平仓数
                    if let value = quoteModel.openInt?.value, value >= 0 {
                        var deciPoint = 0
                        if YXUserManager.isENMode(), value > 1000 {
                            deciPoint = 2
                        } else if (value > 10000) {
                            deciPoint = 2
                        }
                        var unit: String = ""
                        if (quoteModel.market == kYXMarketUsOption) {
                            unit = YXLanguageUtility.kLang(key: "options_page")
                        }
                        viewsArray[x].valueLabel.text = YXToolUtility.stockData(Double(value), deciPoint: deciPoint, stockUnit: unit, priceBase: 0)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .contractSize: //每份合约
                    if let value = quoteModel.contractSize?.value, value > 0 {
                        var deciPoint = 0
                        if YXUserManager.isENMode(), value > 1000 {
                            deciPoint = 2
                        } else if (value > 10000) {
                            deciPoint = 2
                        }
                        viewsArray[x].valueLabel.text = YXToolUtility.stockData(Double(value), deciPoint: deciPoint, stockUnit: YXLanguageUtility.kLang(key: "stock_unit_en"), priceBase: 0)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
               case .optionDelta: //Delta
                    if let value = quoteModel.delta?.value {
                        viewsArray[x].valueLabel.text = String(format: "%.3f", Double(value) / 10000.0)
                    } else {
                        viewsArray[x].valueLabel.text = "0.000"
                    }
               case .gamma: //Gamma
                    if let value = quoteModel.gamma?.value {
                        viewsArray[x].valueLabel.text = String(format: "%.3f", Double(value) / 10000.0)
                    } else {
                        viewsArray[x].valueLabel.text = "0.000"
                    }
                case .theta: //Theta
                    if let value = quoteModel.theta?.value {
                        viewsArray[x].valueLabel.text = String(format: "%.3f", Double(value) / 10000.0)
                    } else {
                        viewsArray[x].valueLabel.text = "0.000"
                    }
                case .vega: //Vega
                    if let value = quoteModel.vega?.value {
                        viewsArray[x].valueLabel.text = String(format: "%.3f", Double(value) / 10000.0)
                    } else {
                        viewsArray[x].valueLabel.text = "0.000"
                    }
                case .rho: //Rho
                    if let value = quoteModel.rho?.value {
                        viewsArray[x].valueLabel.text = String(format: "%.3f", Double(value) / 10000.0)
                    } else {
                        viewsArray[x].valueLabel.text = "0.000"
                    }

                case .navPs: // 基金净值 每股净值
                    if let value = quoteModel.navPS?.value, value > 0 {

                        viewsArray[x].valueLabel.text = YXToolUtility.stockData(Double(value), deciPoint: 2, stockUnit: "", priceBase: priceBasic)
                    }
                case .totalAsset: // 总资产
                    if let value = quoteModel.totalAsset?.value, value > 0 {

                        viewsArray[x].valueLabel.text = YXToolUtility.stockData(Double(value), deciPoint: 2, stockUnit: "", priceBase: priceBasic)
                    }
                case .assetType: // 资产类型

                    let type = quoteModel.assetType?.value ?? 0;
                    var typeStr = "--"
                    if (type == OBJECT_SECUFundAssetType.fundAssetStock.rawValue) {
                        typeStr = YXLanguageUtility.kLang(key: "hold_stock_name")
                    } else if (type == OBJECT_SECUFundAssetType.fundAssetCommodity.rawValue) {
                        typeStr = YXLanguageUtility.kLang(key: "brief_commodity")
                    } else if (type == OBJECT_SECUFundAssetType.fundAssetCurrency.rawValue) {
                        typeStr = YXLanguageUtility.kLang(key: "brief_currency")
                    } else if (type == OBJECT_SECUFundAssetType.fundAssetFuture.rawValue) {
                        typeStr = YXLanguageUtility.kLang(key: "brief_futures")
                    } else if (type == OBJECT_SECUFundAssetType.fundAssetCds.rawValue) {
                        typeStr = YXLanguageUtility.kLang(key: "brief_assetCds")
                    } else if (type == OBJECT_SECUFundAssetType.fundAssetMultiAsset.rawValue) {
                        typeStr = YXLanguageUtility.kLang(key: "brief_multiAsset")
                    } else if (type == OBJECT_SECUFundAssetType.fundAssetFixed.rawValue) {
                        typeStr = YXLanguageUtility.kLang(key: "brief_assetFixed")
                    }

                    viewsArray[x].valueLabel.text = typeStr

                case .currency: //货币单位
                    let moneyArr = ["--", "CNY", "USD", "HKD", "--",
                                    "SGD", "JPY", "GBP", "EUR", "CAD", "AUD"];
                    if let value = quoteModel.currency?.value, value <  moneyArr.count {
                        viewsArray[x].valueLabel.text = moneyArr[Int(value)];
                    }
                case .exerciseStyle: //期权类型

                    if let value = quoteModel.exerciseStyle?.value {
                        var style = ""
                        if value == OBJECT_SECUExerciseStyle.exerEur.rawValue {
                            style = YXLanguageUtility.kLang(key: "option_exerciseStyle_eur")
                        } else if value == OBJECT_SECUExerciseStyle.exerUsa.rawValue {
                            style = YXLanguageUtility.kLang(key: "option_exerciseStyle_usa")
                        } else if value == OBJECT_SECUExerciseStyle.exerBmd.rawValue {
                            style = YXLanguageUtility.kLang(key: "option_exerciseStyle_bmd")
                        } else {
                            style = YXLanguageUtility.kLang(key: "option_exerciseStyle_other")
                        }

                        viewsArray[x].valueLabel.text = style;
                    }
                case .open24: //数字货币 24h向后数第一笔价格
                    if let valueStr = quoteModel.btRealTime?.open, let value = Double(valueStr) {
                        viewsArray[x].valueLabel.text = YXToolUtility.btNumberString(valueStr, decimalPoint: 0)

                        if let pcloseStr = quoteModel.btRealTime?.preClose, let pClose = Double(pcloseStr) {
                            viewsArray[x].valueLabel.textColor = YXToolUtility.changeColor(Double(value - pClose))
                        }
                    }
                case .high24: //数字货币 24小时最高价
                    if let valueStr = quoteModel.btRealTime?.high, let value = Double(valueStr) {
                        viewsArray[x].valueLabel.text = YXToolUtility.btNumberString(valueStr, decimalPoint: 0)

                        if let pcloseStr = quoteModel.btRealTime?.preClose, let pClose = Double(pcloseStr) {
                            viewsArray[x].valueLabel.textColor = YXToolUtility.changeColor(Double(value - pClose))
                        }
                    }
                case .low24: //数字货币 24小时最底价
                    if let valueStr = quoteModel.btRealTime?.low, let value = Double(valueStr) {
                        viewsArray[x].valueLabel.text = YXToolUtility.btNumberString(valueStr, decimalPoint: 0)

                        if let pcloseStr = quoteModel.btRealTime?.preClose, let pClose = Double(pcloseStr) {
                            viewsArray[x].valueLabel.textColor = YXToolUtility.changeColor(Double(value - pClose))
                        }
                    }

                case .high52w: //数字货币 52周高成交价格
                    if let valueStr = quoteModel.btRealTime?.high52W {
                        viewsArray[x].valueLabel.text = YXToolUtility.btNumberString(valueStr, decimalPoint: 0)
                    }
                case .low52w: //数字货币 52周最低成交价格
                    if let valueStr = quoteModel.btRealTime?.low52W {
                        viewsArray[x].valueLabel.text = YXToolUtility.btNumberString(valueStr, decimalPoint: 0)
                    }
                case .volume24: //数字货币 24成交量
                    if let valueStr = quoteModel.btRealTime?.volume {
                        viewsArray[x].valueLabel.text = YXToolUtility.btNumberString(valueStr, decimalPoint: 0, isVol: true)
                    }
                case .amount24: //数字货币 24h成交额
                    if let valueStr = quoteModel.btRealTime?.amount {
                        viewsArray[x].valueLabel.text = YXToolUtility.btNumberString(valueStr, decimalPoint: 0, isVol: true)
                    }
                case .eps: //每股收益
                    if let eps = quoteModel.eps?.value {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(eps), deciPoint: 2, priceBase: priceBasic)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }
                case .epsTTM: //每股收益(TTM)
                    if let epsTTM = quoteModel.epsTTM?.value {
                        viewsArray[x].valueLabel.text = YXToolUtility.stockPriceData(Double(epsTTM), deciPoint: 2, priceBase: priceBasic)
                    } else {
                        viewsArray[x].valueLabel.text = "--"
                    }

                default:
                    print("")
            }
        }
    }

    func showUSAmountAlert() {
        let alertView = YXAlertView(message: YXLanguageUtility.kLang(key: "stock_detail_us_amount_tip"))
        alertView.messageLabel.font = .systemFont(ofSize: 16)
        alertView.messageLabel.textAlignment = .left
        alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_confirm"), style: .default, handler: { (action) in

        }))

        alertView.showInWindow()
    }

    func showStInlineWarrantAlert() {
        //取消
        let cancel = QMUIAlertAction(title: YXLanguageUtility.kLang(key: "common_iknow"), style: .default) { (alertController, action) in

        }
        cancel.buttonAttributes = [NSAttributedString.Key.foregroundColor : QMUITheme().mainThemeColor(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)]

        //弹框
        let alertController = QMUIAlertController.init(title: nil, message: nil, preferredStyle: .alert)
        alertController.alertContentMargin = UIEdgeInsets(top: 0, left: uniHorLength(28), bottom: 0, right: uniHorLength(28))
        alertController.alertContentMaximumWidth = YXConstant.screenWidth

        alertController.alertSeparatorColor = QMUITheme().textColorLevel1()
        alertController.alertContentCornerRadius = 20
        alertController.alertButtonHeight = 48
        alertController.alertHeaderInsets = UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
        alertController.addAction(cancel)
        alertController.addCustomView(warrantAlertView)
        alertController.showWith(animated: true)
    }
}

