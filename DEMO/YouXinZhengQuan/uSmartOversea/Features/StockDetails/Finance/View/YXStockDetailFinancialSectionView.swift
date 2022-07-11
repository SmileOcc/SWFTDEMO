//
//  YXStockDetailFinancialSectionView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/7/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

enum YXStockDetailFinancialType {
    case profit
    case asset
    case cashFlow
}

let financialBlackColor = QMUITheme().themeTintColor()
let financialGreenColor = UIColor.qmui_color(withHexString: "#8D95FF") ?? UIColor.white
let financialRedColor = UIColor.qmui_color(withHexString: "#F9A800") ?? UIColor.white

//"营业收入"/"净利润"/"净利率"
class YXTitleValueView: UIView {
    
    var type: YXStockDetailFinancialType = .profit
    
    lazy var circleViews: [UIView] = {
        
        let colors = [financialBlackColor, financialGreenColor, financialRedColor]
        var views: [UIView] = []
        for x in 0..<3 {
            let view = UIView()
            view.backgroundColor = colors[x]
            view.layer.cornerRadius = 4.0
            view.layer.masksToBounds = true
            views.append(view)
        }
        return views
    }()
    
    lazy var titleLabels: [QMUILabel] = {
        var titles: [QMUILabel] = []
        for x in 0..<3 {
            let lab = QMUILabel()
            lab.text = ""
            lab.font = UIFont.systemFont(ofSize: 14)
            lab.textColor = QMUITheme().textColorLevel1()
            titles.append(lab)
        }
        return titles;
    }()
    
    lazy var valueLabels: [QMUILabel] = {
        
        var values: [QMUILabel] = []
        for x in 0..<3 {
            let lab = QMUILabel()
            lab.text = "--"
            lab.font = UIFont.systemFont(ofSize: 14)
            lab.textColor = QMUITheme().textColorLevel1()
            values.append(lab)
        }
        return values
    }()
    
    lazy var lineViews: [UIView] = {
        var lines: [UIView] = []
        for x in 0..<3 {
            let view = UIView()
            view.backgroundColor = QMUITheme().separatorLineColor()
            lines.append(view)
        }
        return lines
    }()
    
    
    convenience init(frame: CGRect, type: YXStockDetailFinancialType) {
        self.init(frame: frame)
        self.type = type
        initUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() -> Void {
        var titles = [String]()
        if self.type == .profit {
            titles = [YXLanguageUtility.kLang(key: "stock_detail_receipt"), YXLanguageUtility.kLang(key: "stock_detail_profits"), YXLanguageUtility.kLang(key: "stock_detail_profits_rate")]
        } else if self.type == .asset {
            titles = [YXLanguageUtility.kLang(key: "stock_detail_total_assets"), YXLanguageUtility.kLang(key: "stock_detail_total_liabilities"), YXLanguageUtility.kLang(key: "stock_detail_ratio_of_indebtedness")]
        } else {
            titles = [YXLanguageUtility.kLang(key: "stock_detail_operational_cash_flow"), YXLanguageUtility.kLang(key: "stock_detail_investing_cash_flow"), YXLanguageUtility.kLang(key: "stock_detail_financing_cash_flow")]
        }

        for x in 0..<3 {
            
            let circleView = circleViews[x]
            let titleLabel = titleLabels[x]
            let valueLabel = valueLabels[x]
            //let lineView = lineViews[x]
            
            titleLabel.text = titles[x]
            
            addSubview(circleView)
            addSubview(titleLabel)
            addSubview(valueLabel)
            //addSubview(lineView)
            
            circleView.snp.makeConstraints { (make) in
                make.centerY.equalTo(self.snp.top).offset(32 * x + 16)
                make.left.equalToSuperview().offset(16)
                make.width.height.equalTo(8)
            }
            titleLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(circleView.snp.centerY)
                make.left.equalTo(circleView.snp.right).offset(8)
            }
            valueLabel.snp.makeConstraints { (make) in
                make.centerY.equalTo(circleView.snp.centerY)
                make.right.equalToSuperview().offset(-16)
            }
//            lineView.snp.makeConstraints { (make) in
//                make.left.equalToSuperview().offset(13)
//                make.right.equalToSuperview().offset(-16)
//                make.bottom.equalTo(circleView.snp.centerY).offset(20)
//                make.height.equalTo(1)
//            }
            
        }
    }
}



