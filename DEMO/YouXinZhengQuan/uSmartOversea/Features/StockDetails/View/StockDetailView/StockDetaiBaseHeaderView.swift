//
//  StockDetaiBaseHeaderView.swift
//  uSmartOversea
//
//  Created by 陈明茂 on 2022/6/7.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class StockDetaiBaseHeaderView: UIView {
            
    var heightChangeCallBack: ((_ animate: Bool, _ height: CGFloat) -> ())?
    var logosPopView: YXStockDetailTopLogosPopView?
    
    var quoteModel: YXV2Quote? {
        didSet {
            self.nameView.quoteModel = quoteModel
            self.parameterView.quoteModel = quoteModel
            self.statusView.quoteModel = quoteModel
        }
    }
    
    private var isShowParameter = false
    private let knameViewHeight: CGFloat = 98
    private var totalHeight: CGFloat = 98 {
        didSet {
            if oldValue != totalHeight {
                heightChangeCallBack?(true, totalHeight)
            }
        }
    }

    lazy var nameView: YXStockDetailNameView = {
        let view = YXStockDetailNameView()


        
        view.subQuoteView.tapCallBack = { [weak self] in
            guard let `self` = self else { return }
            // 取反
            self.isShowParameter = !self.isShowParameter
            self.showOrHideParameterView(with: true)
        }
        
        return view
    }()
    
    lazy var parameterView: YXStockDetailParameterView = {
        let view = YXStockDetailParameterView()
        view.parameterHeightBlock = { [weak self] height, animate in
            self?.showOrHideParameterView(with: animate)
        }
        
        return view
    }()
    
    lazy var statusView: StockDetailHeaderTimeView = {
        let view = StockDetailHeaderTimeView()
        
        view.lablesView.clickClosure = {
            [weak self] quote in
            guard let `self` = self else { return }
            
            if self.isShowParameter {
                self.isShowParameter = false
                self.showOrHideParameterView(with: false)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    self.showPop()
                }
            } else {
                self.showPop()
            }
        }
        
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
        
        backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(nameView)
        addSubview(parameterView)
        addSubview(statusView)
                
        nameView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(60)
        }
        
        parameterView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(nameView.snp.bottom)
            make.height.equalTo(0)
        }
        
        statusView.snp.makeConstraints { make in
            make.top.equalTo(parameterView.snp.bottom)
            make.height.equalTo(38)
            make.left.right.equalToSuperview()
        }
    }
    
    func showOrHideParameterView(with animate: Bool) {
        self.nameView.subQuoteView.isShowParameter = self.isShowParameter
        
        let parameterViewH = self.isShowParameter ? self.parameterView.contentHeight : 0
        parameterView.snp.updateConstraints { make in
            make.height.equalTo(parameterViewH)
        }
        
        if animate {
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
        } else {
            
        }
        self.totalHeight = parameterViewH + knameViewHeight
    }
    
    
    func hidePop() {
        self.logosPopView?.hideSheetView()
        self.logosPopView = nil
    }
    
    func showPop() {
        if self.logosPopView?.superview != nil {
            self.logosPopView?.hideSheetView()
            return
        }
        let sheetView = YXStockDetailTopLogosPopView()
        sheetView.quote = self.quoteModel

        sheetView.showFromView(self.statusView.lablesView)
        sheetView.itemClickBlock = {
             (type, quote) in
//            guard let `self` = self else { return }
            guard let market = quote?.market else { return }
            guard let symbol = quote?.symbol else { return }
            if type == .userLevel {
                
                var url = YXH5Urls.myQuotesUrl()
                if market == kYXMarketHK {
                    url = YXH5Urls.YX_MY_QUOTES_URL(tab: 2)
                } else if market == kYXMarketUS {
                    url = YXH5Urls.YX_MY_QUOTES_URL(tab: 1)
                }
                YXWebViewModel.pushToWebVC(url)
                
            } else if type == .shortSell {
                //occ测试数据
                let desc1 = "Short Selling Margin Ratio 10%, is the short margin ratio for short selling  this stock."
                let desc2 = "Short Int. Rate 3.29% ,means the interest rate of your borrowed stock."
                let desc3 = "Maximum Short Selling Quantity 15,800 SHR, the quantity left that this stock can be short sell."
                
                let alertView = YXAlertView(title: "", message: desc1 + "\n" + desc2 + "\n" + desc3)
                alertView.addAction(YXAlertAction(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: { [weak alertView] (_) in
                    alertView?.hide()
                }))
                
                alertView.showInWindow()
            }

        }
        self.logosPopView = sheetView
    }
}
