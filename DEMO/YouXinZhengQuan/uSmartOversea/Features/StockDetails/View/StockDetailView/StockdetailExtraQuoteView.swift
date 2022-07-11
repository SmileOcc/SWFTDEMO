//
//  StockdetailExtraQuoteView.swift
//  uSmartOversea
//
//  Created by 陈明茂 on 2022/6/7.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class StockdetailExtraQuoteView: YXStockDetailBaseView, YXStockDetailHeaderViewProtocol {
    
    var heightDidChange: (() -> Void)?
    

    var quoteModel: YXV2Quote? {
        didSet {
            refreshUI()
        }
    }
        
    
    var underlingSec: UnderlingSEC? {
        didSet {
            updateRelatedStockView()
            self.relatedStockView.underlingSec = self.underlingSec
        }
    }

    var relatedQuote: YXV2Quote? {
        didSet {
            updateRelatedStockView()
            self.relatedStockView.quote = relatedQuote
        }
    }
    
    var bearSignalItem: YXBullBearPbSignalItem? {
        didSet {
            showWarrantCbbcView()
        }
    }
    
    
    var parameterHeightBlock: ((_ height: CGFloat, _ animated: Bool) -> Void)?
    
    let kBottomItemHeight: CGFloat = 30
    
    var tapBlock: ((_ market: String, _ symbol: String) -> Void)?
    
    
    lazy var preQuotaView: YXStockDetailPreAfterQuotaView = {
        let view = YXStockDetailPreAfterQuotaView.init()
        view.isHidden = true
        view.contentHeight = kBottomItemHeight
        
        view.clickActionBlock = { [weak self] in
            guard let `self` = self else { return }
            let offset: CGFloat = self.preQuotaView.isSelect ? 34 : 0
            self.preQuotaView.contentHeight = self.kBottomItemHeight + offset
        }
        
        return view
    }()
    
    lazy var relatedStockView: YXStockDetailRelateStockView = {
        let view = YXStockDetailRelateStockView()
        view.isHidden = true
        view.contentHeight = kBottomItemHeight
        view.tapBlock = {
            [weak self] (market, symbol) in
            guard let `self` = self else { return }
            self.tapBlock?(market, symbol)
        }
        return view
    }()


    lazy var adrView: YXStockDetailAdrStockView = {
        let view = YXStockDetailAdrStockView()
        view.isHidden = true
        view.contentHeight = 2 * kBottomItemHeight
        view.tapADRBlock = {
            [weak self] (market, symbol) in
            guard let `self` = self else { return }
            self.tapBlock?(market, symbol)
        }
        return view
    }()
    
    lazy var warrantCbbcView: YXStockDetailWarrantCbbcSignalView = {
        let view = YXStockDetailWarrantCbbcSignalView()
        view.isHidden = true
        view.contentHeight = 48
        return view
    }()
    
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView.init()
        stackView.axis = .vertical
        return stackView
    }()
    
    //MARK: 刷新视图数据
    func refreshUI() {
        
        updatePreQuoteView()

        updateADRView()
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
        
        addSubview(self.stackView)
        
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(8)
        }
        
        stackView.addArrangedSubview(preQuotaView)
        stackView.addArrangedSubview(adrView)
        stackView.addArrangedSubview(relatedStockView)
        stackView.addArrangedSubview(warrantCbbcView)
        
        configStackView()
    }
}


//MARK: AH, ADR相关
extension StockdetailExtraQuoteView {

    func updateADRView() {

        if quoteModel?.ah == nil,  quoteModel?.adr == nil {
            return
        }

        if self.adrView.isHidden == false {
            if let adr = quoteModel?.adr, self.adrView.isHidden == false {
                adrView.adrInfo = adr
            }
        } else {
            if let adr = quoteModel?.adr {
                if let type2 = OBJECT_SECUSecuType2(rawValue: Int32(quoteModel?.type2?.value ?? 0)),
                    (type2 == .stHighAdr || type2 == .stLowAdr) {
                    self.adrView.isParentADR = true
                }
                var height: CGFloat = 2 * kBottomItemHeight
                if let market = self.quoteModel?.adr?.market, market == kYXMarketHK, self.adrView.isParentADR {
                    height = 3 * kBottomItemHeight
                }
                if self.adrView.isHidden {
                    self.adrView.isHidden = false
                    self.adrView.contentHeight = height
                }
                adrView.adrInfo = adr
            }
        }
    }

}