class YXStockDetailFinancialSectionView: UIView {

    var type: YXStockDetailFinancialType = .profit
    
    var titleLabel: QMUILabel
    
    var vauleTitleView: YXTitleValueView!
    
    var chartView: YXStockDetailFinancialChartView!

    var clickItemBlock: ((_ selectIndex: Int) -> ())?
    
    var detailClosure: (() -> Void)?

    var selectIndex: Int = 0
    
    var isYear: Bool {
        didSet {
            self.chartView.isYear = self.isYear
        }
    }
    
    var HSIncomeData: YXHSFinancialData? {
        didSet {

            if HSIncomeData == nil {
                self.emptyView.isHidden = false
                return
            }
            self.emptyView.isHidden = true

            guard var list = self.HSIncomeData?.list else { return }
            
            var tempData: [YXFinancialDetailData]?
            tempData = []
            for m in list {
                let model = changeToFinancialDetailData(data: m)
                tempData!.append(model)
                if self.type == .profit {
                    if (model.operatingIncome ?? 0) == 999999.999999 {
                        model.operatingIncome = nil
                    }
                    if (model.netIncome ?? 0) == 999999.999999 {
                        model.netIncome = nil
                    }
                } else if self.type == .asset {
                    if (model.totalAssets ?? 0) == 999999.999999 {
                        model.totalAssets = nil
                    }
                    if (model.totalLiabilities ?? 0) == 999999.999999 {
                        model.totalLiabilities = nil
                    }
                } else {
                    if (model.cashFromOperations ?? 0) == 999999.999999 {
                        model.cashFromOperations = nil
                    }
                    if (model.cashFromInvesting ?? 0) == 999999.999999 {
                        model.cashFromInvesting = nil
                    }
                    if (model.cashFromFinancing ?? 0) == 999999.999999 {
                        model.cashFromFinancing = nil
                    }
                }
                
            }
            list.reverse()
            
            if self.type == .profit {
                if list.count > 0, let lastData = list.last {
                    let financialData = changeToFinancialDetailData(data: lastData)
                    for x in 0..<3 {
                        if x == 0 {
                            if let operatingIncome = financialData.operatingIncome {
                                self.vauleTitleView.valueLabels[0].text = YXToolUtility.stockData(Double(operatingIncome), deciPoint: 2, stockUnit: "", priceBase: 0)
                            } else {
                                self.vauleTitleView.valueLabels[0].text = "--"
                            }
                        } else if x == 1 {
                            if let netIncome = financialData.netIncome {
                                self.vauleTitleView.valueLabels[1].text = YXToolUtility.stockData(Double(netIncome), deciPoint: 2, stockUnit: "", priceBase: 0)
                            } else {
                                self.vauleTitleView.valueLabels[1].text = "--"
                            }
                        } else {
                            if let retainedProfitsRate = lastData.retainedProfitsRate {
                                self.vauleTitleView.valueLabels[2].text = String(format: "%.2lf%@", retainedProfitsRate, "%")
                            } else if let operatingIncome = financialData.operatingIncome, let netIncome = financialData.netIncome, operatingIncome != 0 {
                                self.vauleTitleView.valueLabels[2].text = String(format: "%.2lf%@", netIncome / operatingIncome * 100.0, "%")
                            } else {
                                self.vauleTitleView.valueLabels[2].text = "--"
                            }
                        }
                    }
                    self.chartView.incomeData = YXFinancialData.init(list: tempData)
                }
            } else if self.type == .asset {
                
                if list.count > 0, let lastData = list.last {
                    let financialData = changeToFinancialDetailData(data: lastData)
                    for x in 0..<3 {
                        if x == 0 {
                            if let totalAssets = financialData.totalAssets {
                                self.vauleTitleView.valueLabels[0].text = YXToolUtility.stockData(Double(totalAssets), deciPoint: 2, stockUnit: "", priceBase: 0)
                            } else {
                                self.vauleTitleView.valueLabels[0].text = "--"
                            }
                        } else if x == 1 {
                            if let totalLiabilities = financialData.totalLiabilities {
                                self.vauleTitleView.valueLabels[1].text = YXToolUtility.stockData(Double(totalLiabilities), deciPoint: 2, stockUnit: "", priceBase: 0)
                            } else {
                                self.vauleTitleView.valueLabels[1].text = "--"
                            }
                        } else {
                            if let totalLiabilitiesRate = lastData.totalLiabilitiesRate {
                                self.vauleTitleView.valueLabels[2].text = String(format: "%.2lf%@", totalLiabilitiesRate, "%")
                            } else if  let totalAssets = financialData.totalAssets, let totalLiabilities = financialData.totalLiabilities, totalAssets != 0 {
                                self.vauleTitleView.valueLabels[2].text = String(format: "%.2lf%@", totalLiabilities / totalAssets * 100.0, "%")
                            } else {
                                self.vauleTitleView.valueLabels[2].text = "--"
                            }
                        }
                    }
                    self.chartView.balanceData = YXFinancialData.init(list: tempData)
                }
            } else {
                
                if list.count > 0, let lastData = list.last {
                    let financialData = changeToFinancialDetailData(data: lastData)
                    for x in 0..<3 {
                        if x == 0 {
                            if let cashFromOperations = financialData.cashFromOperations {
                                self.vauleTitleView.valueLabels[0].text = YXToolUtility.stockData(Double(cashFromOperations), deciPoint: 2, stockUnit: "", priceBase: 0)
                            } else {
                                self.vauleTitleView.valueLabels[0].text = "--"
                            }
                        } else if x == 1 {
                            if let cashFromInvesting = financialData.cashFromInvesting {
                                self.vauleTitleView.valueLabels[1].text = YXToolUtility.stockData(Double(cashFromInvesting), deciPoint: 2, stockUnit: "", priceBase: 0)
                            } else {
                                self.vauleTitleView.valueLabels[1].text = "--"
                            }
                        } else {
                            if let cashFromFinancing = financialData.cashFromFinancing {
                                self.vauleTitleView.valueLabels[2].text = YXToolUtility.stockData(Double(cashFromFinancing), deciPoint: 2, stockUnit: "", priceBase: 0)
                            } else {
                                self.vauleTitleView.valueLabels[2].text = "--"
                            }
                        }
                    }
                    
                    self.chartView.cashFlow = YXFinancialData.init(list: tempData)
                }
            }
            
            //單位
            self.chartView.unitLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_stock_unit") + ": " + self.getUnitStr() + " " + (list.last?.currName ?? "")


            if let reportPeriod = list.last?.reportPeriod {
              
                let endDate = YXDateHelper.commonDateString(reportPeriod)
                self.timeLabel.text = "(\(endDate))"
            } else {
                self.timeLabel.text = ""
            }
        }
    }
    
