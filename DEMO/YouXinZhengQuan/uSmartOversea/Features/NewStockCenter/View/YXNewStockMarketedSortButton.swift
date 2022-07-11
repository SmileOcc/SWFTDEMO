//
//  YXNewStockMarketedSortButton.swift
//  uSmartOversea
//
//  Created by youxin on 2019/4/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit


class YXNewStockMarketedSortButton: QMUIButton {

    var sortState: YXSortState = .normal {
        didSet {
            updateSortStatus()
        }
    }
    var mobileBrief1Type: YXStockRankSortType = .now {
        didSet {
            updateMobileBrief1Type()
        }
    }
    
    var hiddenImage: Bool = false
    
    func updateMobileBrief1Type() {
        var title = ""
        switch mobileBrief1Type {
        case .listDate:
            title = YXLanguageUtility.kLang(key: "newStock_marketDate")//market_marketDate
        case .issuePrice:
            title = YXLanguageUtility.kLang(key: "market_publishPirce")
        case .now:
            title = YXLanguageUtility.kLang(key: "market_now")
        case .totalRoc:
            title = YXLanguageUtility.kLang(key: "market_total_change")
        case .listedDays:
            title = YXLanguageUtility.kLang(key: "market_market_days")
        case .firstDayClosePrice:
            title = YXLanguageUtility.kLang(key: "market_first_open")
        case .firstDayRoc:
            title = YXLanguageUtility.kLang(key: "market_first_change")
        case .amount:
            title = YXLanguageUtility.kLang(key: "market_amount")
        case .roc:
            title = YXLanguageUtility.kLang(key: "market_roc")
        case .change:
            title = YXLanguageUtility.kLang(key: "market_change")
        case .volume:
            title = YXLanguageUtility.kLang(key: "market_volume")
        case .turnoverRate:
            title = YXLanguageUtility.kLang(key: "stock_detail_turnover_rate")
        case .amp:
            title = YXLanguageUtility.kLang(key: "stock_detail_amplitude")
        case .volumeRatio:
            title = YXLanguageUtility.kLang(key: "stock_detail_vol_ratio")
        case .marketValue:
            title = YXLanguageUtility.kLang(key: "stock_detail_mkt_cap")
        case .pe:
            title = YXLanguageUtility.kLang(key: "stock_detail_pe")
        case .pb:
            title = YXLanguageUtility.kLang(key: "stock_detail_pb")
        case .endDate:
            title = YXLanguageUtility.kLang(key: "warrants_end_date")
        case .premium:
            title = YXLanguageUtility.kLang(key: "warrants_premium")
        case .outstandingRatio:
            title = YXLanguageUtility.kLang(key: "warrants_outstandingPct")
        case .leverageRatio:
            title = YXLanguageUtility.kLang(key: "warrants_gearing")
        case .exchangeRatio:
            title = YXLanguageUtility.kLang(key: "warrants_conversionRatio")
        case .strikePrice:
            title = YXLanguageUtility.kLang(key: "warrants_strike")
        case .dailyBalance:
            title = YXLanguageUtility.kLang(key: "hold_daily_profit_loss")
        case .holdingBalance:
            title = YXLanguageUtility.kLang(key: "hold_position_profit_loss")
        case .lastAndCostPrice:
            title = YXLanguageUtility.kLang(key: "warrants_price_cost")
        case .marketValueAndNumber:
            title = YXLanguageUtility.kLang(key: "warrants_value_qty")
        case .warrantsNow:
            title = YXLanguageUtility.kLang(key: "warrants_latest_price")
        case .lowerStrike:
            title = YXLanguageUtility.kLang(key: "warrants_lower_strike")
        case .upperStrike:
            title = YXLanguageUtility.kLang(key: "warrants_upper_strike")
        case .toLowerStrike:
            title = YXLanguageUtility.kLang(key: "warrants_to_lower_strike")
        case .toUpperStrike:
            title = YXLanguageUtility.kLang(key: "warrants_to_upper_strike")
        case .moneyness:
            title = YXLanguageUtility.kLang(key: "warrants_in_out")
        case .impliedVolatility:
            title = YXLanguageUtility.kLang(key: "warrants_volatility")
        case .actualLeverage:
            title = YXLanguageUtility.kLang(key: "effective_eff_gearing")
        case .callPrice:
            title = YXLanguageUtility.kLang(key: "warrants_call_level")
        case .toCallPrice:
            title = YXLanguageUtility.kLang(key: "warrants_spot_vs_call")
        case .amountMoney:
            title = YXLanguageUtility.kLang(key: "amount_of_moneny")
        case .yesterdayGains:
            title = YXLanguageUtility.kLang(key: "warrants_yesterday_gains")
        case .holdGains:
            title = YXLanguageUtility.kLang(key: "warrants_hold_gains")
        case .deliverApplyDate:
            title = YXLanguageUtility.kLang(key: "delivered_apply_date")
        case .deliverStatus:
            title = YXLanguageUtility.kLang(key: "delivered_status")
        case .adrExchangePrice:
            title = YXLanguageUtility.kLang(key: "stock_detail_adr_conversion_price2")
        case .adrPriceSpread:
            title = YXLanguageUtility.kLang(key: "stock_detail_adr_compare_h")
        case .adrPrice:
            title = YXLanguageUtility.kLang(key: "markets_news_price")
        case .leadStock:
            title = YXLanguageUtility.kLang(key: "markets_news_leadstock")
        case .accer3:
            title = YXStockRankSortType.accer3.title
        case .accer5:
            title = YXStockRankSortType.accer5.title
        case .netInflow:
            title = YXStockRankSortType.netInflow.title
        case .mainInflow:
            title = YXStockRankSortType.mainInflow.title
        case .dividendYield:
            title = YXStockRankSortType.dividendYield.title
        case .yxScore:
            title = YXStockRankSortType.yxScore.title
        case .hStock:
            title = YXStockRankSortType.hStock.title
        case .aStock:
            title = YXStockRankSortType.aStock.title
        case .ahSpread:
            title = YXStockRankSortType.ahSpread.title
        case .adrHKCode:
            title = YXStockRankSortType.adrHKCode.title
        case .marginRatio:
            title = YXStockRankSortType.marginRatio.title
        case .bail:
            title = YXStockRankSortType.bail.title
        case .greyChgPct:
            title = YXStockRankSortType.greyChgPct.title
        case .winningRate:
            title = YXStockRankSortType.winningRate.title
        case .gearingRatio:
            title = YXStockRankSortType.gearingRatio.title
        case .preAndClosePrice:
            title = YXStockRankSortType.preAndClosePrice.title
        case .preRoc:
            title = YXStockRankSortType.preRoc.title
        case .afterAndClosePrice:
            title = YXStockRankSortType.afterAndClosePrice.title
        case .afterRoc:
            title = YXStockRankSortType.afterRoc.title
        case .cittthan:
            title = YXStockRankSortType.cittthan.title
        case .bid:
            title = YXStockRankSortType.bid.title
        case .ask:
            title = YXStockRankSortType.ask.title
        case .bidSize:
            title = YXStockRankSortType.bidSize.title
        case .askSize:
            title = YXStockRankSortType.askSize.title
        case .currency:
            title = YXStockRankSortType.currency.title
        case .expiryDate:
            title = YXStockRankSortType.expiryDate.title
        case .delta:
            title = YXStockRankSortType.delta.title
        case .status:
            title = YXStockRankSortType.status.title
        case .dividendsPriceChg:
            title = YXLanguageUtility.kLang(key: "market_dividends_priceChg")
        case .dividendsRate:
            title = YXLanguageUtility.kLang(key: "market_dividends_rate")
        case .dividendsYield:
            title = YXLanguageUtility.kLang(key: "market_dividends_yield")
        default:
            title = ""
        }
        self.setTitle(title, for: .normal)
    }
    
