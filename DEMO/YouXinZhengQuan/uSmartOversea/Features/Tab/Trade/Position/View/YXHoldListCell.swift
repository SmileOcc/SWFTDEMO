//
//  YXHoldListCell.swift
//  YouXinZhengQuan
//
//  Created by ellison on 2019/1/15.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class YXHoldListCell: YXTableViewCell, HasDisposeBag {
    
    lazy var stockInfoView: YXStockBaseinfoView = {
        let view = YXStockBaseinfoView()
        return view
    }()
    
    lazy var marketValueLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.baselineAdjustment = .alignCenters
        label.textAlignment = .right
        return label
    }()
    
    @objc lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isUserInteractionEnabled = false
        scrollView.delegate = self
        return scrollView
    }()
    
    lazy var marketNumberLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    lazy var priceLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.font = .systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.textAlignment = .right
        label.baselineAdjustment = .alignCenters;
        return label
    }()
    
    lazy var costLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    lazy var profitLabel: YXPreOrderView = {
        let label = YXPreOrderView(frame: .zero)
        return label
    }()
    
    lazy var profitPercentLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel3()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()

    private lazy var gradientView: UIImageView = {
        let view = UIImageView.holdGradient()
        view.isHidden = true
        return view
    }()

    fileprivate lazy var moneyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,##0.00";
        formatter.locale = Locale(identifier: "zh")
        return formatter;
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func initialUI() {
        super.initialUI()
        self.selectionStyle = .none
        backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(stockInfoView)
        
        contentView.addSubview(scrollView)
        contentView.addGestureRecognizer(scrollView.panGestureRecognizer)
        scrollView.addSubview(profitLabel)
        scrollView.addSubview(marketValueLabel)
        scrollView.addSubview(marketNumberLabel)
        scrollView.addSubview(priceLabel)
        scrollView.addSubview(costLabel)
        scrollView.addSubview(profitLabel)
        scrollView.addSubview(profitPercentLabel)

        contentView.addSubview(gradientView)

        scrollView.snp.makeConstraints { (make) in
            make.left.equalTo(138)
            make.top.bottom.right.equalTo(self)
        }

        gradientView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(scrollView)
            make.width.equalTo(23)
        }
        
        stockInfoView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(16)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(115)
        }
        
//        lineView.snp.makeConstraints { (make) in
//            make.left.right.bottom.equalTo(self)
//            make.height.equalTo(1)
//        }

        var width: CGFloat = 80
        let spacing: CGFloat = 15
        var left: CGFloat = 0
        
        marketValueLabel.frame   = CGRect(x: 0, y: 10, width: width, height: 20)
        marketNumberLabel.frame = CGRect(x: 0, y: 30, width: width, height: 15)

        left += width
        left += spacing
        
        priceLabel.frame  = CGRect(x: left, y: 10, width: width, height: 20)
        costLabel.frame = CGRect(x: left, y: 30, width: width, height: 15)

        left += width
        left += spacing

        if YXUserManager.isENMode() {
            width = 100;
        } else {
            width = 80;
        }
        profitLabel.frame = CGRect(x: left, y: 10, width: width, height: 20)
        profitPercentLabel.frame = CGRect(x: left, y: 30, width: width, height: 15)

        left += width
        left += 16

        scrollView.contentSize = CGSize(width: left, height: height)
    }

    override func refreshUI() {
        super.refreshUI()
        if let model = model as? YXAccountAssetHoldListItem { // 股票
            stockInfoView.nameLabel.text = model.stockName ?? "--"
            stockInfoView.symbolLabel.text = model.stockCode ?? "--"
            stockInfoView.market = model.exchangeType ?? "--"

            stockInfoView.moneyTypeLabel.isHidden = model.exchangeType?.lowercased() != YXMarketType.SG.rawValue
            stockInfoView.moneyTypeLabel.text = model.moneyType

            if let level = model.level,
               level == .delay,
               model.exchangeType != YXMarketType.USOption.rawValue {
                stockInfoView.delayLabel.isHidden = false
            } else {
                stockInfoView.delayLabel.isHidden = true
            }
            
            marketValueLabel.text = "--"
            if let marketValue = model.marketValue, let formatString = moneyFormatter.string(from: marketValue) {
                marketValueLabel.text = formatString
            }
            
            marketNumberLabel.text = "--"
            if let currentAmount = model.currentAmount {
                marketNumberLabel.text = countFormatter.string(from: currentAmount)
            }
            
            priceLabel.text = "--"
            if let price = model.lastPrice {
                priceLabel.text = quotePriceFormatter.string(from: price)
            }

            costLabel.text = "--"
            if let price = model.startPrice {
                costLabel.text = priceFormatter.string(from: price)
            }
            
            profitLabel.textColor = QMUITheme().textColorLevel1()
            profitPercentLabel.textColor = QMUITheme().textColorLevel1()
            profitLabel.textLabel.text = "--"
//            if (model.exchangeType == YXExchangeType.us.rawValue && (model.sessionType == 1 || model.sessionType == 2)){ //是美股
//                profitLabel.sessionType = model.sessionType
//                todayProfitLabel.sessionType = model.sessionType
//            }else{
//                profitLabel.sessionType = 0
//                todayProfitLabel.sessionType = 0
//            }

            var op = ""
            if let profit = model.holdingBalance {
                let doubleValue = profit.doubleValue
                if doubleValue > 0 {
                    op = "+"
                    profitLabel.textColor = QMUITheme().stockRedColor()
                    profitPercentLabel.textColor = QMUITheme().stockRedColor()
                } else if doubleValue < 0 {
                    profitLabel.textColor = QMUITheme().stockGreenColor()
                    profitPercentLabel.textColor = QMUITheme().stockGreenColor()
                } else {
                    profitLabel.textColor = QMUITheme().stockGrayColor()
                    profitPercentLabel.textColor = QMUITheme().stockGrayColor()
                }

                if let formatString = moneyFormatter.string(from: profit) {
                    profitLabel.textLabel.text = op + formatString
                }
            }

            profitPercentLabel.text = "--"
            if let doubleValue = model.holdingBalancePercent?.doubleValue {
                profitPercentLabel.text = op + String(format: "%.2f%%", doubleValue * 100)
            }
        }
    }

    fileprivate lazy var countFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal;
        formatter.groupingSize = 3;
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 4
        return formatter;
    }()

    fileprivate lazy var quotePriceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal;
        formatter.groupingSeparator = ""
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 3
        return formatter;
    }()

    fileprivate lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal;
        formatter.groupingSeparator = ""
        formatter.maximumFractionDigits = 4
        return formatter;
    }()
}

extension YXHoldListCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gradientView.isHidden = scrollView.contentOffset.x <= 0
    }
}