    var incomeData: YXFinancialData? {
        didSet {

            if incomeData == nil {
                self.emptyView.isHidden = false
                return
            }
            self.emptyView.isHidden = true

            guard var list = self.incomeData?.list else { return }
        
            for model in list {
                if self.type == .profit {
                    if (model.operatingIncome ?? 0) == 999999.999999 {
                        model.operatingIncome = nil
                    }
                    if (model.netIncome ?? 0) == 999999.999999 {
                        model.netIncome = nil
                    }
                } else if self.type == .asset {
                    if (model.totalAssets ?? 0) == 999999.999999 {
                        model.totalAssets = nil
                    }
                    if (model.totalLiabilities ?? 0) == 999999.999999 {
                        model.totalLiabilities = nil
                    }
                } else {
                    if (model.cashFromOperations ?? 0) == 999999.999999 {
                        model.cashFromOperations = nil
                    }
                    if (model.cashFromInvesting ?? 0) == 999999.999999 {
                        model.cashFromInvesting = nil
                    }
                    if (model.cashFromFinancing ?? 0) == 999999.999999 {
                        model.cashFromFinancing = nil
                    }
                }
                
            }
            list.reverse()
            
            if self.type == .profit {
                if list.count > 0, let financialData = list.last {
                    for x in 0..<3 {
                        if x == 0 {
                            if let operatingIncome = financialData.operatingIncome {
                                self.vauleTitleView.valueLabels[0].text = YXToolUtility.stockData(Double(operatingIncome * 1000000), deciPoint: 2, stockUnit: "", priceBase: 0)
                            } else {
                                self.vauleTitleView.valueLabels[0].text = "--"
                            }
                        } else if x == 1 {
                            if let netIncome = financialData.netIncome {
                                self.vauleTitleView.valueLabels[1].text = YXToolUtility.stockData(Double(netIncome * 1000000), deciPoint: 2, stockUnit: "", priceBase: 0)
                            } else {
                                self.vauleTitleView.valueLabels[1].text = "--"
                            }
                        } else {
                            if let operatingIncome = financialData.operatingIncome, let netIncome = financialData.netIncome, operatingIncome != 0 {
                                self.vauleTitleView.valueLabels[2].text = String(format: "%.2lf%@", netIncome / operatingIncome * 100.0, "%")
                            } else {
                                self.vauleTitleView.valueLabels[2].text = "--"
                            }
                        }
                    }
                    self.chartView.incomeData = self.incomeData
                }
            } else if self.type == .asset {
                
                if list.count > 0, let financialData = list.last {
                    for x in 0..<3 {
                        if x == 0 {
                            if let totalAssets = financialData.totalAssets {
                                self.vauleTitleView.valueLabels[0].text = YXToolUtility.stockData(Double(totalAssets * 1000000), deciPoint: 2, stockUnit: "", priceBase: 0)
                            } else {
                                self.vauleTitleView.valueLabels[0].text = "--"
                            }
                        } else if x == 1 {
                            if let totalLiabilities = financialData.totalLiabilities {
                                self.vauleTitleView.valueLabels[1].text = YXToolUtility.stockData(Double(totalLiabilities * 1000000), deciPoint: 2, stockUnit: "", priceBase: 0)
                            } else {
                                self.vauleTitleView.valueLabels[1].text = "--"
                            }
                        } else {
                            if  let totalAssets = financialData.totalAssets, let totalLiabilities = financialData.totalLiabilities, totalAssets != 0 {
                                self.vauleTitleView.valueLabels[2].text = String(format: "%.2lf%@", totalLiabilities / totalAssets * 100.0, "%")
                            } else {
                                self.vauleTitleView.valueLabels[2].text = "--"
                            }
                        }
                    }
                    self.chartView.balanceData = self.incomeData
                }
            } else {
                
                if list.count > 0, let financialData = list.last {
                    for x in 0..<3 {
                        if x == 0 {
                            if let cashFromOperations = financialData.cashFromOperations {
                                self.vauleTitleView.valueLabels[0].text = YXToolUtility.stockData(Double(cashFromOperations * 1000000), deciPoint: 2, stockUnit: "", priceBase: 0)
                            } else {
                                self.vauleTitleView.valueLabels[0].text = "--"
                            }
                        } else if x == 1 {
                            if let cashFromInvesting = financialData.cashFromInvesting {
                                self.vauleTitleView.valueLabels[1].text = YXToolUtility.stockData(Double(cashFromInvesting * 1000000), deciPoint: 2, stockUnit: "", priceBase: 0)
                            } else {
                                self.vauleTitleView.valueLabels[1].text = "--"
                            }
                        } else {
                            if let cashFromFinancing = financialData.cashFromFinancing {
                                self.vauleTitleView.valueLabels[2].text = YXToolUtility.stockData(Double(cashFromFinancing * 1000000), deciPoint: 2, stockUnit: "", priceBase: 0)
                            } else {
                                self.vauleTitleView.valueLabels[2].text = "--"
                            }
                        }
                    }
                    self.chartView.cashFlow = self.incomeData
                }
            }
            
            //單位
            self.chartView.unitLabel.text = YXLanguageUtility.kLang(key: "newStock_detail_stock_unit") + ": " + self.getUnitStr() + " " + (list.last?.currName ?? "")

            if let endDate = list.last?.endDate {
                if endDate.count > 10 {
                    let dateString = endDate.replacingOccurrences(of: "-", with: "")
                    self.timeLabel.text = "(" + YXDateHelper.commonDateString(dateString) + ")"
                } else {
                    self.timeLabel.text = "(\(endDate))"
                }
            } else {
                self.timeLabel.text = ""
            }

        }
    }
    
