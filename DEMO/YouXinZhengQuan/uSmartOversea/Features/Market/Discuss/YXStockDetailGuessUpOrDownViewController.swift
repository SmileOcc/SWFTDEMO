//
//  YXStockDetailGuessUpOrDownViewController.swift
//  YouXinZhengQuan
//
//  Created by lennon on 2021/9/16.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import IGListKit
import IGListSwiftKit

class YXStockDetailGuessUpOrDownCell: UICollectionViewCell {
    
    var model: YXStockDetailGuessUpOrDownInfo? {
        didSet {
            guard let model = model else { return }
            
            if let guessChange = model.guessChange?.intValue {
                if guessChange == 0 {
                    guessButton.guessDownButton.isSelected = true
                    guessButton.guessUpButton.isSelected = false
                } else {
                    guessButton.guessDownButton.isSelected = false
                    guessButton.guessUpButton.isSelected = true
                }
            } else {
                guessButton.guessDownButton.isSelected = false
                guessButton.guessUpButton.isSelected = false
            }
            
            if let upCount = model.upCount?.intValue, let downCount = model.downCount?.intValue {
                let up = Double(upCount)
                let down = Double(downCount)
                let total = up + down
                if total > 0 {
                    let upRatio = up / total
                    let downRatio = down / total
                    ratioView.upRatioLabel.text = String(format: "%.2lf%%", upRatio*100.0)
                    ratioView.downRatioLabel.text = String(format: "%.2lf%%", downRatio*100.0)
                    
                    let w = YXConstant.screenWidth/2.0 - 36.0;
                    ratioView.upGradientLayer.frame = CGRect.init(x: 0, y: 0, width: w * CGFloat(upRatio), height: 4)
                    ratioView.downGradientLayer.frame = CGRect.init(x: ratioView.upGradientLayer.frame.width-5, y: 0, width: w * CGFloat(downRatio)+7, height: 4)
                }
            }
        }
    }
    var tapUpAction: ((_ isSelect: Bool) -> Void)?
    var tapDownAction: ((_ isSelect: Bool) -> Void)?
    
    lazy var ratioView: YXGuessRatioView = {
        let view = YXGuessRatioView()
        return view
    }()
    
    lazy var guessButton: YXGuessButtonView = {
        let view = YXGuessButtonView()
        _ = view.guessUpButton.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.tapUpAction?(self.model?.guessChange != nil)
        })
        _ = view.guessDownButton.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.tapDownAction?(self.model?.guessChange != nil)
        })
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
        bgView.addSubview(ratioView)
        bgView.addSubview(guessButton)
        
        bgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(13)
            make.right.equalToSuperview().offset(-13)
            make.top.equalToSuperview().offset(11)
            make.bottom.equalToSuperview().offset(-11)
        }
        
        guessButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(160)
            make.centerY.equalToSuperview()
            make.height.equalTo(28)
        }
        
        ratioView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.right.equalTo(guessButton.snp.left).offset(-16)
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
        
        return CGSize.init(width: collectionContext!.containerSize.width, height: 62)
        
    }

    override func cellForItem(at index: Int) -> UICollectionViewCell {

        let guessIndexCell: YXStockDetailGuessUpOrDownCell = collectionContext.dequeueReusableCell(for: self, at: index)

        guessIndexCell.model = object
        
        guessIndexCell.tapUpAction = { [weak self] isSelect in
            self?.tapAction(isUp: true, isSelected: isSelect)
        }
        
        guessIndexCell.tapDownAction = { [weak self] isSelect in
            self?.tapAction(isUp: false, isSelected: isSelect)
        }
        
        return guessIndexCell
    }
    
    override func didUpdate(to object: Any) {
        self.object = object as? YXStockDetailGuessUpOrDownInfo
    }
    
    func tapAction(isUp: Bool, isSelected: Bool) {
        if YXUserManager.isLogin() {

            let symbol = self.object?.symbol ?? ""
            var value = ""
            if isUp {
                value = "1"
            } else {
                value = "0"
            }            
         
            if !isSelected {
                let requestModel = YXGuessUpAndDownUserGuessReqModel.init()

                if self.market == kYXMarketHK {
                    requestModel.market = "0"
                } else if self.market == kYXMarketUsOption {
                    requestModel.market = "51"
                } else if self.market == kYXMarketUS {
                    requestModel.market = "5"
                } else if self.market == kYXMarketChinaSH {
                    requestModel.market = "6"
                } else if self.market == kYXMarketChinaSZ {
                    requestModel.market = "7"
                }
                requestModel.guessChange = value
                requestModel.stockCode = symbol

                let request = YXRequest.init(request: requestModel)
                request.startWithBlock(success: { response in
                    guard response.code == .success else { return }
//                        self.collectionContext.invalidateLayout(for: self, completion: nil)
//                        self.refreshData?()
                }, failure: { request in

                })
                
                let text = isUp ? YXLanguageUtility.kLang(key: "guess_rise_content") : YXLanguageUtility.kLang(key: "guess_fall_content")
                let createPostModel = YXCreatePostRequestModel.init()
                createPostModel.content = "$" + self.name + "(\(symbol.uppercased()).\(market.uppercased()))" + "$ " + text
                createPostModel.stock_id_list = ["\(market)\(symbol)"]
                let createPostRequest = YXRequest.init(request: createPostModel)

                let hud = YXProgressHUD.showLoading("")

                createPostRequest.startWithBlock(success: { response in
                    guard response.code == .success else { return }
                    hud.hide(animated: true)
                    self.collectionContext.invalidateLayout(for: self, completion: nil)
                    self.refreshData?()

                }, failure: { request in
                    hud.hide(animated: true)

                })
            }

        } else {
            YXToolUtility.handleBusinessWithLogin(nil)
        }
    }
}
