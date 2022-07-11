//
//  YXStockDetailFinanceBaseListView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/10/12.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit


class YXStockDetailFinanceListSectionView: UIView {

    var type: YXStockDetailFinancialType = .profit
    
    var parametersViewArray: [YXStockDetailFinanceListParameterView] = []

    var clickItemBlock: ((_ selectIndex: Int) -> ())?

    var selectIndex: Int = 0
    
    var isAStock: Bool = false
    
    var listProfitData: YXStockDetailFinancialListProfitModel? {
        
        didSet {
            if listProfitData == nil {
                self.emptyView.isHidden = false
                return
            }
            self.emptyView.isHidden = true
            fillData()
        }
    }
    
    var listAssetData: YXStockDetailFinancialListAssetModel? {
        
        didSet {
            if listAssetData == nil {
                self.emptyView.isHidden = false
                return
            }
            self.emptyView.isHidden = true
            fillData()
        }
    }
    
    var listCashFlowData: YXStockDetailFinancialListCashFlowModel? {
           
        didSet {
            if listCashFlowData == nil {
                self.emptyView.isHidden = false
                return
            }
            self.emptyView.isHidden = true
            fillData()
        }
    }
    
    var aListData: YXStockDetailFinancialListAStockModel? {
           
        didSet {
            if aListData == nil {
                self.emptyView.isHidden = false
                return
            }
            self.emptyView.isHidden = true
            fillData()
        }
    }
    
