//
//  YXStockDetailHeaderView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/12/11.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXStockDetailHeaderView: UIView {

    var quoteModel: YXV2Quote? {
        didSet {                        
            extraQuoteView.quoteModel = quoteModel

            chartView.quoteModel = quoteModel
                        
            if chartView.accessoryView.quoteModel == nil {
                chartView.accessoryView.quoteModel = quoteModel
            }
            
            //美股指数隐藏提示
            if let model = quoteModel, quoteModel?.type1?.value == OBJECT_SECUSecuType1.stIndex.rawValue, model.market == kYXMarketUS {
                if YXToolUtility.needFinishQuoteNotify() {
                    quoteStatementShadeView.isHidden = false
                }else if !YXUserManager.isOpenAccount(broker: YXBrokersBitType.sg) {
                    stockIndexShadeView.isHidden = false
                } else {
                    stockIndexShadeView.isHidden = true
                }
            } else {
                stockIndexShadeView.isHidden = true
            }
        }
    }


    var updateHeightBlock: ((_ height: CGFloat) -> Void)?
    //adr, ah视图点击回调
    var tapBlock: ((_ market: String, _ symbol: String) -> Void)?
    //筹码分布回调
    var cyqRequestBlock: ((_ interval: UInt64) -> Void)?

    //视图总高度
    var totalHeight: CGFloat {
        var total: CGFloat = 0
        for subview in self.subviews {
            if let view = subview as? YXStockDetailBaseView {
                total += view.contentHeight
            }
        }
        // 加上分时图和盘口的间隙12
        total += 8
        return total
    }

    var klineViewExternHeight: CGFloat = 0
    var klineViewHeight: CGFloat {
        330 + klineViewExternHeight
    }

    var market: String = kYXMarketHK

    //处理视图 手势或按钮事件 回调
    func handleBlock() {
        //盘口数据
        handleParameterBlock()
        //分时，K线
        handleChartBlock()
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name(rawValue: "YX_Noti_UpdateUserInfo"))
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { [weak self] noti in
                guard let `self` = self else { return }
                if !YXToolUtility.needFinishQuoteNotify() && self.quoteStatementShadeView.isHidden == false {
                    self.quoteStatementShadeView.isHidden = true
                }
            }).disposed(by: rx.disposeBag)
    }

    //MARK: initUI
    init(frame: CGRect, market: String) {
        super.init(frame: frame)
        self.market = market
        initUI()
        handleBlock()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    //MARK: 布局子视图
    func initUI() {
        backgroundColor = QMUITheme().backgroundColor()
                
        addSubview(extraQuoteView)
      
        extraQuoteView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(0)
        }

        addSubview(usQuoteTipView)
        usQuoteTipView.snp.makeConstraints { (make) in
            make.top.equalTo(extraQuoteView.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
        
        addSubview(chartView)
        self.chartView.contentHeight = self.klineViewHeight
        chartView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(usQuoteTipView.snp.bottom)
            make.height.equalTo(self.chartView.contentHeight)
        }
        
        addSubview(stockIndexShadeView)
        stockIndexShadeView.snp.makeConstraints { (make) in
            make.edges.equalTo(chartView)
        }

        addSubview(quoteStatementShadeView)
        quoteStatementShadeView.snp.makeConstraints { (make) in
            make.edges.equalTo(chartView)
        }
    }

    //MARK: 懒加载视图

    lazy var extraQuoteView: StockdetailExtraQuoteView = {
        let view = StockdetailExtraQuoteView()
        
        view.heightDidChange = { [weak self] in
            guard let `self` = self else { return }
            
            var height = self.extraQuoteView.mj_h
            if height > 0 {
                height = height + 8
            }
            
            self.extraQuoteView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            self.extraQuoteView.contentHeight = height
            self.updateHeightBlock?(self.totalHeight)
        }
        return view
    }()
    
    //美股行情引导
    lazy var usQuoteTipView: USQuoteGuideView = {
        let view = USQuoteGuideView.init()
        view.isHidden = true
        view.contentHeight = 0
        return view
    }()
    

    //K线、分时图表
    lazy var chartView: YXStockDetailLineView = {
        let view = YXStockDetailLineView(frame: CGRect.zero, market: self.market, isLand: false)
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()

    //毛玻璃
    lazy var stockIndexShadeView: YXStockIndexAccessoryShadeView = {
        let view = YXStockIndexAccessoryShadeView()
        view.isHidden = true
        view.setButtonType(.OPENACCOUNTBUTTON)
        view.setLandscape(false)
        return view
    }()
    
    lazy var quoteStatementShadeView: YXStockIndexAccessoryShadeView = {
        let view = YXStockIndexAccessoryShadeView()
        view.isHidden = true
        view.setButtonType(.QUOTESTATEMENTBUTTON)
        view.setLandscape(false)
        return view
    }()
}


//MARK: 额外行情相关
extension YXStockDetailHeaderView {

    fileprivate func handleParameterBlock() {
        extraQuoteView.tapBlock = {
            [weak self] (market, symbol) in
            guard let `self` = self else { return }
            self.tapBlock?(market, symbol)
        }

//        parameterView.parameterHeightBlock = {
//            [weak self, weak parameterView] (height, animated) in
//            guard let `self` = self, let `parameterView` = parameterView else { return }
//            parameterView.snp.updateConstraints { (make) in
//                make.height.equalTo(height)
//            }
//            self.parameterView.contentHeight = height
//            if animated {
//                UIView.animate(withDuration: 0.225) {
//                    self.layoutIfNeeded()
//                }
//            }
//
//            self.updateHeightBlock?(self.totalHeight)
//
//        }
    }
}

//MARK: 分时，K线相关
extension YXStockDetailHeaderView {

    //update market
    fileprivate func handleChartBlock() {

        self.chartView.updateExternHeightBlock = { [weak self] externHeight in
            guard let `self` = self else { return }

            self.klineViewExternHeight = externHeight
            self.chartView.contentHeight = self.klineViewHeight
            self.chartView.snp.updateConstraints { (make) in
                make.height.equalTo(self.klineViewHeight)
            }

            self.updateHeightBlock?(self.totalHeight)
        }

        self.chartView.setCurrentLineTypeHeight()
    }

    
}

//MARK: 美股行情提示
extension YXStockDetailHeaderView {
    
    func updateUsQuoteTipView() {
        
        var height: CGFloat = 0
        if let model = quoteModel, model.market == kYXMarketUS, !YXUserManager.isLogin() {
            usQuoteTipView.isHidden = false
            height = 92
        } else {
            usQuoteTipView.isHidden = true
            height = 0
        }
        
        if usQuoteTipView.contentHeight != height {
            usQuoteTipView.contentHeight = height
            usQuoteTipView.snp.updateConstraints { (make) in
                make.height.equalTo(height)
            }
            self.updateHeightBlock?(self.totalHeight);
        }
    }
}

