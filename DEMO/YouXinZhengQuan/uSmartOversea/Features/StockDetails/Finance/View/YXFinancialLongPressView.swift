//
//  YXFinancialLongPressView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2019/8/27.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXFinancialLongPressView: UIView {

    let titleLabel = UILabel.init(with: QMUITheme().textColorLevel1(), font: .systemFont(ofSize: 12, weight: .medium), text: "--")
    let firstTitle = UILabel.init(with: QMUITheme().textColorLevel2(), font: .systemFont(ofSize: 10), text: "--")
    let secondTitle = UILabel.init(with: QMUITheme().textColorLevel2(), font: .systemFont(ofSize: 10), text: "--")
    let thirdTitle = UILabel.init(with: QMUITheme().textColorLevel2(), font: .systemFont(ofSize: 10), text: "--")
    
    let firstValue = UILabel.init(with: QMUITheme().textColorLevel1(), font: .systemFont(ofSize: 10), text: "--")
    let secondValue = UILabel.init(with: QMUITheme().textColorLevel1(), font: .systemFont(ofSize: 10), text: "--")
    let thirdValue = UILabel.init(with: QMUITheme().textColorLevel1(), font: .systemFont(ofSize: 10), text: "--")

    @objc var currentTitle: String = YXLanguageUtility.kLang(key: "financial_report_quarter_4")
    
    var type: YXStockDetailFinancialType = .profit
    @objc var market: String = YXMarketType.HK.rawValue
    var isYear = true
    @objc var marketType: YXStockFinancialMarketType = .ROE {
        didSet {
            var str = YXLanguageUtility.kLang(key: "per_share_cash_flow")
            if self.market.hasPrefix(YXMarketType.ChinaSH.rawValue) || self.market.hasPrefix(YXMarketType.ChinaSZ.rawValue) {
                str = YXLanguageUtility.kLang(key: "per_share_operating_cash_flow")
            }
            let arr = ["ROE(%)", "ROA(%)", "PE", "PB", "EPS", YXLanguageUtility.kLang(key: "per_share_net_assets"), str, YXLanguageUtility.kLang(key: "per_share_revenue")]
            let title = arr[marketType.rawValue]
            secondTitle.isHidden = false
            secondValue.isHidden = false

            thirdTitle.isHidden = true
            thirdValue.isHidden = true

            secondTitle.text = YXLanguageUtility.kLang(key: "yoy_growth_rate")
            firstTitle.text = title
        }

    }
    
    var model: YXFinancialDetailData? {
        didSet {
            if self.isYear {
                if let year = self.model?.fiscalYear {
                    self.titleLabel.text = "\(year)" + self.currentTitle
                } else {
                    self.titleLabel.text = "--" + self.currentTitle
                }                
            } else {
                if let year = self.model?.calendarYear, let quarter = self.model?.calendarQuarter {
                    self.titleLabel.text = "\(year)" + "Q" + "\(quarter)"
                } else {
                    self.titleLabel.text = "--"
                }
            }
            
            var unit: Float64 = 1000000
            if (model?.isHS ?? false) {
                unit = 1
            }
            
            switch self.type {
            case .profit:
                if let first = self.model?.operatingIncome {
                    firstValue.text = YXToolUtility.stockData(first * unit, deciPoint: 2, stockUnit: "", priceBase: 0)
                } else {
                    firstValue.text = "--"
                }
                if let second = self.model?.netIncome {
                    secondValue.text = YXToolUtility.stockData(second * unit, deciPoint: 2, stockUnit: "", priceBase: 0)
                } else {
                    secondValue.text = "--"
                }

                if let rate = model?.retainedProfitsRate, rate > 0 {
                    thirdValue.text = String.init(format: "%.2f", rate) + "%"
                } else if let first = self.model?.operatingIncome, let second = self.model?.netIncome, first != 0 {
                    thirdValue.text = String.init(format: "%.2f", second / first * 100) + "%"
                } else {
                    thirdValue.text = "--"
                }
            case .asset:
                if let first = self.model?.totalAssets {
                    firstValue.text = YXToolUtility.stockData(first * unit, deciPoint: 2, stockUnit: "", priceBase: 0)
                } else {
                    firstValue.text = "--"
                }
                if let second = self.model?.totalLiabilities {
                    secondValue.text = YXToolUtility.stockData(second * unit, deciPoint: 2, stockUnit: "", priceBase: 0)
                } else {
                    secondValue.text = "--"
                }
                if let rate = model?.totalLiabilitiesRate, rate > 0 {
                    thirdValue.text = String.init(format: "%.2f", rate) + "%"
                } else if let first = self.model?.totalAssets, let second = self.model?.totalLiabilities, first != 0 {
                    thirdValue.text = String.init(format: "%.2f", second / first * 100) + "%"
                } else {
                    thirdValue.text = "--"
                }
            case .cashFlow:
                if let first = self.model?.cashFromOperations {
                    firstValue.text = YXToolUtility.stockData(first * unit, deciPoint: 2, stockUnit: "", priceBase: 0)
                } else {
                    firstValue.text = "--"
                }
                if let second = self.model?.cashFromInvesting {
                    secondValue.text = YXToolUtility.stockData(second * unit, deciPoint: 2, stockUnit: "", priceBase: 0)
                } else {
                    secondValue.text = "--"
                }
                if let third = self.model?.cashFromFinancing {
                    thirdValue.text = YXToolUtility.stockData(third * unit, deciPoint: 2, stockUnit: "", priceBase: 0)
                } else {
                    thirdValue.text = "--"
                }
            }
        }
    }

    @objc var marketModel: YXFinancialMarketDetaiModel? {
        didSet {
            if let year = self.marketModel?.year {

                self.titleLabel.text =  "\(year)" + self.currentTitle
            } else {
                self.titleLabel.text = "--" + self.currentTitle
            }
            switch self.marketType {
                case .ROE:
                    if let value = self.marketModel?.roe_annual {
                        firstValue.text = String(format: "%.02f", value)
                    } else {
                        firstValue.text = "--"
                    }

                    if let value = self.marketModel?.roe_annual_yoy {
                        secondValue.text = String(format: "%.02f%%", value * 100)
                    } else {
                        secondValue.text = "--"
                    }
                case .ROA:
                    if let value = self.marketModel?.roa_annual {
                        firstValue.text = String(format: "%.02f", value)
                    } else {
                        firstValue.text = "--"
                    }

                    if let value = self.marketModel?.roa_annual_yoy {
                        secondValue.text = String(format: "%.02f%%", value * 100)
                    } else {
                        secondValue.text = "--"
                    }
                case .PE:
                    if let value = self.marketModel?.pe_annual {
                        firstValue.text = String(format: "%.02f", value)
                    } else {
                        firstValue.text = "--"
                    }

                    if let value = self.marketModel?.pe_annual_yoy {
                        secondValue.text = String(format: "%.02f%%", value * 100)
                    } else {
                        secondValue.text = "--"
                    }
                case .PB:
                    if let value = self.marketModel?.pb_annual {
                        firstValue.text = String(format: "%.02f", value)
                    } else {
                        firstValue.text = "--"
                    }

                    if let value = self.marketModel?.pb_annual_yoy {
                        secondValue.text = String(format: "%.02f%%", value * 100)
                    } else {
                        secondValue.text = "--"
                    }
                case .EPS:
                    if let value = self.marketModel?.eps_annual {
                        firstValue.text = String(format: "%.02f", value)
                    } else {
                        firstValue.text = "--"
                    }

                    if let value = self.marketModel?.eps_annual_yoy {
                        secondValue.text = String(format: "%.02f%%", value * 100)
                    } else {
                        secondValue.text = "--"
                    }
                case .BPS:
                    if let value = self.marketModel?.bps_annual {
                        firstValue.text = String(format: "%.02f", value)
                    } else {
                        firstValue.text = "--"
                    }

                    if let value = self.marketModel?.bps_annual_yoy {
                        secondValue.text = String(format: "%.02f%%", value * 100)
                    } else {
                        secondValue.text = "--"
                    }
                case .OCFPS:
                    if let value = self.marketModel?.ocfps_annual {
                        firstValue.text = String(format: "%.02f", value)
                    } else {
                        firstValue.text = "--"
                    }

                    if let value = self.marketModel?.ocfps_annual_yoy {
                        secondValue.text = String(format: "%.02f%%", value * 100)
                    } else {
                        secondValue.text = "--"
                    }
                case .GRPS:
                    if let value = self.marketModel?.grps_annual {
                        firstValue.text = String(format: "%.02f", value)
                    } else {
                        firstValue.text = "--"
                    }

                    if let value = self.marketModel?.grps_annual_yoy {
                        secondValue.text = String(format: "%.02f%%", value * 100)
                    } else {
                        secondValue.text = "--"
                    }
                default:
                break
            }
        }
    }
    
    init(frame: CGRect, type: YXStockDetailFinancialType) {
        super.init(frame: frame)
        self.type = type
        initUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        self.layer.backgroundColor = QMUITheme().foregroundColor().cgColor
        
        if !YXThemeTool.isDarkMode() {
            self.layer.shadowColor = QMUITheme().textColorLevel3().withAlphaComponent(0.25).cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 1)
            self.layer.shadowOpacity = 1.0
            self.layer.shadowRadius = 4.0
        }
        
        backgroundColor = QMUITheme().popupLayerColor()
        switch self.type {
        case .profit:
            firstTitle.text = YXLanguageUtility.kLang(key: "stock_detail_receipt")
            secondTitle.text = YXLanguageUtility.kLang(key: "stock_detail_profits")
            thirdTitle.text = YXLanguageUtility.kLang(key: "stock_detail_profits_rate")
        case .asset:
            firstTitle.text = YXLanguageUtility.kLang(key: "stock_detail_total_assets")
            secondTitle.text = YXLanguageUtility.kLang(key: "stock_detail_total_liabilities")
            thirdTitle.text = YXLanguageUtility.kLang(key: "stock_detail_ratio_of_indebtedness")
        case .cashFlow:
            firstTitle.text = YXLanguageUtility.kLang(key: "stock_detail_operational_cash_flow")
            secondTitle.text = YXLanguageUtility.kLang(key: "stock_detail_investing_cash_flow")
            thirdTitle.text = YXLanguageUtility.kLang(key: "stock_detail_financing_cash_flow")
        }
        
        addSubview(titleLabel)
        addSubview(firstTitle)
        addSubview(firstValue)
        addSubview(secondTitle)
        addSubview(secondValue)
        addSubview(thirdTitle)
        addSubview(thirdValue)
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(14)
        }
        firstTitle.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.height.equalTo(12)
        }
        secondTitle.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(firstTitle.snp.bottom).offset(8)
            make.height.equalTo(12)
        }
        thirdTitle.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(secondTitle.snp.bottom).offset(8)
            make.height.equalTo(12)
        }
        
        firstValue.snp.makeConstraints { (make) in
            make.height.equalTo(12)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalTo(firstTitle)
        }
        
        secondValue.snp.makeConstraints { (make) in
            make.height.equalTo(12)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalTo(secondTitle)
        }
        
        thirdValue.snp.makeConstraints { (make) in
            make.height.equalTo(12)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalTo(thirdTitle)
        }
    }


}
