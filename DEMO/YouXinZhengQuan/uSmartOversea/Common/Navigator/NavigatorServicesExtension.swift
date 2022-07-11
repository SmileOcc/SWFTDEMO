//
//  YXNavigatorMapExtension.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/12/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import URLNavigator

extension NavigatorServices {
    
    @objc func pushToDayMarginSearchList(market: String, didSelectedSearchItem: @escaping ((YXSearchItem) -> Void)) {
        
        let market = YXMarketType.init(rawValue: market) ?? .HK
        
        let dic = ["market": market, "rankType": YXRankType.dailyFunding, "uiStyle": YXFinancingUIStyle.search, "didSelectedSearchItemBlock": didSelectedSearchItem] as [String: Any]
        push(YXModulePaths.financingList.url, context: dic)
    }
    
    
    /// 跳转到股票搜索页面 OC ---> Swift
    @objc func presentToTradeSearch(mkts: [String]? = nil, showPopular: Bool = true, showLike: Bool = true, showHistory: Bool = true, didSelectedItem:((YXSearchItem)->())?) {
        
        let type1Arr = [
            "\(OBJECT_SECUSecuType1.stStock.rawValue)",
            //"\(OBJECT_SECUSecuType1.stBond.rawValue)",
            "\(OBJECT_SECUSecuType1.stFund.rawValue)",
            "\(OBJECT_SECUSecuType1.stFuture.rawValue)",
            "\(OBJECT_SECUSecuType1.stOption.rawValue)"
        ]
        let searchParam = YXSearchParam(q: nil, markets: mkts, type1: type1Arr, type2: nil, type3: nil, size: nil)

        let types = mkts?.map{ YXSearchType(rawValue: $0) } ?? YXSearchType.allCases
        let dic: [String : Any] = [
            "param" : searchParam,
            "showPopular": showPopular,
            "showHistory": showHistory,
            "showLike": showLike,
            "types": types
        ]

        let nv = present(YXModulePaths.search.url, context: dic, animated: false) as? YXNavigationController

        if let vc = nv?.qmui_rootViewController as? YXNewSearchViewController {
            vc.didSelectedItem = {[weak vc] (item:YXSearchItem) in
                if let vc = vc {
                    vc.dismiss(animated: true, completion: nil)
                }
                if let didSelected = didSelectedItem {
                    didSelected(item)
                }
            }
        }
    }
    
    @objc func presentToSearch(showLike: Bool = true, showHistory: Bool = true, didSelectedItem:((YXSearchItem)->())?) {
        let dic: [String : Any] = [
            "showPopular": true,
            "showLike": showLike,
            "showHistory": showHistory,
        ]

        let nv = present(YXModulePaths.search.url, context: dic, animated: false) as? YXNavigationController

        if let vc = nv?.qmui_rootViewController as? YXNewSearchViewController {
            vc.didSelectedItem = {[weak vc] (item:YXSearchItem) in
                if let vc = vc {
                    vc.dismiss(animated: true, completion: nil)
                }
                if let didSelected = didSelectedItem {
                    didSelected(item)
                }
            }
        }
    }
    
    @objc func presentToNoPopularSearch(showLike: Bool = true, showHistory: Bool = true, didSelectedItem:((YXSearchItem)->())?) {
        let dic: [String : Any] = [
            "showPopular": false,
            "showLike": showLike,
            "showHistory": showHistory,
        ]

        let nv = present(YXModulePaths.search.url, context: dic, animated: false) as? YXNavigationController

        if let vc = nv?.qmui_rootViewController as? YXNewSearchViewController {
            vc.didSelectedItem = {[weak vc] (item:YXSearchItem) in
                if let vc = vc {
                    vc.dismiss(animated: true, completion: nil)
                }
                if let didSelected = didSelectedItem {
                    didSelected(item)
                }
            }
        }
    }
    
    @objc func presentToFollowSearch(mkts: [String], showLike: Bool = true,  didSelectedItem:((YXSearchItem)->())?) {
        
        let type1Arr = [
            "\(OBJECT_SECUSecuType1.stStock.rawValue)",
            "\(OBJECT_SECUSecuType1.stFund.rawValue)",
            "\(OBJECT_SECUSecuType1.stIndex.rawValue)"
        ]
        let searchParam = YXSearchParam(q: nil, markets: mkts, type1: type1Arr, type2: nil, type3: nil, size: nil)

        let types = mkts.map{ YXSearchType(rawValue: $0) }
        let dic: [String : Any] = [
            "param" : searchParam,
            "showPopular": false,
            "showLike": showLike,
            "types": types
        ]

        let nv = present(YXModulePaths.search.url, context: dic, animated: false) as? YXNavigationController

        if let vc = nv?.qmui_rootViewController as? YXNewSearchViewController {
            vc.didSelectedItem = {[weak vc] (item:YXSearchItem) in
                if let vc = vc {
                    vc.dismiss(animated: true, completion: nil)
                }
                if let didSelected = didSelectedItem {
                    didSelected(item)
                }
            }
        }
    }
    
    /// 跳转到 广告 OC ----> Swift
    @objc func gotoBanner(with model: YXBannerActivityDetailModel) {
        let banner = BannerList(bannerID: Int(model.bannerId),
                                adType: Int(model.adType),
                                adPos: model.adPos,
                                pictureURL: model.pictureUrl,
                                originJumpURL: model.jumpUrl,
                                newsID: String(describing: model.bannerId),
                                bannerTitle: "",
                                tag: "0",
                                jumpType: YXInfomationType(rawValue: model.newsJumpType)?.converNewType()
                                )
        YXBannerManager.goto(withBanner: banner, navigator: self)
    }
    
    /// 交易下单页的消息响应 ，和ViewController的messageButton响应是一样的
    @objc func tradeOrderMessageAction(with vc: UIViewController) {
        if YXUserManager.isLogin() {
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_MSG_CENTER_URL()]
            push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        } else {
            let callback: (([String: Any])->Void)? = { _ in
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: { [weak self] in
                    guard let `self` = self else { return }
                    
                    let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_MSG_CENTER_URL()]
                    self.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
                })
            }
            
            let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: callback, vc: vc))
            push(YXModulePaths.defaultLogin.url, context: context)
        }
    }

    /// 跳转到登录页面 oc --> Swift
    @objc func pushToLoginVC(callBack: (([String: Any])->Void)?) {

        let context = YXNavigatable(viewModel: YXLoginViewModel(callBack: callBack, vc: UIViewController.current()))
        push(YXModulePaths.defaultLogin.url, context: context)
    }
    
    /// 从横屏push 到登录页面 oc --> Swift
    @objc func pushToLoginVCFromeLandscape(callBack: (([String: Any])->Void)?) {
        
        let viewModel: YXLoginViewModel = YXLoginViewModel(callBack: callBack, vc: UIViewController.current())
        viewModel.unenablePopGestion = true
        let context = YXNavigatable(viewModel: viewModel)
//        presentPath(.defaultLogin, context: context, animated: true)
        push(YXModulePaths.defaultLogin.url, context: context)
    }
}