    let kInValidValue = 999999.999999
    let dataUnit = pow(10.0, 6.0)
    func fillData() {

        var currencyName = ""

        if isAStock {
            if let reportPeriod = aListData?.compinfo?.reportPeriod {
                
                let endDate = YXDateHelper.commonDateString(reportPeriod)
//                arrowButton.setTitle(endDate, for: .normal)
                self.timeLabel.text =  "(\(endDate))"
            }
            
            currencyName = aListData?.compinfo?.crncyCode ?? ""


            
        } else {
            var periodTypeID = 1  //1-年度， 2-季度， 10-半年
            var quarter = 1 //1-第一季度， 2-第二季度， 3-第三季度， 4-第四季度
            var endDate = "--"
            if self.type == .profit {
                if let id = listProfitData?.list?.periodTypeID {
                    periodTypeID = id
                }
                
                if let fiscal_quarter = listProfitData?.list?.fiscalQuarter {
                    quarter = fiscal_quarter
                }
                endDate = listProfitData?.list?.endDate ?? ""
                currencyName = listProfitData?.list?.currName ?? ""
            } else if self.type == .asset {
                if let id = listAssetData?.list?.periodTypeID {
                    periodTypeID = id
                }
                
                if let fiscal_quarter = listAssetData?.list?.fiscalQuarter {
                    quarter = fiscal_quarter
                }
                endDate = listAssetData?.list?.endDate ?? ""
                currencyName = listAssetData?.list?.currName ?? ""
            } else if self.type == .cashFlow {
                if let id = listCashFlowData?.list?.periodTypeID {
                    periodTypeID = id
                }
                
                if let fiscal_quarter = listCashFlowData?.list?.fiscalQuarter {
                    quarter = fiscal_quarter
                }
                endDate = listCashFlowData?.list?.endDate ?? ""
                currencyName = listCashFlowData?.list?.currName ?? ""
            }
            
            if endDate.count > 10 {
                endDate = endDate.subString(toCharacterIndex: 10)
            }

//            arrowButton.setTitle(endDate, for: .normal)
            let dateString = endDate.replacingOccurrences(of: "-", with: "")
            self.timeLabel.text = "(" + YXDateHelper.commonDateString(dateString) + ")"
        }

        var unitString = ""


        
        for view in parametersViewArray {
            view.yearReportLabel.text = "--"
            view.yearOnYearLabel.text = "--"
            if view.titleLabel.text == YXLanguageUtility.kLang(key: "total_revenues") {
                //总收入
                if isAStock {
                    if let totalRevenues = self.aListData?.list?.totalRevenues, totalRevenues != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(totalRevenues, deciPoint: 2, stockUnit: "", priceBase: 0)

                        //unitString = self.getUnitStr(with: totalRevenues)
                    }
                    
                    if let rate = self.aListData?.yoy?.totalRevenuesYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let totalRevenues = self.listProfitData?.list?.totalRevenues, totalRevenues != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(totalRevenues * dataUnit, deciPoint: 2, stockUnit: "", priceBase: 0)
                        //unitString = self.getUnitStr(with: totalRevenues * dataUnit)
                    }
                    
                    if let rate = self.listProfitData?.yoy?.totalRevenuesYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
                
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "gross_profit") {
               //毛利润
               if isAStock {
                    if let value = self.aListData?.list?.totalProfit, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value, deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.aListData?.yoy?.totalProfitYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let grossProfit = self.listProfitData?.list?.grossProfit, grossProfit != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(grossProfit * dataUnit, deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.listProfitData?.yoy?.grossProfitYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "gross_margin") {
                //毛利率
                if isAStock {
                    if let value = self.aListData?.list?.totalProfitRate, value != kInValidValue {
                        view.yearReportLabel.text = String(format: "%.2lf%%", value)
                    }
                    
                    if let rate = self.aListData?.yoy?.totalProfitRateYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let rate = self.listProfitData?.list?.grossMargin, rate != kInValidValue {
                        view.yearReportLabel.text = String(format: "%.2lf%%", rate)
                    }
                    
                    if let rate = self.listProfitData?.yoy?.grossMarginYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "ebitda") {
                //息税折旧摊销前利润（EBITDA)
                if isAStock {
                    
                } else {
                    if let value = self.listProfitData?.list?.ebitda, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value * dataUnit, deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.listProfitData?.yoy?.ebitdaYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "ebitda_margin") {
                //息税折旧摊销前利润率
                if isAStock {
                    
                } else {
                    if let value = self.listProfitData?.list?.ebitdaMargin, value != kInValidValue {
                        view.yearReportLabel.text = String(format: "%.2lf%%", value)
                    }
                    
                    if let rate = self.listProfitData?.yoy?.ebitdaMarginYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "net_income") {
                //净利润
                if isAStock {
                    if let value = self.aListData?.list?.retainedProfits, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value, deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.aListData?.yoy?.retainedProfitsYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listProfitData?.list?.netIncome, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value * dataUnit, deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.listProfitData?.yoy?.netIncomeYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "net_income_margin") {
                //净利率
                if isAStock {
                    if let value = self.aListData?.list?.retainedProfitsRate, value != kInValidValue {
                        view.yearReportLabel.text = String(format: "%.2lf%%", value)
                    }
                    
                    if let rate = self.aListData?.yoy?.retainedProfitsRateYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listProfitData?.list?.netIncomeMargin, value != kInValidValue {
                        view.yearReportLabel.text = String(format: "%.2lf%%", value)
                    }
                    
                    if let rate = self.listProfitData?.yoy?.netIncomeMarginYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "roa") {
                //资产收益率（ROA)
               if isAStock {
                    if let value = self.aListData?.list?.roa, value != kInValidValue {
                        view.yearReportLabel.text = String(format: "%.2lf%%", value)
                    }
                    
                    if let rate = self.aListData?.yoy?.roaYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listProfitData?.list?.roa, value != kInValidValue {
                        view.yearReportLabel.text = String(format: "%.2lf%%", value)
                    }
                    
                    if let rate = self.listProfitData?.yoy?.roaYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "roe") {
                //净资产收益率（ROE)
                if isAStock {
                    if let value = self.aListData?.list?.roe, value != kInValidValue {
                        view.yearReportLabel.text = String(format: "%.2lf%%", value)
                    }
                    
                    if let rate = self.aListData?.yoy?.roeYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listProfitData?.list?.roe, value != kInValidValue {
                        view.yearReportLabel.text = String(format: "%.2lf%%", value)
                    }
                    
                    if let rate = self.listProfitData?.yoy?.roeYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "eps") {
                //每股权益（EPS)
                if isAStock {
                    if let value = self.aListData?.list?.eps, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value, deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.aListData?.yoy?.epsYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listProfitData?.list?.eps, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value , deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.listProfitData?.yoy?.epsYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "total_current_assets") {
                //流动资产总额
                if isAStock {
                    if let value = self.aListData?.list?.totalCurrentAssets, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value, deciPoint: 2, stockUnit: "", priceBase: 0)
                        //unitString = self.getUnitStr(with: value)
                    }
                    
                    if let rate = self.aListData?.yoy?.totalCurrentAssetsYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listAssetData?.list?.totalCurrentAssets, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value * dataUnit , deciPoint: 2, stockUnit: "", priceBase: 0)
                        //unitString = self.getUnitStr(with: value * dataUnit)
                    }
                    
                    if let rate = self.listAssetData?.yoy?.totalCurrentAssetsYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "total_current_liabilities") {
                //流动负债总额
                if isAStock {
                    if let value = self.aListData?.list?.totalCurrentLiabilities, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value, deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.aListData?.yoy?.totalCurrentLiabilitiesYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listAssetData?.list?.totalCurrentLiabilities, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value * dataUnit , deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.listAssetData?.yoy?.totalCurrentLiabilitiesYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "current_ratio") {
                //流动比率
                if isAStock {
                    if let value = self.aListData?.list?.currentRate, value != kInValidValue {
                        view.yearReportLabel.text = String(format: "%.2lf%%", value)
                    }
                    
                    if let rate = self.aListData?.yoy?.currentRateYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listAssetData?.list?.currentRatio, value != kInValidValue {
                        view.yearReportLabel.text = String(format: "%.2lf%%", value)
                    }
                    
                    if let rate = self.listAssetData?.yoy?.currentRatioYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "total_assets") {
                //总资产
                if isAStock {
                    if let value = self.aListData?.list?.totalAssets, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value, deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.aListData?.yoy?.totalAssetsYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listAssetData?.list?.totalAssets, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value * dataUnit , deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.listAssetData?.yoy?.totalAssetsYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "total_liabilities") {
                //总负债
                if isAStock {
                    if let value = self.aListData?.list?.totalLiabilities, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value, deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.aListData?.yoy?.totalLiabilitiesYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listAssetData?.list?.totalLiabilities, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value * dataUnit , deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.listAssetData?.yoy?.totalLiabilitiesYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "liabilities_ratio") {
                //资产负债率
                if isAStock {
                    if let value = self.aListData?.list?.totalLiabilitiesRate, value != kInValidValue {
                        view.yearReportLabel.text = String(format: "%.2lf%%", value)
                    }
                    
                    if let rate = self.aListData?.yoy?.totalLiabilitiesRateYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listAssetData?.list?.totalLiabilitiesRatio, value != kInValidValue {
                        view.yearReportLabel.text = String(format: "%.2lf%%", value)
                    }
                    
                    if let rate = self.listAssetData?.yoy?.totalLiabilitiesRatioYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "total_equity") {
                //权益总额
                if isAStock {
                    if let value = self.aListData?.list?.totalEquity, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value, deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.aListData?.yoy?.totalEquityYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listAssetData?.list?.totalEquity, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value * dataUnit , deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.listAssetData?.yoy?.totalEquityYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "cash_from_operations") {
                //经营活动现金流量
                if isAStock {
                    if let value = self.aListData?.list?.operationsCash, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value, deciPoint: 2, stockUnit: "", priceBase: 0)
                        //unitString = self.getUnitStr(with: value)
                    }
                    
                    if let rate = self.aListData?.yoy?.operationsCashYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listCashFlowData?.list?.cashFromOperations, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value * dataUnit , deciPoint: 2, stockUnit: "", priceBase: 0)
                        //unitString = self.getUnitStr(with: value * dataUnit)
                    }
                    
                    if let rate = self.listCashFlowData?.yoy?.cashFromOperationsYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "cash_from_investing") {
                //投资活动现金流量
                if isAStock {
                    if let value = self.aListData?.list?.investingCash, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value, deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.aListData?.yoy?.investingCashYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listCashFlowData?.list?.cashFromInvesting, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value * dataUnit , deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.listCashFlowData?.yoy?.cashFromInvestingYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "cash_from_financing") {
                //融资活动现金流量
                if isAStock {
                    if let value = self.aListData?.list?.financingCash, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value, deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.aListData?.yoy?.financingCashYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listCashFlowData?.list?.cashFromFinancing, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value * dataUnit , deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.listCashFlowData?.yoy?.cashFromFinancingYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            } else if view.titleLabel.text == YXLanguageUtility.kLang(key: "net_change_in_cash") {
                //总现金流量
                if isAStock {
                    if let value = self.aListData?.list?.totalCash, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value, deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.aListData?.yoy?.totalCashYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                } else {
                    if let value = self.listCashFlowData?.list?.netChangeInCash, value != kInValidValue {
                        view.yearReportLabel.text = YXToolUtility.stockData(value * dataUnit , deciPoint: 2, stockUnit: "", priceBase: 0)
                    }
                    
                    if let rate = self.listCashFlowData?.yoy?.netChangeInCashYoy, rate != kInValidValue {
                        view.yearOnYearLabel.text = String(format: "%.2lf%%", rate)
                    }
                }
            }
        }



        //unitLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_stock_unit") + ": " + unitString + " " + currencyName

        unitLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_stock_unit") + ": " + currencyName
    }


    func getUnitStr(with maxValue: Double) -> String {

        let type = calUntiType(with: maxValue)
        var str = ""
        switch type {
            case .none:
                str = ""
            case .tenThousand:
                str = YXLanguageUtility.kLang(key: "stock_detail_ten_thousand")
            case .hundredMillion:
                str = YXLanguageUtility.kLang(key: "common_billion")
            case .billion:
                str = "B"
            case .million:
                str = "M"
        }
        return str
    }


    func calUntiType(with maxValue: Float64) -> YXStockDetailFinancialChartView.YXFinancialUnitType {
        var type: YXStockDetailFinancialChartView.YXFinancialUnitType = .none
        let value = abs(maxValue)
        if YXUserManager.isENMode() {
            if (value >= 1E9) {
                type = .billion
            } else if (value >= 1E6) {
                type = .million
            }
        } else {
            if (value >= 1E8) {
                type = .hundredMillion
            } else if (value >= 10000) {
                type = .tenThousand
            }
        }

        return type
    }

    convenience init(frame: CGRect, type: YXStockDetailFinancialType, market: String) {
        self.init(frame: frame)
        self.type = type
        
        if self.type == .profit {
            self.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_income_statement")
        } else if self.type == .asset {
            self.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_balance_sheet")
        } else {
            self.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_cash_flow_statement")
        }

        self.yearOnYearLabel.text = YXLanguageUtility.kLang(key: "year_on_year")

        var dataSourceArray: [String] = []
        
        isAStock = (market == YXMarketType.ChinaSH.rawValue || market == YXMarketType.ChinaSZ.rawValue)
        if type == .profit {
            if !isAStock {
                dataSourceArray = [YXLanguageUtility.kLang(key: "total_revenues"),
                               YXLanguageUtility.kLang(key: "gross_profit"),
                               YXLanguageUtility.kLang(key: "gross_margin"),
                               YXLanguageUtility.kLang(key: "ebitda"),
                               YXLanguageUtility.kLang(key: "ebitda_margin"),
                               YXLanguageUtility.kLang(key: "net_income"),
                               YXLanguageUtility.kLang(key: "net_income_margin"),
                               YXLanguageUtility.kLang(key: "roa"),
                               YXLanguageUtility.kLang(key: "roe"),
                               YXLanguageUtility.kLang(key: "eps")]
            } else {
                dataSourceArray = [YXLanguageUtility.kLang(key: "total_revenues"),
                                   YXLanguageUtility.kLang(key: "gross_profit"),
                                   YXLanguageUtility.kLang(key: "gross_margin"),
                                   YXLanguageUtility.kLang(key: "net_income"),
                                   YXLanguageUtility.kLang(key: "net_income_margin"),
                                   YXLanguageUtility.kLang(key: "roa"),
                                   YXLanguageUtility.kLang(key: "roe"),
                                   YXLanguageUtility.kLang(key: "eps")]
            }
        } else if type == .asset {
            dataSourceArray = [YXLanguageUtility.kLang(key: "total_current_assets"),
                               YXLanguageUtility.kLang(key: "total_current_liabilities"),
                               YXLanguageUtility.kLang(key: "current_ratio"),
                               YXLanguageUtility.kLang(key: "total_assets"),
                               YXLanguageUtility.kLang(key: "total_liabilities"),
                               YXLanguageUtility.kLang(key: "liabilities_ratio"),
                               YXLanguageUtility.kLang(key: "total_equity")]
        } else if type == .cashFlow {
            dataSourceArray = [YXLanguageUtility.kLang(key: "cash_from_operations"),
                               YXLanguageUtility.kLang(key: "cash_from_investing"),
                               YXLanguageUtility.kLang(key: "cash_from_financing"),
                               YXLanguageUtility.kLang(key: "net_change_in_cash")]
        }
        initUI(dataSourceArray)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    
    func initUI(_ dataSourceArray: [String]) {
     
        addSubview(self.titleLabel)
        addSubview(timeLabel)
        addSubview(arrowButton)
        addSubview(unitLabel)
        addSubview(self.popoverButton)

        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(20)
        }

        timeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(4)
            make.height.equalTo(20)
            make.trailing.lessThanOrEqualTo(arrowButton.snp.leading).offset(-10)
        }

        arrowButton.sizeToFit()
        arrowButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-11)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.height.equalTo(20)
            make.width.equalTo(arrowButton.width + 4)
        }

//        let lineview = UIView()
//        lineview.backgroundColor = UIColor.qmui_color(withHexString: "#E1E1E1")
//        addSubview(lineview)
//        lineview.snp.makeConstraints { (make) in
//            make.leading.equalToSuperview().offset(8)
//            make.trailing.equalToSuperview().offset(8)
//            make.height.equalTo(1)
//            make.top.equalTo(titleLabel.snp.bottom).offset(6)
//        }

        unitLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(14)
        }

        popoverButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(unitLabel)
            make.width.lessThanOrEqualTo(uniSize(100))
        }
        
        addSubview(self.yearOnYearLabel)
        yearOnYearLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-uniSize(113))
            make.centerY.equalTo(unitLabel)
            make.width.lessThanOrEqualTo(uniSize(70))
        }
        
        var preView: UIView = unitLabel
        for (index, str) in dataSourceArray.enumerated() {
            let cell = YXStockDetailFinanceListParameterView()
            addSubview(cell)
            parametersViewArray.append(cell)
            
            cell.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                if self.type == .cashFlow && (str == YXLanguageUtility.kLang(key: "cash_from_operations") || str ==
                    YXLanguageUtility.kLang(key: "cash_from_investing")) {
                    make.height.equalTo(58)
                } else {
                    make.height.equalTo(44)
                }
                if index == 0 {
                    make.top.equalTo(preView.snp.bottom).offset(4)
                } else {
                    make.top.equalTo(preView.snp.bottom)
                }
            }
            cell.titleLabel.text = str
            cell.yearOnYearLabel.text = "--"
            cell.yearReportLabel.text = "--"
            preView = cell
        }

        addSubview(self.emptyView)
        self.emptyView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.unitLabel.snp.bottom).offset(5)
        }

    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        return label
    }()

    lazy var unitLabel: QMUILabel = {
        let lab = QMUILabel()
        lab.text = YXLanguageUtility.kLang(key: "newStock_detail_stock_unit") +  ": --"
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textColor = QMUITheme().textColorLevel3()
        return lab
    }()
    
    lazy var yearOnYearLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = QMUITheme().textColorLevel3()
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()

    lazy var popoverButton: YXStockFinancialPopoverButton = {

        let button = YXStockFinancialPopoverButton()
        button.clickItemBlock = {
            [weak self] selectIndex in
            guard let `self` = self else { return }
            self.selectIndex = selectIndex
            self.clickItemBlock?(selectIndex)
        }
        return button
    }()
    
    lazy var arrowButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "market_more_arrow"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "see_detail"), for:  .normal)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.imagePosition = .right
        button.spacingBetweenImageAndTitle = 3
        button.contentHorizontalAlignment = .right
        //button.addTarget(self, action: #selector(arrowButtonAction), for: .touchUpInside)
        return button
    }()

    lazy var emptyView: YXStockEmptyDataView = {
        let view = YXStockEmptyDataView()
        view.isHidden = true
        if self.type == .profit {
            view.textLabel.text = YXLanguageUtility.kLang(key: "has_no_profit")
        } else if self.type == .asset {
            view.textLabel.text = YXLanguageUtility.kLang(key: "has_no_liability")
        } else {
            view.textLabel.text = YXLanguageUtility.kLang(key: "has_no_cash")
        }
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

}

class YXStockDetailFinanceListParameterView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        addSubview(titleLabel)
        addSubview(yearOnYearLabel)
        addSubview(yearReportLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.width.lessThanOrEqualTo(uniSize(180))
            make.top.bottom.equalToSuperview()
        }
        
        yearReportLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(uniSize(90))
        }
        
        yearOnYearLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-uniSize(113))
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(uniSize(70))
        }
        
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    lazy var yearOnYearLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var yearReportLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = QMUITheme().textColorLevel1()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        return label
    }()
}
