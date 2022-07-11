//
//  YXHotETFListViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/5/22.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXHotETFListViewModel: YXViewModel {
    
    let firstCodePre = "HOTETFFIRSTCONS" // 拉取一级分类成分股列表前缀 接口文档地址：http://szshowdoc.youxin.com/web/#/23?page_id=264
    let secondCodePre = "HOTETFSECONDCONS" // 拉取二级分类成分股列表前缀
    var selectedIndex = 0
    var market = ""
    
    var titles: [String] = [YXLanguageUtility.kLang(key: "common_all")]
    var viewControllers: [YXStockDetailIndustryVC] = []
    
    override func initialize() {
        if let market = self.params?["market"] as? String {
            self.market = market
        }
        
        if let selectedTab = self.params?["selectedTab"] as? Int {
            self.selectedIndex = selectedTab
        }
        
        if let sectionInfoDic = self.params?["sectionInfo"] as? [String: Any] {
            if let name = sectionInfoDic["chsNameAbbr"] as? String, let code = sectionInfoDic["secuCode"] as? String {
                self.title = name
                // 全部成分股
                let allCode = String(format: "%@_%@", firstCodePre, code)
                let allVC = self.viewController(code: allCode)
                self.viewControllers.append(allVC)
            }
            
            
            
            if let list = self.params?["sectionList"] as? [YXMarketRankCodeListInfo] {
                for item in list {
                    if let code = item.secuCode, let name = item.chsNameAbbr {
                        let code = String(format: "%@_%@", secondCodePre, code)
                        let vc = self.viewController(code: code)
                        self.viewControllers.append(vc)
                        self.titles.append(name)
                    }
                }
                
            }else if let list = self.params?["sectionList"] as? [[String: Any]] {
                for dic in list {
                    if let code = dic["secuCode"] as? String, let name = dic["chsNameAbbr"] as? String {
                        let code = String(format: "%@_%@", secondCodePre, code)
                        let vc = self.viewController(code: code)
                        self.viewControllers.append(vc)
                        self.titles.append(name)
                    }
                }
            }
        }
    }
    
    func viewController(code: String) -> YXStockDetailIndustryVC {
        let vc = YXStockDetailIndustryVC()
        if let root = UIApplication.shared.delegate as? YXAppDelegate {
            vc.viewModel.navigator =  root.navigator
        }
        vc.viewModel.code = code
        vc.viewModel.market = self.market
        
        return vc
    }
}
