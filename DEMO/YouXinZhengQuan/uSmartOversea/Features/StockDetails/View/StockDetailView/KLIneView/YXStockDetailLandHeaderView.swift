//
//  YXStockDetailLandHeaderView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/8/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

import YXKit

class YXStockDetailLandHeaderView: UIView {
    
    var parameterViews: [YXStockDetailLandscapeHeadLabel] = [YXStockDetailLandscapeHeadLabel]()

    var titles: [YXStockDetailBasicType] {
        if self.market == kYXMarketCryptos {
            return [ .high24, .low24, .volume24]
        } else {
            return [ .now, .high, .volume, .pclose, .low, .amount ]
        }

    }

    var market = "" {
        didSet {

            if market == kYXMarketCryptos {
                directionImageView.isHidden = true
                changeLabel.isHidden = true
                statusLabel.isHidden = true

                nameLabel.snp.updateConstraints { (make) in
                    make.width.equalTo(100)
                }

                nowLabel.snp.updateConstraints { (make) in
                    make.width.equalTo(115)
                }
            } else {
                directionImageView.isHidden = false
                changeLabel.isHidden = false
                statusLabel.isHidden = false

                nameLabel.snp.updateConstraints { (make) in
                    make.width.equalTo(nameWidth)
                }

                nowLabel.snp.updateConstraints { (make) in
                    make.width.equalTo(nowWidth)
                }
            }

            setUpParametersView()
        }
    }
    
    var hkIndex = false {
        didSet {
            // 隐藏成交量
            if self.hkIndex {
                for i in 0..<titles.count {
                    let type = titles[i]
                    if type == .volume {
                        let view = self.parameterViews[i]
                        view.isHidden = true
                        break
                    }
                }
            } else {
                for i in 0..<titles.count {
                    let type = titles[i]
                    if type == .volume {
                        let view = self.parameterViews[i]
                        view.isHidden = false
                        break
                    }
                }
            }
        }
    }
    var usIndex = false {
        didSet {
            // 隐藏成交e
            if self.usIndex {
                for i in 0..<titles.count {
                    let type = titles[i]
                    if type == .amount {
                        let view = self.parameterViews[i]
                        view.isHidden = true
                        break
                    }
                }
            } else {
                for i in 0..<titles.count {
                    let type = titles[i]
                    if type == .amount {
                        let view = self.parameterViews[i]
                        view.isHidden = false
                        break
                    }
                }
            }
        }
    }
    
    //model
    var quoteModel: YXV2Quote? {
        didSet {
            refreshUI()
        }
    }
    
    var statusMarketString: String = "" {
        didSet {
            statusLabel.text = statusMarketString
        }
    }
    
    let nameWidth = 180.0 * YXConstant.screenWidth / 375.0
    let nowWidth = 130.0 * YXConstant.screenWidth / 375.0
    
