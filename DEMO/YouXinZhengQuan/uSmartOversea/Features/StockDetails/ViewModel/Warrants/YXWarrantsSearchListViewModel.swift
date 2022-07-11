//
//  YXWarrantsSearchListViewModel.swift
//  uSmartOversea
//
//  Created by 井超 on 2019/8/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import YXKit

class YXWarrantsSearchHistoryViewModel: YXSearchListViewModel {
    
    var allDidSelected = PublishSubject<Bool>()

    var types: [YXSearchType] = []

    var cellDidSelected = PublishSubject<YXSearchItem>()
    
    var list: Variable<YXSearchList?> = Variable(YXSearchList())
    
    var title: String? = YXLanguageUtility.kLang(key: SearchLanguageKey.history_title.rawValue)
    
    var cellRightNormalImage: String? = "icon_del"
    
    var cellRightSelectedImage: String?
    var headerRightNormalImage :String? = "delete_oversea_light"
    
    var warrantType: YXStockWarrantsType = .bullBear
    
    let disposeBag = DisposeBag()
    init() {
        YXSearchHistoryManager.shared.warrantsList.asObservable().subscribe(onNext: { [weak self] (list) in
            
            self?.loadDiskCache()
            
            
        }).disposed(by: disposeBag)
    }
    
    func cellRightAction(sender :UIButton, at :Int) {
        
        if let value = list.value, at >= 0 && at < value.count() {
            
            if let item = value.item(at: at){
                
                let history = YXSearchHistoryManager.shared.warrantsList.value
                history?.remove(item: item)
                YXSearchHistoryManager.shared.warrantsList.value = history
                
                YXSecuGroupManager.shareInstance().remove(item)
//                YXSensorAnalyticsTrack.track(withEvent: .ViewClick, properties: [YXSensorAnalyticsPropsConstant.PROP_VIEW_PAGE : "search",
//                                                                                 YXSensorAnalyticsPropsConstant.PROP_VIEW_ID : "like_cancel",
//                                                                                 YXSensorAnalyticsPropsConstant.PROP_VIEW_NAME : "删自选",
//                                                                                 YXSensorAnalyticsPropsConstant.PROP_STOCK_ID : YXSensorAnalyticsPropsConstant.stockID(market: item.market, symbol: item.symbol)])
                saveToDisk()
            }
        }
    }
    
    func headerRightAction(sender: UIButton?) {
        
        if let value = list.value ,value.count() > 0{
            
            let history = YXSearchHistoryManager.shared.warrantsList.value
            
            value.forEach { (item) in
                history?.remove(item: item)
            }
            
            YXSearchHistoryManager.shared.warrantsList.value = history
            
            saveToDisk()
        }
        
    }
    
    func cellTapAction(at: Int) {
        
        if let value = list.value, at >= 0 && at < value.count() {
            if let item = value.item(at: at){
                cellDidSelected.onNext(item)
                
                //调整历史记录位置
                if let list = YXSearchHistoryManager.shared.warrantsList.value {
                    list.add(item: item)
                    YXSearchHistoryManager.shared.warrantsList.value = list
                    YXSearchHistoryManager.shared.saveWarrantsToDisk()
                }
            }
        }
    }
    
    func loadDiskCache(){
        //过滤出匹配类型的数据
        if types != [] {
            let newList = YXSearchList()
            
            if let count = YXSearchHistoryManager.shared.warrantsList.value?.count() {
                let markets = types.map{ $0.rawValue }
                for i in (0..<count).reversed() {
                    if
                        let item = YXSearchHistoryManager.shared.list.value?.item(at: i),
                        markets.contains(item.market),
                        let type1 = item.type1,
                        let secuType1 = OBJECT_SECUSecuType1(rawValue: type1),
                        (secuType1 == .stStock
                            || secuType1 == .stFund
                            || secuType1 == .stFuture
                            || secuType1 == .stBond
                            || secuType1 == .stOption
                            || (self.warrantType == .inlineWarrants && item.type3 == OBJECT_SECUSecuType3.stInlineWarrant.rawValue))
                    {
                        newList.add(item: item)
                    }
                }
            }
            
            list.value = newList
            
            return
        }
        
        list.value = YXSearchHistoryManager.shared.warrantsList.value
    }
    
    func saveToDisk(){
        YXSearchHistoryManager.shared.saveWarrantsToDisk()
    }
    
    deinit {
        print(">>>>>>> \(NSStringFromClass(YXSearchHistoryViewModel.self)) deinit")
    }
    
}

class YXWarrantsSearchResultViewModel: YXSearchListViewModel {
    
    var allDidSelected = PublishSubject<Bool>()
    
    var types: [YXSearchType] = []

    var cellDidSelected = PublishSubject<YXSearchItem>()
    
    var saveToHistory = PublishSubject<YXSearchItem>()
    
    var list :Variable<YXSearchList?> = Variable(nil)
    
    var title: String? = YXLanguageUtility.kLang(key: SearchLanguageKey.result_title.rawValue)
    
    var cellRightNormalImage: String?
    
    var cellRightSelectedImage: String?
    var headerRightNormalImage :String?
    
    func cellRightAction(sender :UIButton, at :Int) {
        sender.isSelected = !sender.isSelected
        if let value = list.value, at >= 0 && at < value.count(), let _ = value.item(at: at) {

        }
    }
    
    func headerRightAction(sender: UIButton?) {
        
    }
    
    func cellTapAction(at: Int) {
        
        if let value = list.value, at >= 0 && at < value.count() {
            
            if let item = value.item(at: at){
                saveToHistory.onNext(item)
                cellDidSelected.onNext(item)
                
            }
        }
    }
    
    func loadDiskCache(){}
    
    func saveToDisk(){}
    
    deinit {
        print(">>>>>>> \(NSStringFromClass(YXSearchResultViewModel.self)) deinit")
    }
}
