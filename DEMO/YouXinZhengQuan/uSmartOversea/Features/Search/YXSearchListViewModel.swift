//
//  YXSearchListViewModel.swift
//  uSmartOversea
//
//  Created by ZhiYun Huang on 2019/4/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import YXKit

protocol YXSearchListViewModel {
    
    var types :[YXSearchType] {get set}
    
    var list :Variable<YXSearchList?> { get set }
    
    var title :String? {get}
    
    var cellRightNormalImage :String? {get}
    
    var cellRightSelectedImage :String? {get}
    
    var headerRightNormalImage :String? {get}
    
    var cellDidSelected :PublishSubject<YXSearchItem> {get}
    
    var allDidSelected :PublishSubject<Bool> {get}
    
    func cellRightAction(sender :UIButton, at :Int)
    
    func headerRightAction(sender :UIButton?)
    
    func cellTapAction(at :Int)
        
    func saveToDisk()
        
}

class YXSearchHistoryViewModel: YXSearchListViewModel {
   
    var allDidSelected = PublishSubject<Bool>()
    
    var types: [YXSearchType] = []

    var cellDidSelected = PublishSubject<YXSearchItem>()
    
    var list: Variable<YXSearchList?> = Variable(YXSearchList())
    
    var title: String? = YXLanguageUtility.kLang(key: SearchLanguageKey.history_title.rawValue)
    
    var cellRightNormalImage: String? = "icon_del"
    
    var cellRightSelectedImage: String?
    var headerRightNormalImage :String? = "delete_oversea"
    
    let disposeBag = DisposeBag()
    init() {
    }
    
    func cellRightAction(sender :UIButton, at :Int) {
        
        if let value = list.value, at >= 0 && at < value.count() {
            
            if let item = value.item(at: at){
                
                let history = YXSearchHistoryManager.shared.list.value
                history?.remove(item: item)
                YXSearchHistoryManager.shared.list.value = history
                
                YXSecuGroupManager.shareInstance().remove(item)
                saveToDisk()
            }
        }
    }
    
    func headerRightAction(sender: UIButton?) {
        
        if let value = list.value ,value.count() > 0{
            
            let history = YXSearchHistoryManager.shared.list.value
            
            value.forEach { (item) in
                history?.remove(item: item)
            }
            
            YXSearchHistoryManager.shared.list.value = history
            
            saveToDisk()
        }
        
    }
    
    func cellTapAction(at: Int) {
        
        if let value = list.value, at >= 0 && at < value.count() {
            if let item = value.item(at: at){
                cellDidSelected.onNext(item)
                
                //调整历史记录位置
                if let list = YXSearchHistoryManager.shared.list.value {
                    list.add(item: item)
                    YXSearchHistoryManager.shared.list.value = list
                    YXSearchHistoryManager.shared.saveToDisk()
                    
                }
            }
        }
    }

    func saveToDisk(){
        YXSearchHistoryManager.shared.saveToDisk()
    }
    
    deinit {
        print(">>>>>>> \(NSStringFromClass(YXSearchHistoryViewModel.self)) deinit")
    }

}

class YXSearchResultViewModel: YXSearchListViewModel {
    
    var allDidSelected = PublishSubject<Bool>()
    
    var types: [YXSearchType] = []

    var cellDidSelected = PublishSubject<YXSearchItem>()
    
    var saveToHistory = PublishSubject<YXSearchItem>()

    var list :Variable<YXSearchList?> = Variable(nil)
    
    var title: String? = YXLanguageUtility.kLang(key: SearchLanguageKey.result_title.rawValue)
    
    var cellRightNormalImage: String? = "new_like_unselect"
    
    var cellRightSelectedImage: String? = "new_like_select"
    var headerRightNormalImage :String?
    
    var secuGroup: YXSecuGroup?
    
    func cellRightAction(sender :UIButton, at :Int) {
        sender.isSelected = !sender.isSelected
        if let value = list.value, at >= 0 && at < value.count(), let item = value.item(at: at) {
            
            if YXSecuGroupManager.shareInstance().containsSecu(item) {
                YXSecuGroupManager.shareInstance().remove(item)
                if let window = UIApplication.shared.delegate?.window, window != nil {
                    YXProgressHUD.showMessage(message: YXLanguageUtility.kLang(key: "search_remove_from_favorite"), inView: window!, buttonTitle: "", delay: 2, clickCallback: nil)
                }
            } else {
                let secu = YXOptionalSecu()
                secu.name = item.name ?? ""
                secu.market = item.market
                secu.symbol = item.symbol
                if let type1 = item.type1 {
                    secu.type1 = type1
                }
                if let type2 = item.type2 {
                    secu.type2 = type2
                }
                if let type3 = item.type3 {
                    secu.type3 = type3
                }
                /*
                var success = false
                if let secuGroup = secuGroup, secuGroup.groupType() == .custom {
                    success = YXSecuGroupManager.shareInstance().append(secu, secuGroup: secuGroup)
                    if success {
                        YXProgressHUD.showMessage(String(format: YXLanguageUtility.kLang(key: "tips_add_stock_success"), secuGroup.name))
                    }
                } else {
                    success = YXSecuGroupManager.shareInstance().append(secu)
                    
                    if success {
                        YXProgressHUD.showMessage(YXLanguageUtility.kLang(key: SearchLanguageKey.favorite_add.rawValue))
                    }
                }
                 */
                YXToolUtility.addSelfStockToGroup(secu: secu, secuGroup: secuGroup) { (addResult) in
                    if addResult {

                    } else {
                        sender.isSelected = !sender.isSelected
                    }
                }

            }
            
            saveToHistory.onNext(item)
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
        
    func saveToDisk(){}
    
    deinit {
        print(">>>>>>> \(NSStringFromClass(YXSearchResultViewModel.self)) deinit")
    }
}