    convenience init(frame: CGRect, type: YXStockDetailFinancialType) {
        self.init(frame: frame)
        self.type = type
        initUI()

        chartView.clickItemBlock = {
            [weak self] selectIndex in
            guard let `self` = self else { return }
            self.selectIndex = selectIndex
            self.clickItemBlock?(selectIndex)
        }
    }
    
    override init(frame: CGRect) {
        self.titleLabel = QMUILabel.init()
        self.titleLabel.textColor = QMUITheme().textColorLevel1()
        self.titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        self.isYear = true
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        if self.type == .profit {
            self.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_revenues")
        } else if self.type == .asset {
            self.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_assets_and_liabilities")
        } else {
            self.titleLabel.text = YXLanguageUtility.kLang(key: "stock_detail_cashFlow")
        }
        
        self.vauleTitleView = YXTitleValueView.init(frame: .zero, type: self.type)
        self.chartView = YXStockDetailFinancialChartView.init(frame: .zero, type: self.type)
        
        addSubview(self.titleLabel)
        addSubview(timeLabel)
        addSubview(self.chartView)
        addSubview(self.vauleTitleView)
        addSubview(arrowButton)
        
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
            make.width.equalTo(arrowButton.frame.width + 4)
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
        
        chartView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.height.equalTo(228)
        }
        