    lazy var nameLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = "--"
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 12.0 / 16.0
        label.numberOfLines = 0
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapGestureEvent))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var nowLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = "--"
        label.textColor = QMUITheme().stockGrayColor()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        if YXToolUtility.is4InchScreenWidth(), YXUserManager.isENMode() {
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    lazy var directionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var changeLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = "--"
        label.textColor = QMUITheme().stockGrayColor()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    lazy var statusLabel: QMUILabel = {
        let label = QMUILabel()
        label.text = "--"
        label.textColor = QMUITheme().textColorLevel3()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    lazy var paraView: UIView = {
        let view = UIView()

        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        

        addSubview(nameLabel)
        addSubview(nowLabel)
        addSubview(directionImageView)
        addSubview(changeLabel)
        addSubview(statusLabel)

        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(19)
            make.width.equalTo(nameWidth)
        }
        
        statusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(12)
            make.height.equalTo(12)
            make.width.equalTo(nameWidth)
        }

        nowLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(nameLabel.snp.trailing).offset(5)
            make.top.equalToSuperview().offset(9)
            make.height.equalTo(21)
            make.width.equalTo(nowWidth)
        }

        nowLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        directionImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
            make.leading.equalTo(nowLabel)
            make.top.equalTo(nowLabel.snp.bottom).offset(3)
        }

        changeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(directionImageView.snp.trailing).offset(2)
            make.centerY.equalTo(directionImageView)
            make.trailing.lessThanOrEqualTo(nowLabel)
        }
        
        let paraView = UIView.init()
        addSubview(paraView)
        paraView.snp.makeConstraints { (make) in
            make.leading.equalTo(nowLabel.snp.trailing).offset(4)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.paraView = paraView
        

    }


    func setUpParametersView() {

        guard paraView.superview != nil else {
            return
        }

        parameterViews.forEach { $0.removeFromSuperview() }
        parameterViews.removeAll()

        let paraViewH: CGFloat = 25
        let isCryptos = self.market == kYXMarketCryptos
        let topMargin: CGFloat = isCryptos ? 7.0 : 5.0
        // 添加子的参数view
        for i in 0..<titles.count {
            let type = titles[i]
            let view = YXStockDetailLandscapeHeadLabel.init()
            view.titleLabel.text = type.title
            view.paraLabel.text = "--"
            paraView.addSubview(view)
            view.leftMargin = 5.0
            if isCryptos {
                view.titleWidth = 50
                view.margin = 10.0
            }
            view.snp.makeConstraints { (make) in

                if i == 0 {
                    make.left.equalToSuperview()
                } else if i == 1 {
                    make.left.equalTo(parameterViews[0].snp.right)
                } else if i == 2 {
                    make.left.equalTo(parameterViews[1].snp.right)
                } else {
                    make.left.equalTo(parameterViews[i % 3])
                }
                make.height.equalTo(paraViewH)
                make.width.equalToSuperview().multipliedBy(1.0 / 3.0)
                make.top.equalToSuperview().offset(topMargin + CGFloat(i / 3) * paraViewH)
            }
            parameterViews.append(view)
        }
    }
    
    //實時數據
    func refreshUI() {
        
        var priceBasic = 1
        if let priceBase = quoteModel?.priceBase?.value, priceBase > 0  {
            priceBasic = Int(priceBase)
        }
        
        var nameStr = "--"

        if self.market == kYXMarketCryptos {
            nameStr = self.quoteModel?.btInfo?.displayedSymbol ?? "--"
        } else {
            if let market = self.quoteModel?.market, market == kYXMarketUsOption {
                if let name = self.quoteModel?.name, name.count > 0 {
                    nameStr = name
                }
            } else {
                //name
                if let name = self.quoteModel?.name, name.count > 0 {
                    if name.count > 16 {
                        nameStr = name.subString(toCharacterIndex: 8) + "..."
                    } else {
                        nameStr = name
                    }
                }

                if let symbol = self.quoteModel?.symbol, symbol.count > 0 {

                    if let market = self.quoteModel?.market {
                        nameStr += "(" + symbol + "." + market.localizedUppercase +  ")"
                    } else {
                        nameStr += "(" + symbol + ")"
                    }
                }
            }
        }

        nameLabel.text = nameStr

        if self.market != kYXMarketCryptos  {
            if statusMarketString.count > 0 {
                self.statusLabel.text = statusMarketString
            } else {
                var statusStr = ""
                if let status = quoteModel?.msInfo?.desc, status.count > 0 {
                    statusStr = status
                }

                //time
                var timeString = ""
                if quoteModel?.greyFlag?.value ?? 0 != 0 , quoteModel?.msInfo?.status?.value == OBJECT_MARKETMarketStatus.msGreyPreOpen.rawValue {

                } else {
                    if let time = quoteModel?.latestTime?.value, time > 0 {
                        var timeStr = YXDateHelper.commonDateStringWithNumber(UInt64(time), format: .DF_MDHMS)
                        if self.market == YXMarketType.US.rawValue {
                            timeStr = timeStr + "  " + YXLanguageUtility.kLang(key: "stock_detail_us_time")
                        }
                        timeString = " " + timeStr
                    }
                }

                self.statusLabel.text = statusStr + timeString
            }

        }

        var changeString = "--"
        var rocString = "--"
        var changeValue = Double(quoteModel?.netchng?.value ?? 0)
        if let market = quoteModel?.market, market == kYXMarketCryptos {
            
            self.nowLabel.text = YXToolUtility.btNumberString(quoteModel?.btRealTime?.now)

            if let valueStr = quoteModel?.btRealTime?.netchng, let value = Double(valueStr)  {
                changeString = (value > 0 ? "+" : "") + valueStr
                changeValue = value
            } else {
                changeString = "0.000"
            }

            if let valueStr = quoteModel?.btRealTime?.pctchng, let value = Double(valueStr)  {
                rocString = String(format: "(%@%%)", (value > 0 ? "+" : "") + valueStr)
            } else {
                rocString = "(0.00%)"
            }


        } else {
            //now
            if let now = quoteModel?.latestPrice?.value, now > 0 {
                let nowString = YXToolUtility.stockPriceData(Double(now), deciPoint: priceBasic, priceBase: priceBasic)
                self.nowLabel.text = nowString
            } else {
                self.nowLabel.text = "--"
            }

            do {
                //change
                if let change = quoteModel?.netchng?.value {
                    let number = YXToolUtility.stockPriceData(Double(change), deciPoint: priceBasic, priceBase: priceBasic)
                    if change >= 0 {
                        changeString = "+" + (number ?? "--")
                    } else {
                        changeString = (number ?? "--")
                    }
                    changeValue = Double(change)
                }

                //roc
                if let roc = quoteModel?.pctchng?.value {
                    rocString = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2)
                }
            }

            directionImageView.image = YXStockDetailTool.changeDirectionImage(changeValue)
            if changeValue == 0 {
                directionImageView.snp.makeConstraints { (make) in
                    make.width.equalTo(0)
                }
            } else {
                directionImageView.snp.makeConstraints { (make) in
                    make.width.equalTo(16)
                }
            }
        }



        self.changeLabel.text = changeString + "  " + rocString

        self.changeLabel.textColor = YXToolUtility.changeColor(Double(changeValue))
        self.nowLabel.textColor = YXToolUtility.changeColor(Double(changeValue))

        
        for x in 0..<titles.count {
            let type = titles[x]
            switch type {
            case .now:
                if let open = quoteModel?.open?.value {
                    if open > 0 {
                        let openString = YXToolUtility.stockPriceData(Double(open), deciPoint: priceBasic, priceBase: priceBasic)
                        parameterViews[x].paraLabel.text = openString
                        if let pclose = quoteModel?.preClose?.value, pclose > 0 {
                            parameterViews[x].paraLabel.textColor = YXToolUtility.priceTextColor(Double(open), comparedData: Double(pclose))
                        }
                    } else {
                        parameterViews[x].paraLabel.text = "--"
                    }
                }
            case .pclose:
                if let pclose = quoteModel?.preClose?.value {
                    if pclose > 0 {
                        let pcloseString = YXToolUtility.stockPriceData(Double(pclose), deciPoint: priceBasic, priceBase: priceBasic)
                        parameterViews[x].paraLabel.text = pcloseString
                    } else {
                        parameterViews[x].paraLabel.text = "--"
                    }
                }
            case .high:
                if let high = quoteModel?.high?.value {
                    if high > 0 {
                        let highString = YXToolUtility.stockPriceData(Double(high), deciPoint: priceBasic, priceBase: priceBasic)
                        parameterViews[x].paraLabel.text = highString
                        if let pclose = quoteModel?.preClose?.value, pclose > 0 {
                            parameterViews[x].paraLabel.textColor = YXToolUtility.priceTextColor(Double(high), comparedData: Double(pclose))
                        }
                    } else {
                        parameterViews[x].paraLabel.text = "--"
                    }
                }
            case .low:
                if let low = quoteModel?.low?.value {
                    if low > 0 {
                        let lowString = YXToolUtility.stockPriceData(Double(low), deciPoint: priceBasic, priceBase: priceBasic)
                        parameterViews[x].paraLabel.text = lowString
                        if let pclose = quoteModel?.preClose?.value, pclose > 0 {
                            parameterViews[x].paraLabel.textColor = YXToolUtility.priceTextColor(Double(low), comparedData: Double(pclose))
                        }
                    } else {
                        parameterViews[x].paraLabel.text = "--"
                    }
                }
            case .volume:

                var unitString = YXLanguageUtility.kLang(key: "stock_unit_en")
                if let market = quoteModel?.market, market == kYXMarketUsOption {
                    unitString = YXLanguageUtility.kLang(key: "options_page")
                }
                if let volume = quoteModel?.volume?.value, volume > 0 {
                    let volumeString = YXToolUtility.stockData(Double(volume), deciPoint: 2, stockUnit: unitString, priceBase: 0)
                    parameterViews[x].paraLabel.text = volumeString
                } else {
                    parameterViews[x].paraLabel.text = "0"
                }
            case .amount:
                if let amount = quoteModel?.amount?.value, amount > 0 {
                    let amountString = YXToolUtility.stockData(Double(amount), deciPoint: 2, stockUnit: "", priceBase: priceBasic)
                    parameterViews[x].paraLabel.text = amountString
                } else {
                    parameterViews[x].paraLabel.text = "0"
                }
            case .open24: //数字货币 24h向后数第一笔价格
                if let valueStr = quoteModel?.btRealTime?.open, let value = Double(valueStr) {
                    parameterViews[x].paraLabel.text = YXToolUtility.btNumberString(valueStr, decimalPoint: 0)

                    if let pcloseStr = quoteModel?.btRealTime?.preClose, let pClose = Double(pcloseStr) {
                        parameterViews[x].paraLabel.textColor = YXToolUtility.changeColor(Double(value - pClose))
                    }
                }
            case .high24: //数字货币 24小时最高价
                if let valueStr = quoteModel?.btRealTime?.high, let value = Double(valueStr) {
                    parameterViews[x].paraLabel.text = YXToolUtility.btNumberString(valueStr, decimalPoint: 0)

                    if let pcloseStr = quoteModel?.btRealTime?.preClose, let pClose = Double(pcloseStr) {
                        parameterViews[x].paraLabel.textColor = YXToolUtility.changeColor(Double(value - pClose))
                    }
                }
            case .low24: //数字货币 24小时最底价
                if let valueStr = quoteModel?.btRealTime?.low, let value = Double(valueStr) {
                    parameterViews[x].paraLabel.text = YXToolUtility.btNumberString(valueStr, decimalPoint: 0)

                    if let pcloseStr = quoteModel?.btRealTime?.preClose, let pClose = Double(pcloseStr) {
                        parameterViews[x].paraLabel.textColor = YXToolUtility.changeColor(Double(value - pClose))
                    }
                }

            case .high52w: //数字货币 52周高成交价格
                if let valueStr = quoteModel?.btRealTime?.high52W {
                    parameterViews[x].paraLabel.text = YXToolUtility.btNumberString(valueStr, decimalPoint: 0)
                }
            case .low52w: //数字货币 52周最低成交价格
                if let valueStr = quoteModel?.btRealTime?.low52W {
                    parameterViews[x].paraLabel.text = YXToolUtility.btNumberString(valueStr, decimalPoint: 0)
                }
            case .volume24: //数字货币 24成交量
                if let valueStr = quoteModel?.btRealTime?.volume {
                    parameterViews[x].paraLabel.text = YXToolUtility.btNumberString(valueStr, decimalPoint: 0, isVol: true)
                }
            case .amount24: //数字货币 24h成交额
                if let valueStr = quoteModel?.btRealTime?.amount {
                    parameterViews[x].paraLabel.text = YXToolUtility.btNumberString(valueStr, decimalPoint: 0, isVol: true)
                }
            default:
                print("")
            }
        }
    }
    
  
    @objc func tapGestureEvent() {

        if let market = self.quoteModel?.market, market == kYXMarketUsOption {

            if let text = self.nameLabel.text, text.count > 0 {
                let width = (text as NSString).boundingRect(with: CGSize(width: 1000, height: 25), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font : self.nameLabel.font!], context: nil).size.width
                if width > self.nameLabel.frame.width {
                    QMUITips.showInfo(text)
                }
            }

        } else {
            let str = (self.quoteModel?.name ?? "") + "(\(self.quoteModel?.symbol ?? ""))"
            if str.count > 16 {
                QMUITips.showInfo(str)
            }
        }
    }

}
