//
//  YXSearchHistoryManager.swift
//  uSmartOversea
//
//  Created by ZhiYun Huang on 2019/5/8.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import RxSwift

class YXSearchHistoryManager: NSObject {
    
    static let shared = YXSearchHistoryManager()
    
    var list: Variable<YXSearchList?> = Variable(YXSearchList())
    var warrantsList: Variable<YXSearchList?> = Variable(YXSearchList())

    var searchType: YXStockWarrantsType = .bullBear

    var optionChainSearchItem: YXSearchItem?
    
    override init() {
        super.init()
        loadDiskCache()
    }
    
    func loadDiskCache(){
        
        if let list = MMKV.default().object(of: YXSearchList.self, forKey: NSStringFromClass(YXSearchHistoryManager.self)) as? YXSearchList {
            self.list.value = list
        }
    }
    
    func saveToDisk(){
        if let list = list.value {
            MMKV.default().set(list, forKey: NSStringFromClass(YXSearchHistoryManager.self))
        }
    }
    
    
    func saveWarrantsToDisk(){ //存储轮证搜索
        if let list = warrantsList.value {
            MMKV.default().set(list, forKey: searchKey())
        }
    }
    
    func loadWarrantsDiskCache(searchType: YXStockWarrantsType){ //加载储轮证搜索

        self.searchType = searchType
        if let list = MMKV.default().object(of: YXSearchList.self, forKey: searchKey()) as? YXSearchList {
            self.warrantsList.value = list
        } else {
            self.warrantsList.value = YXSearchList()
        }
    }

    func searchKey() -> String {
        switch searchType {
            case .optionChain:
                return "OptionChainSearch"
            default:
                return "WarrantsSearch"
        }
    }
}
