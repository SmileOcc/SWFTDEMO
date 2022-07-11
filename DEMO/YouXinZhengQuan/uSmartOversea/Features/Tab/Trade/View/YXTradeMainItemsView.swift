//
//  YXTradeMainItemsView.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/7.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeMainItemsView: UIView {
    typealias ClosureClick = () -> Void
    
    // 持仓点击事件
    @objc var onClickHoldStocks: ClosureClick?
    
    // 交易订单点击事件
    @objc var onClickOrders: ClosureClick?
    
    // 追踪订单点击事件
    @objc var onClickTracks: ClosureClick?
    
    // 持仓
    lazy var holdStocksBtn: QMUIButton = {
        let holdStocksBtn = QMUIButton()
        holdStocksBtn.imagePosition = .top
        holdStocksBtn.setTitle(YXLanguageUtility.kLang(key: "hold_holds"), for: .normal)
        holdStocksBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        holdStocksBtn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        holdStocksBtn.setImage(UIImage(named: "holdStocks"), for: .normal)
        holdStocksBtn.spacingBetweenImageAndTitle = 6
        holdStocksBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        holdStocksBtn.titleLabel?.minimumScaleFactor = 0.3
        return holdStocksBtn
    }()
    
    // 交易订单
    lazy var ordersBtn: QMUIButton = {
        let ordersBtn = QMUIButton()
        ordersBtn.imagePosition = .top
        ordersBtn.setTitle(YXLanguageUtility.kLang(key: "hold_orders"), for: .normal)
        ordersBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        ordersBtn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        ordersBtn.setImage(UIImage(named: "orders"), for: .normal)
        ordersBtn.spacingBetweenImageAndTitle = 6
        ordersBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        ordersBtn.titleLabel?.minimumScaleFactor = 0.3
        return ordersBtn
    }()
    
    // 追踪订单
    lazy var tracksBtn: QMUIButton = {
        let tracksBtn = QMUIButton()
        tracksBtn.imagePosition = .top
        tracksBtn.setTitle(YXLanguageUtility.kLang(key: "hold_tracks"), for: .normal)
        tracksBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        tracksBtn.setTitleColor(QMUITheme().textColorLevel1(), for: .normal)
        tracksBtn.setImage(UIImage(named: "tracks"), for: .normal)
        tracksBtn.spacingBetweenImageAndTitle = 6
        tracksBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        tracksBtn.titleLabel?.minimumScaleFactor = 0.3
        return tracksBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        self.addSubview(self.holdStocksBtn)
        self.addSubview(self.ordersBtn)
        self.addSubview(self.tracksBtn)
        
        let btns = [self.holdStocksBtn, self.ordersBtn, self.tracksBtn]
        btns.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        btns.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(56)
        }
        
        self.holdStocksBtn.addTarget(self, action: #selector(holdStocksAction(sender:)), for: .touchUpInside)
        
        self.ordersBtn.addTarget(self, action: #selector(ordersAction(sender:)), for: .touchUpInside)
        
        self.tracksBtn.addTarget(self, action: #selector(tracksAction(sender:)), for: .touchUpInside)
    }
    
    @objc func holdStocksAction(sender: UIButton) {
        if let closure = onClickHoldStocks {
            closure()
        }
    }
    
    @objc func ordersAction(sender: UIButton) {
        if let closure = onClickOrders {
            closure()
        }
    }
    
    @objc func tracksAction(sender: UIButton) {
        if let closure = onClickTracks {
            closure()
        }
    }
}