    func updateSortStatus() {
        
        if hiddenImage || mobileBrief1Type == .preAndClosePrice || mobileBrief1Type == .afterAndClosePrice {
            self.isUserInteractionEnabled = false
            return
        }else {
            self.isUserInteractionEnabled = true
        }
        
        let imageName: String
        switch sortState {
        case .normal:
            imageName = "optional_sort"
        case .descending:
            imageName = "optional_sort_descending"
        case .ascending:
            imageName = "optional_sort_ascending"
        }
        self.setImage(UIImage(named: imageName), for: .normal)
    }
   
    class func button(sortType mobileBrief1Type: YXStockRankSortType, sortState: YXSortState) -> YXNewStockMarketedSortButton {
        let button = YXNewStockMarketedSortButton()
        button.imagePosition = .right
        button.spacingBetweenImageAndTitle = 4.0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 10.0 / 14.0
        button.mobileBrief1Type = mobileBrief1Type
        button.contentHorizontalAlignment = .right
        button.sortState = sortState
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        button.adjustsImageWhenHighlighted = false
        return button
    }
    
    convenience init(mobileBrief1Type: YXStockRankSortType, sortState: YXSortState) {
        self.init()
        self.sortState = sortState
        self.mobileBrief1Type = mobileBrief1Type
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
