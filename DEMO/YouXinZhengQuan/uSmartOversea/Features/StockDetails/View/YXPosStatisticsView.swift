//
//  YXPosStatisticsView.swift
//  uSmartOversea
//
//  Created by chenmingmao on 2022/2/14.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

class YXPosStatisticsView: UIView, YXStockDetailHeaderViewProtocol {
    
    var heightDidChange: (() -> Void)?
    
    var clickItemBlock: ((_ selectIndex: Int) -> Void)?
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    @objc var tapBlock: ((_ priceString: String?, _ number: NSNumber?) -> Void)? {
        didSet {
            depthOrderView.tapBlock = tapBlock
            askBidView.tapBlock = tapBlock
        }
    }
    
    ///这个方法只在改变的时候更新.订阅的数据不用传进来
    var quote: YXV2Quote? {
        didSet {
            guard let quote = quote else { return }
            guard let market = quote.market else { return }
            
            let stockType = quote.stockType
            let type2 = OBJECT_SECUSecuType2(rawValue: Int32(quote.type2?.value ?? 0)) ?? .none
            let isGrey = (quote.greyFlag?.value ?? 0) > 0
                        
            // 买卖档的显示
            let isShowAskBid = !(stockType == .stIndex || stockType == .stSector || type2 == .stLowAdr)
            self.askBidView.market = market
            self.askBidView.isHidden = !isShowAskBid
            if isGrey {
                self.askBidView.hideTen = true
            }
            
            // 经纪商的显示
            var isShowBroker = false
            if YXStockDetailTool.isShowAskBid(quote) && market == YXMarketType.HK.rawValue && !isGrey {
                if YXUserManager.hkLevel() == .hkLevel1 {
                    isShowBroker = false
                } else {
                    isShowBroker = true
                }
                
            }
            self.brokerView.isHidden = !isShowBroker
            
            // 深度摆盘的显示
            var isShowDepth = false
            if YXStockDetailTool.showDepthOrder(quote) {
                isShowDepth = true
            }
            self.depthOrderView.isHidden = !isShowDepth
            self.depthOrderView.isSgMarket = market == kYXMarketSG
            
            print("YXPosStatisticsView  进来刷新数据")
        }
        
        
    }
    
    /// 更新盘口数据
    var posBroker: PosBroker? {
        didSet {
            guard let posBroker = posBroker else { return }
            if posBroker.pos != nil {
                self.askBidView.posBroker = posBroker
            }
            if posBroker.brokerData != nil {
                self.brokerView.posBroker = posBroker
            }
            if self.depthOrderView.isHidden == false {
                self.depthOrderView.posBroker = posBroker
            }
        }
    }

    //买卖档
    lazy var askBidView: YXStockDetailAskBidView = {
        let view = YXStockDetailAskBidView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.isHidden = true
        
        view.usPosButton.clickItemBlock = { [weak self] type in
            self?.clickItemBlock?(type)
            self?.askBidView.usNationTipView.posQuoteType = YXStockDetailUtility.getUsAskBidSelect()
        }
        return view
    }()

    //买卖档经纪商
    lazy var brokerView: YXHKStockDetailBrokerView = {
        let view = YXHKStockDetailBrokerView()
        view.backgroundColor = QMUITheme().foregroundColor()
        view.number = 5
        view.isHidden = true
        return view
    }()

    
    //深度摆盘视图
    lazy var depthOrderView: YXStockDetailDepthTradeView = {
        let view = YXStockDetailDepthTradeView(frame: .zero, isTrade: false)
        view.backgroundColor = QMUITheme().foregroundColor()
        view.contentHeight = view.totalHeight
        view.isHidden = true
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {

        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.addArrangedSubview(askBidView)
        stackView.addArrangedSubview(brokerView)
        stackView.addArrangedSubview(depthOrderView)
        
        configStackView()
    }
    
    func updatePosBrokerData(_ posBroker: PosBroker) {
        if posBroker.pos != nil {
            askBidView.posBroker = posBroker
        }
        if posBroker.brokerData != nil {
            brokerView.posBroker = posBroker
        }
        if self.depthOrderView.isHidden == false {
            self.depthOrderView.posBroker = posBroker
        }
    }
}
