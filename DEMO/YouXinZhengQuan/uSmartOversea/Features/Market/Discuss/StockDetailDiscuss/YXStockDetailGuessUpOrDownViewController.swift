//
//  StockDetailGuessUpOrDownSectionController.swift
//  uSmartOversea
//
//  Created by lennon on 2022/5/26.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit

class YXStockDetailGuessUpOrDownCell: UICollectionViewCell {
    
    var tapAction: ((_ direction:Bool, _ state: Bool) -> Void)?

    
    var model: YXStockDetailGuessUpOrDownInfo? {
        didSet {
            guard let model = model else { return }
            guessUpOrDownView.model = model
        }
    }
    
    lazy var guessUpOrDownView: StockDetailGuessUpOrDownView = {
        let view = StockDetailGuessUpOrDownView()
        view.tapAction = { [weak self] direction, state in
            guard let `self` = self else { return }
            self.tapAction?(direction,state)
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
        
        let bgView = UIView.init()
        bgView.backgroundColor = QMUITheme().foregroundColor()
        
        contentView.addSubview(bgView)
        contentView.addSubview(guessUpOrDownView)
        
        guessUpOrDownView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
}

class YXStockDetailGuessUpOrDownViewController: ListSectionController {
 
    private var object: YXStockDetailGuessUpOrDownInfo?
    
    @objc var market = ""
    
    @objc var name = ""
    
    @objc var refreshData: (()->())?

    override func numberOfItems() -> Int {
        return 1
    }

    override func sizeForItem(at index: Int) -> CGSize {
        
        return CGSize.init(width: collectionContext!.containerSize.width, height: 140)
        
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {

        let guessIndexCell: YXStockDetailGuessUpOrDownCell = collectionContext.dequeueReusableCell(for: self, at: index)

        guessIndexCell.model = object


        guessIndexCell.tapAction = { [weak self] direction, state  in
            self?.tapAction(isUp: direction, isSelected: state)
        }
        
        
        return guessIndexCell
    }
    
    override func didUpdate(to object: Any) {
        self.object = object as? YXStockDetailGuessUpOrDownInfo
    }
    
    func tapAction(isUp: Bool, isSelected: Bool) {
        if YXUserManager.isLogin() {
            
            guard let model = self.object,let market = model.market else {
                return
            }
            let symbol = model.code ?? ""
            var h5Str = ""
            var value = ""
            if isUp {
                h5Str = "1"
                value = "1"
            } else {
                h5Str = "-1"
                value = "0"
            }
            
            var type = ""
            if market == kYXMarketHK {
                type =  "warrant"
            } else if market == kYXMarketUS {
                type = "option"
            } else if market == kYXMarketSG {
                type = "0"
            }
            
            let context = YXWebViewModel(dictionary: [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.guessUpOrDownUrl(market: market, symbol: symbol, type: type, upOrDown: h5Str)
            ])
            YXSquareManager.getTopService()?.push(YXModulePaths.webView.url, context: context)
            
            if !isSelected {
                let requestModel = YXGuessUpAndDownUserGuessReqModel.init()
                requestModel.market = market
                requestModel.guessChange = value
                requestModel.code = symbol

                let request = YXRequest.init(request: requestModel)
                
                let hud = YXProgressHUD.showLoading("")
                request.startWithBlock(success: { response in
                    hud.hideHud()
                    guard response.code == .success else {
                        if let msg = response.msg, msg.count > 0 {
                            hud.showError(msg)
                        }
                        return
                    }
                    self.refreshData?()
                    
                }, failure: { request in
                    hud.hideHud()
                    hud.showError(YXLanguageUtility.kLang(key: "network_failed"))
                })
            }

        } else {
            YXToolUtility.handleBusinessWithLogin {
                
            }
        }
    }
}
