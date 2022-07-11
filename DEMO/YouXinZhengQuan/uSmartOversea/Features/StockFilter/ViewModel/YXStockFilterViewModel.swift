//
//  YXStockFilterViewModel.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/2.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class YXStockFilterViewModel: YXViewModel {
    var market: String = kYXMarketHK
    var model: YXStockFilterQueryItemsResponseModel?
    var sectionSelectedCountBlock: ((_ indexPath: IndexPath, _ count: Int) -> Void)?
    var editModel: YXStockFilterUserFilterList?
    var operationType: YXStockFilterOperationType = .new
    var industrySelectedItems: [Any] = []
    var customInputCachDic: [String: YXStokFilterListItem] = [:]
    
    var requestGroups: [YXStokFilterGroup] {
        var array: [YXStokFilterGroup] = []
        
        for group in self.model?.groups ?? [] {
            var newFilterItems: [YXStockFilterItem] = []
            for item in group.items {
                if item.isSelected {
                    
                    let newItem = YXStockFilterItem()
                    newItem.key = item.key
                    newItem.name = item.name
                    newItem.queryType = item.queryType
                    newItem.queryValueList = []
                    newFilterItems.append(newItem)
                    
                    if YXStockFilterEnumUtility.shared.enumFromString(item.key ?? "") == .industry {
                        // 行业信息是从另一个列表来的
                        newItem.queryValueList = item.queryValueList
                    }else {
                        for list in item.queryValueList {
                            let newValueListItem = YXStokFilterQueryValueListItem()
                            newItem.queryValueList.append(newValueListItem)
                            
                            var arr: [YXStokFilterListItem] = []
                            for item in list.list {
                                if item.isSelected {
                                    arr.append(item)
                                }
                            }
                            
                            newValueListItem.list = arr
                        }
                    }
                }
            }
            
            if newFilterItems.count > 0 {
                let newGroup = YXStokFilterGroup()
                newGroup.items = newFilterItems
                newGroup.key = group.key
                newGroup.name = group.name
                
                array.append(newGroup)
            }
        }
        
        return array
    }
    
    var selectedConditionDatas: [YXStockFilterItem] {
        get {
            var array: [YXStockFilterItem] = []
            for group in model?.groups ?? [] {
                for item in group.items {
                    if item.isSelected {
                        array.append(item)
                    }
                }
            }
            return array
        }
    }
    
    func selectedCountForSection(section: Int) -> Int {
        var count = 0
        let group = model?.groups[section]
        for item in group?.items ?? [] {
            if item.isSelected {
                count += 1
            }
        }
        return count
    }
    
    func startFilterStock() {
        
        if YXUserManager.isLogin() {

            if YXUserManager.shared().getLevel(with: market) == .delay {
                let msg = YXLanguageUtility.kLang(key: "filter_delay_prompt")
                let alertView = YXAlertView.alertView(title: YXLanguageUtility.kLang(key: "common_tips"), message: msg)
                alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "common_cancel"), style: .cancel, handler: {_ in }))
                alertView.addAction(YXAlertAction.action(title: YXLanguageUtility.kLang(key: "upgrade_immediately"), style: .default, handler: { (action) in
                    YXWebViewModel.pushToWebVC(YXH5Urls.YX_MY_QUOTES_URL())
                }))
                
                alertView.showInWindow()
                
                return
            }
            
            let vm = YXStockPickerResultViewModel.init(services: self.services, params: ["market": self.market, "updateType": NSNumber.init(value: self.operationType.rawValue), "groups": self.requestGroups, "groupName": (editModel?.name ?? ""), "idNumber": NSNumber(value: (editModel?.Id ?? 0))])
            self.services.push(vm, animated: true)

        } else {
            (self.services as? NavigatorServices)?.pushToLoginVC(callBack: nil)
        }
    }
    
    func changeState(withActionType type: YXStockFilterActionType) -> Driver<Any?> {
        switch type {
        case .selectedItem(let item, let selectedIndexArr):
            item.isSelected = true
            for (index, itemList) in item.queryValueList.enumerated() {
                for (subIndex, item) in itemList.list.enumerated() {
                    if subIndex == selectedIndexArr[index] {
                        item.isSelected = true
                    }else {
                        item.isSelected = false
                    }
                }
            }
        case .unSelectedItem(let item):
            item.isSelected = false
            if YXStockFilterEnumUtility.shared.enumFromString(item.key ?? "")  == .industry {
                industrySelectedItems.removeAll()
            }
        case .customInput(let item, let lowValue, let upValue, let showText):
            // 要找到key为custom的自定义项，再赋值
            item.isSelected = true
            for subItem in item.queryValueList.first?.list ?? [] {
                if subItem.key == "custom" {
                    if let key = item.key, customInputCachDic[key] == nil {
                        // 由于原始值会被用户输入值覆盖，这里把原始值缓存起来
                        let cacheItem = YXStokFilterListItem()
                        cacheItem.min = subItem.min
                        cacheItem.max = subItem.max
                        customInputCachDic[key] = cacheItem
                    }
                    
                    subItem.isSelected = true
                    subItem.min = lowValue
                    subItem.max = upValue
                    subItem.name = showText
                }else {
                    subItem.isSelected = false
                }
            }
        case .selectedIndustry(let item, let selecteds):
            if selecteds.count > 0 {
                item.isSelected = true
                let queryValueList = YXStokFilterQueryValueListItem()
                var arr: [YXStokFilterListItem] = []
                for item in selecteds {
                    if let dic = item as? Dictionary<String, Any> {
                        let item = YXStokFilterListItem()
                        item.isSelected = true
                        if let name = dic["industry_name"] as? String {
                            item.name = name
                        }
                        if let value = dic["industry_code_yx"] as? String {
                            item.value = value
                        }
                        arr.append(item)
                    }
                }
                queryValueList.list = arr
                item.queryValueList = [queryValueList]
            }else {
                item.isSelected = false
            }
            
        case .unSelectedAll:
            industrySelectedItems.removeAll()
            for group in model?.groups ?? [] {
                for item in group.items {
                    item.isSelected = false
                }
            }
        case .edit:
            
            for editGroup in editModel?.groups ?? [] {
                for group in model?.groups ?? [] {
                    if editGroup.key == group.key {
                        synGroup(originGroup: group, editGroup: editGroup)
                    }
                }
            }

        }
        // 只是告诉订阅者数据已变更完毕可以做下一步事情了
        return Observable.just(nil).asDriver(onErrorJustReturn: nil)
    }
    
    func synGroup(originGroup: YXStokFilterGroup, editGroup: YXStokFilterGroup) {
        for editItem in editGroup.items {
            for item in originGroup.items {
                if editItem.key == item.key {
                    item.isSelected = true
                    if YXStockFilterEnumUtility.shared.enumFromString(item.key ?? "") == .industry {
                        item.queryValueList = editItem.queryValueList
                        industrySelectedItems = []
                        for listQuerytItem in editItem.queryValueList {
                            for item in listQuerytItem.list {
                                industrySelectedItems.append(["industry_code_yx": (item.value ?? ""), "industry_name": (item.name ?? "")])
                            }
                        }
                    }
                    
                    synFilterItem(originItem: item, editItem: editItem)
                    
                    break
                }
                
            }
        }
    }
    
    func synFilterItem(originItem: YXStockFilterItem, editItem: YXStockFilterItem) {
        for (editIndex, editQuerytListItem) in editItem.queryValueList.enumerated() {
            for (originIndex, listQuerytItem) in originItem.queryValueList.enumerated() {
                if editIndex == originIndex {
                    // 同步索引相同的项，比如A数组中的index=0的项和B数组中index=0的项同步
                    synListItem(originListItem: listQuerytItem, editListItem: editQuerytListItem)
                    break
                }
            }
        }
    }
    
    func synListItem(originListItem: YXStokFilterQueryValueListItem, editListItem: YXStokFilterQueryValueListItem) {
        for editValueItem in editListItem.list {
            for originValueItem in originListItem.list {
                if editValueItem.key == originValueItem.key {
                    originValueItem.isSelected = true
                    if editValueItem.key == "custom" {
                        originValueItem.min = editValueItem.min
                        originValueItem.max = editValueItem.max
                        originValueItem.name = editValueItem.name
                    }
                    break
                }
            }
        }
    }
    
    func getFilterItems() -> (Single<Any?>) {
        let single = Single<Any?>.create { single in
            
            let requestModel = YXStockFilterQueryitemsReqModel()
            requestModel.market = self.market
            
            let request = YXRequest.init(request: requestModel)
            
            request.startWithBlock(success: { [weak self](response) in
                
                if response.code == YXResponseStatusCode.success {
                    self?.model = YXStockFilterQueryItemsResponseModel.yy_model(withJSON: response.data ?? [:])
                    single(.success(self?.model))
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
    
    func getFilterResult() -> (Driver<NSAttributedString?>) {
        let single = Single<NSAttributedString?>.create { single in
            
            let requestGroups = self.requestGroups
            
            if requestGroups.count > 0 {
                let requestModel = YXStockPickerResultRequestModel()
                requestModel.market = self.market
                requestModel.justCount = true
                
                requestModel.groups = self.requestGroups
                
                let request = YXRequest.init(request: requestModel)
                
                request.startWithBlock(success: { [weak self](response) in
                    let conditionCount = self?.selectedConditionDatas.count ?? 0
                    if response.code == YXResponseStatusCode.success {
                        let model = YXStockPickerModel.yy_model(withJSON: response.data ?? [:])
                        let stockCount = model?.count ?? 0
                        let result = self?.resultAttrStr(conditionCount: conditionCount, stockCount: stockCount)
                        
                        single(.success(result))
                    }else {
                        let result = self?.resultAttrStr(conditionCount: conditionCount, stockCount: 0)
                        single(.success(result))
                    }

                }, failure: { (request) in
                    single(.error(request.error ?? NSError.init(domain: "", code: -1, userInfo: nil)))
                })
                
            }else {
                let result = self.resultAttrStr(conditionCount: 0, stockCount: 0)
                single(.success(result))
            }
            
            return Disposables.create()
        }
        
        return single.asDriver(onErrorJustReturn: nil)
    }
    
    func resultAttrStr(conditionCount: Int, stockCount: Int) -> NSAttributedString {
        let conditionCountStr = "\(conditionCount)"
        let stockCountStr = "\(stockCount)"
        let keyWords: [String] = [conditionCountStr, stockCountStr]
        
        let text1: String = String(format: YXLanguageUtility.kLang(key: "total_selected_prefix"), conditionCount)

        let text2: String = String(format: YXLanguageUtility.kLang(key: "total_selected_suffix"), stockCount)
        
        let textArr = [text1, text2]
        
        let wholeAttrStr = NSMutableAttributedString.init()
        
        for (index, str) in keyWords.enumerated() {
            let text = textArr[index]
            let attrStr = NSMutableAttributedString.init(string: text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : QMUITheme().textColorLevel2()])
            let range = (text as NSString).range(of: str)
            attrStr.addAttributes([NSAttributedString.Key.foregroundColor : QMUITheme().themeTextColor(), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .medium)], range: range)
            wholeAttrStr.append(attrStr)
        }
        
        return wholeAttrStr
    }
    
    override init(services: YXViewModelServices, params: [AnyHashable : Any]?) {
        super.init(services: services, params: params)
        if let market = params?["market"] as? String {
            self.market = market
        }
    }
}