        vauleTitleView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(chartView.snp.bottom)
            make.height.equalTo(96)
        }

        addSubview(self.emptyView)
        self.emptyView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(self.chartView.snp.top).offset(30)
            make.bottom.equalToSuperview()
        }
    }
    
    func getUnitStr() -> String {
        var str = ""
        switch self.chartView.unitTpe {
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
    
    func changeToFinancialDetailData(data: YXHSFinancialDetailData) -> YXFinancialDetailData {
        
        let model = YXFinancialDetailData.init()
        model.operatingIncome = data.totalRevenues
        model.netIncome = data.retainedProfits
        model.currName = data.currName
        model.fiscalYear = Int(data.year ?? "")
        model.calendarYear = Int(data.year ?? "")
        model.currUnit = "0"
        model.totalAssets = data.totalAssets
        model.totalLiabilities = data.totalLiabilities
        model.cashFromOperations = data.operationsCash
        model.cashFromInvesting = data.investingCash
        model.cashFromFinancing = data.financingCash
        model.retainedProfitsRate = data.retainedProfitsRate
        model.totalLiabilitiesRate = data.totalLiabilitiesRate
        model.isHS = true
        return model
    }
    
    lazy var arrowButton: YXExpandAreaButton = {
        let button = YXExpandAreaButton()
        button.setImage(UIImage(named: "market_more_arrow"), for: .normal)
        button.setTitle(YXLanguageUtility.kLang(key: "see_detail"), for:  .normal)
        button.setTitleColor(QMUITheme().textColorLevel2(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.imagePosition = .right
        button.spacingBetweenImageAndTitle = 3
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(arrowButtonAction), for: .touchUpInside)
        return button
    }()
    
    @objc func arrowButtonAction() {
        self.detailClosure?()
    }

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

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = QMUITheme().textColorLevel2()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        return label
    }()
}
