//
//  YXStockWarrantsSortViewController.swift
//  uSmartOversea
//
//  Created by 井超 on 2019/8/5.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

class YXStockWarrantsSortViewController: YXHKViewController {
    
    var confirmCallBack: (([String: String])->Void)?
    
    var viewModel: YXStockWarrantsSortViewModel! = YXStockWarrantsSortViewModel()
    
    let sortView = YXWarrantsMoreSortView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = YXLanguageUtility.kLang(key: "warrants_sort")
        initUI()
    }
    
    func resetAll() {
        sortView.resetBtnAction()
    }
    
    func initUI() {
        
        //确定
        let confirmItem = UIBarButtonItem.qmui_item(withTitle: YXLanguageUtility.kLang(key: "common_confirm2"), target: self, action: nil)
        
        //确定 的响应
        sortView.confirmBlock = { [weak self] in
            guard let `self` = self else { return }
            
            let outstandingPctLow = Double(self.sortView.outstandingPctLowTextFld.text ?? "") ?? 0
            let outstandingPctHeigh = Double(self.sortView.outstandingPctHeightTextFld.text ?? "") ?? 0
            let exchangeRatioLow = Double(self.sortView.exchangeRatioLowTextFld.text ?? "") ?? 0
            let exchangeRatioHeight = Double(self.sortView.exchangeRatioHeightTextFld.text ?? "") ?? 0
            
            let recoveryPriceLow = Double(self.sortView.recoveryPriceLowTextFld.text ?? "") ?? 0
            let recoveryPriceHeight = Double(self.sortView.recoveryPriceHeightTextFld.text ?? "") ?? 0
            let extendedVolatilityLow = Double(self.sortView.extendedVolatilityLowTextFld.text ?? "") ?? 0
            let extendedVolatilityHeight = Double(self.sortView.extendedVolatilityHeightTextFld.text ?? "") ?? 0
            
            let window = UIApplication.shared.keyWindow
            
            if outstandingPctHeigh < outstandingPctLow {
                
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "warrants_strike_invalid"), in: window)
                return
            }
            
            if exchangeRatioHeight < exchangeRatioLow {
                
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "warrants_conversionRatio_invalid"), in: window)
                return
            }
            
            if recoveryPriceHeight < recoveryPriceLow {
                
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "warrants_call_level_invalid"), in: window)
                return
            }
            
            if extendedVolatilityHeight < extendedVolatilityLow {
                
                YXProgressHUD.showError(YXLanguageUtility.kLang(key: "warrants_volatility_invalid"), in: window)
                return
            }
            
            
            let dic = ["outstandingPctLow": self.sortView.outstandingPctLowTextFld.text ?? "",
             "outstandingPctHeight": self.sortView.outstandingPctHeightTextFld.text ?? "",
             "exchangeRatioLow": self.sortView.exchangeRatioLowTextFld.text ?? "",
             "exchangeRatioHeight": self.sortView.exchangeRatioHeightTextFld.text ?? "",
             "recoveryPriceLow": self.sortView.recoveryPriceLowTextFld.text ?? "",
             "recoveryPriceHeight": self.sortView.recoveryPriceHeightTextFld.text ?? "",
             "extendedVolatilityLow": self.sortView.extendedVolatilityLowTextFld.text ?? "",
             "extendedVolatilityHeight": self.sortView.extendedVolatilityHeightTextFld.text ?? "",
             "moneyness": "\(self.sortView.moneyness)",
             "leverageRatio": "\(self.sortView.leverageRatio)",
             "premium": "\(self.sortView.premium)",
             "outstandingRatio": "\(self.sortView.outstandingRatio)"
                ]
            
            if let callBack = self.confirmCallBack{
                callBack(dic)
            }
            
//            self.navigationController?.popViewController(animated: true)
            
        }
//        navigationItem.rightBarButtonItems = [confirmItem]
        
        view.addSubview(sortView)
        sortView.snp.makeConstraints { (make) in
            make.right.left.bottom.equalTo(view)
            make.top.equalTo(view)
        }
        
    }
    
}
