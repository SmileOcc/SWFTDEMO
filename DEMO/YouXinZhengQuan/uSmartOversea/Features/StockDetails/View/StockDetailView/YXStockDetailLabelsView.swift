//
//  YXStockDetailLabelsView.swift
//  YouXinZhengQuan
//
//  Created by youxin on 2020/9/28.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

extension QuoteLevel {
    func stockDetailImageName(with market: String) -> String {
        switch self {
        case .delay:
            return "stock_detail_L0"
        case .level1:
            if market == kYXMarketUS {
                return "stock_detail_nsdq"
            } else if market == kYXMarketUsOption {
                return "stock_detail_usoption"
            }
            return "stock_detail_L1"
        case .level2:
            return "stock_detail_L2"
        case .bmp:
            return "stock_detail_bmp"
        case .usNational:
            return "stock_detail_usnation"
        default:
            return "stock_detail_L0"
        }
    }
}

class YXStockDetailLabelsView: UIView {

    var labelsArray: [UIView] = []

    @objc var clickClosure: ((YXV2Quote?) -> Void)?

    @objc var quote: YXV2Quote? {
        didSet {

            for view in labelsArray {
                view.removeFromSuperview()
            }
            labelsArray.removeAll()

            if let quoteModel = quote {

                if let market = quoteModel.market {
                    //市场
                    let imagePrefix = "stock_detail_"
                    var imageName: String = market.lowercased()
                    if market == kYXMarketUsOption {
                        imageName = kYXMarketUS.lowercased()
                    }

                    let marketImageView = self.createImageView(imagePrefix + imageName)
                    labelsArray.append(marketImageView)
                }

                /*
                if YXStockDetailOCTool.hkCanTradeSH(quoteModel) || YXStockDetailOCTool.hkCanTradeSZ(quoteModel) || YXStockDetailOCTool.szCanTradeHK(quoteModel) ||
                    YXStockDetailOCTool.shCanTradeHK(quoteModel) {
                    let dayMarginLabel = self.creatLabel(text: "通", backgroundColor:  QMUITheme().themeTextColor())
                    labelsArray.append(dayMarginLabel)
                }
                 

                //是否是日内融股票
                if quoteModel.dailyMargin?.value == true {
                    let dayMarginLabel = self.creatLabel(text: "DM", backgroundColor: UIColor.qmui_color(withHexString: "#FF7127") ?? QMUITheme().themeTextColor())
                    labelsArray.append(dayMarginLabel)
                }
                 */
                
                //是否是融资股票
                if YXConstant.appTypeValue == .OVERSEA{
                    if YXUserManager.isBrokerLogin() {
                        if YXStockDetailTool.isFinancingStock(quoteModel) {
                            let marginImageView = self.createImageView("stock_detail_margin")
                            labelsArray.append(marginImageView)
                        }
                    }
                } else if YXConstant.appTypeValue == .OVERSEA_SG{
                    if YXStockDetailTool.isFinancingStock(quoteModel) {
                            let marginImageView = self.createImageView("stock_detail_margin")
                            labelsArray.append(marginImageView)
                        }
                }
                
                
                //行情权限
                do {
                    
                    if YXUserManager.shared().getHighestUsaThreeLevel() == .delay && YXStockDetailOCTool.isUSIndex(quoteModel){
                        //美股三大指数无权限时不显示
                    }else{
                        var level: QuoteLevel = .delay
                        if let tempLevel = QuoteLevel(rawValue: Int(quoteModel.level?.value ?? 0)) {
                            level = tempLevel
                        }
                        
                        let levelImageView = self.createImageView(level.stockDetailImageName(with: self.quote?.market ?? ""))
                        labelsArray.append(levelImageView)
                    }
                }
                
                //occ测试数据 支持做空的美股
//                if let shortSellFlag = quoteModel.shortSellFlag?.value, shortSellFlag,
//                let market = quoteModel.market, market == kYXMarketUS {
                    let shortSellLabel = self.creatLabel(text: "空", backgroundColor: UIColor.qmui_color(withHexString: "#FFBA00") ?? QMUITheme().themeTextColor())
                    labelsArray.append(shortSellLabel)
//                }
                
                /*
                //是否是卖空股票
                if let shortSellFlag = quoteModel.shortSellFlag?.value, shortSellFlag,
                let market = quoteModel.market, market == kYXMarketUS {
                    let shortSellLabel = self.creatLabel(text: "空", backgroundColor: UIColor.qmui_color(withHexString: "#FFBA00") ?? QMUITheme().themeTextColor())
                    labelsArray.append(shortSellLabel)
                }

                //是否是港股ETF, 美股ETN 反向杠杆倍数
                if labelsArray.count < 5, let lever = quoteModel.lever?.value, lever != 0,
                   let type3 = quoteModel.type3?.value, (type3 == OBJECT_SECUSecuType3.stEtf.rawValue || type3 == OBJECT_SECUSecuType3.stFundUsEtn.rawValue) {

                    let lever = quote?.lever?.value ?? 0
                    let valueString = String(format: "%@%dx", lever > 0 ? "+" : "", lever)

                    let leverLabel = self.creatLabel(text: valueString, backgroundColor: UIColor.qmui_color(withHexString: "#FF7127") ?? QMUITheme().themeTextColor())
                    labelsArray.append(leverLabel)
                }
                */
        

                let count = labelsArray.count;
                for (index, label) in labelsArray.reversed().enumerated() {
                    self.containerView.addSubview(label)
                    label.snp.makeConstraints { (make) in
                        make.width.height.equalTo(14)
                        make.centerY.equalToSuperview()
                        make.right.equalToSuperview().offset(-CGFloat(14 * index + 4 * index))
                        if index == count - 1 {
                            make.left.equalToSuperview()
                        }
                    }

                }
            }

        }
    }

    func createImageView(_ imageName: String) -> UIImageView {
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: imageName)
        return imageView
    }


    func creatLabel(text: String, backgroundColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.backgroundColor = backgroundColor
        label.layer.cornerRadius = 2.0
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 10)
        label.adjustsFontSizeToFitWidth = true
        return label;
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()

        let tap = UITapGestureRecognizer.init { [weak self] (ges) in
            guard let `self` = self else { return }
            self.clickClosure?(self.quote)
        }

        self.containerView.addGestureRecognizer(tap)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI() {

        self.backgroundColor = QMUITheme().foregroundColor()
        addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.height.equalTo(22)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(5)
        }

    }

    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()


}

