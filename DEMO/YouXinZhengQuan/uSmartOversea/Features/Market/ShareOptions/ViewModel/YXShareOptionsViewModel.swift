//
//  YXShareOptionsViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/11/23.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift

enum YXShareOptionsType:Int {
    case all = 0
    case call
    case put
    
    var title: String {
        switch self {
        case .all:
            return YXLanguageUtility.kLang(key: "options_all_options")
        case .call:
            return YXLanguageUtility.kLang(key: "optiojns_call")
        case .put:
            return YXLanguageUtility.kLang(key: "optiojns_put")
        }
    }
    
    var key: String {
        switch self {
        case .call:
            return "callItem"
        case .put:
            return "putItem"
        default:
            return ""
        }
    }
}

enum YXShareOptionsShowStyle {
    case inMarket
    case inStockDetail
}

enum YXShareOptionsListStyle:Int {
    case straddleStyle = 0  //T型号
    case listStyle = 1      //列表
    
    var title: String {
        switch self {
        case .straddleStyle:
            return YXLanguageUtility.kLang(key: "option_straddle_style")
        case .listStyle:
            return YXLanguageUtility.kLang(key: "option_list")
        }
    }
}



class YXShareOptionsViewModel: YXViewModel {
    //列表风格
    public static let ListStyleKey =  "ListStyleKey"
    //列表数量
    public static let StrikeKey =  "StrikeKey"
    
    var style: YXShareOptionsShowStyle = .inMarket
    
    var listStyle:YXShareOptionsListStyle = .straddleStyle
    
    var currentOptinosCount: YXShareOptinosCount = .ten {
        didSet {
            allVM.currentOptinosCount = currentOptinosCount
            callVM.currentOptinosCount = currentOptinosCount
            putVM.currentOptinosCount = currentOptinosCount
        }
    }
    
    var market: String = "" {
        didSet {
            allVM.market = market
            callVM.market = market
            putVM.market = market
        }
    }
    var symbol: String = "" {
        didSet {
            allVM.symbol = symbol
            callVM.symbol = symbol
            putVM.symbol = symbol
        }
    }
    var dateModel: YXShareOptionsDateResModel?
    
    @objc var tapCellAction: ((_ market: String, _ code: String) -> Void)?
    
    lazy var allVM: YXShareOptionsListViewModel = {
        let vm = YXShareOptionsListViewModel.init(services: services, params: ["market": market, "code": symbol])
        vm.tapCellAction = tapCellAction
        vm.optionsType = .all
        vm.currentOptinosCount = currentOptinosCount
        return vm
    }()
    
    lazy var callVM: YXShareOptionsListViewModel = {
        let vm = YXShareOptionsListViewModel.init(services: services, params: ["market": market, "code": symbol])
        vm.tapCellAction = tapCellAction
        vm.optionsType = .call
        vm.currentOptinosCount = currentOptinosCount
        return vm
    }()
    
    lazy var putVM: YXShareOptionsListViewModel = {
        let vm = YXShareOptionsListViewModel.init(services: services, params: ["market": market, "code": symbol])
        vm.tapCellAction = tapCellAction
        vm.optionsType = .put
        vm.currentOptinosCount = currentOptinosCount
        return vm
    }()
    
    lazy var allVC: YXShareOptionsListViewController = {
        return YXShareOptionsListViewController.init(viewModel: allVM)
    }()
    
    lazy var callVC: YXShareOptionsListViewController = {
        return YXShareOptionsListViewController.init(viewModel: callVM)
    }()
    
    lazy var putVC: YXShareOptionsListViewController = {
        return YXShareOptionsListViewController.init(viewModel: putVM)
    }()
    
    
    lazy var allNewListVC: ShareOptionNewListViewController = {
        return ShareOptionNewListViewController.init(viewModel: allVM)
    }()
    
    lazy var callNewListVC: ShareOptionNewListViewController = {
        return ShareOptionNewListViewController.init(viewModel: callVM)
    }()
    
    lazy var putNewListVC: ShareOptionNewListViewController = {
        return ShareOptionNewListViewController.init(viewModel: putVM)
    }()
    
    
    func getDate() -> (Single<Any?>) {
        let single = Single<Any?>.create { single in
            
            let requestModel = YXShareOptionsDateReqModel()
            requestModel.market = self.market
            requestModel.code = self.symbol
            
            let request = YXRequest.init(request: requestModel)
            let loadingHud = YXProgressHUD.showLoading("")
            request.startWithBlock(success: { [weak self](response) in
                loadingHud.hide(animated: true)
                
                if response.code == YXResponseStatusCode.success {
                    self?.dateModel = YXShareOptionsDateResModel.yy_model(withJSON: response.data ?? [:])
                    single(.success(self?.dateModel))
                }else {
                    single(.success(nil))
                }

            }, failure: { (request) in
                single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
            })
            
            return Disposables.create()
        }
        
        return single
    }
    
    override init(services: YXViewModelServices, params: [AnyHashable : Any]?) {
        super.init(services: services, params: params)
        
        if let market = params?["market"] as? String {
            self.market = market
        }
        
        if let symbol = params?["code"] as? String {
            self.symbol = symbol
        }
        
        let defaultStyle = MMKV.default().int32(forKey: YXShareOptionsViewModel.ListStyleKey, defaultValue: 0)
        
        let style = YXShareOptionsListStyle.init(rawValue:Int(defaultStyle)) ?? YXShareOptionsListStyle.straddleStyle
        listStyle = style
        
        let defaultStrike = MMKV.default().int32(forKey: YXShareOptionsViewModel.StrikeKey, defaultValue: 1)
        let strike = YXShareOptinosCount.init(rawValue: Int(defaultStrike)) ?? .ten
        currentOptinosCount = strike
        
        
    }
}