//MARK: 窝轮牛熊关联正股相关
extension StockdetailExtraQuoteView {

    func updateRelatedStockView() {

        if self.relatedStockView.isHidden {
            self.relatedStockView.isHidden = false
        }
    }

}



//MARK: 美股盘前盘后交易显示，赋值相关
extension StockdetailExtraQuoteView {

    func updatePreQuoteView() {

        if YXStockDetailTool.isShowPreAfterQuote(self.quoteModel) {
            
            let marketStatus = quoteModel?.msInfo?.status?.value
            let now = quoteModel?.sQuote?.latestPrice?.value ?? 0
            
            if self.preQuotaView.isHidden {
                self.preQuotaView.isHidden = false
            }

            var statusText = ""
            if marketStatus == OBJECT_MARKETMarketStatus.msPreHours.rawValue {
                statusText = YXLanguageUtility.kLang(key: "stock_detail_pre_quota_price")
            } else {
                statusText = YXLanguageUtility.kLang(key: "stock_detail_after_quota_price")
            }

            self.preQuotaView.marketStatus = marketStatus ?? OBJECT_MARKETMarketStatus.msPreHours.rawValue
            
            if now > 0 {
                self.preQuotaView.timeZoneLabel.isHidden = false
                self.preQuotaView.timeLabel.isHidden = false
                // 有值
                var str = ""
                var priceBasic = 1
                if let priceBase = quoteModel?.priceBase?.value, priceBase > 0  {
                    priceBasic = Int(priceBase)
                }

                let nowString = YXToolUtility.stockPriceData(Double(now), deciPoint: priceBasic, priceBase: priceBasic) ?? "--"
                str = str + nowString

                if let change = quoteModel?.sQuote?.netchng?.value {
                    let changeString = (change > 0 ? "+" : "") + YXToolUtility.stockPriceData(Double(change), deciPoint: priceBasic, priceBase: priceBasic)

                    str = str + "  " + changeString
                }

                if let roc = quoteModel?.sQuote?.pctchng?.value {
                    let rocString = YXToolUtility.stockPercentData(Double(roc), priceBasic: 2, deciPoint: 2) ?? "--"
                    str = str + "  " + rocString
                    self.preQuotaView.preQuotaNowLabel.textColor = YXToolUtility.changeColor(Double(roc))
                }
                self.preQuotaView.preQuotaNowLabel.text = str
                if let time = quoteModel?.sQuote?.latestTime?.value {
                    let dateModel = YXDateToolUtility.dateTime(withTime: String(time))
                    let timeString = dateModel.hour + ":" + dateModel.minute + ":" + dateModel.second
                    statusText += String(format: "(%@ %@)", timeString, "ET")
                }
                
                if let sQuote = self.quoteModel?.sQuote {
                    self.preQuotaView.updateUI(with: sQuote, Int(self.quoteModel?.priceBase?.value ?? 0), (self.quoteModel?.latestPrice?.value ?? 0))
                }

            } else {
                // 无值
                self.preQuotaView.timeZoneLabel.isHidden = true
                self.preQuotaView.timeLabel.isHidden = true
                
                self.preQuotaView.preQuotaNowLabel.text = YXLanguageUtility.kLang(key: "no_trade_plate")
                self.preQuotaView.preQuotaNowLabel.textColor = QMUITheme().textColorLevel1()
                self.preQuotaView.preQuotaNowLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            }

            self.preQuotaView.preQuotaStatusLabel.text = statusText
        }  else {
            
            if !self.preQuotaView.isHidden {
                self.preQuotaView.isHidden = true
            }
        }
    }
}

//MARK: 多空信号
extension StockdetailExtraQuoteView {


    func showWarrantCbbcView() {
        if let bearSignal = bearSignalItem {
            if self.warrantCbbcView.isHidden {
                self.warrantCbbcView.isHidden = false
            }
            self.warrantCbbcView.model = bearSignal
        }
    }

}
