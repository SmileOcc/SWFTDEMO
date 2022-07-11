//
//  YXSearchViewModel.swift
//  uSmartOversea
//
//  Created by ZhiYun Huang on 2019/4/19.
//  Copyright © 2019 RenRenDai. All rights reserved.
//
//
//import Foundation
//import RxSwift
//import RxCocoa
//import URLNavigator
//
//class YXSearchViewModel: NSObject {
//    
//    var navigator: NavigatorServicesType!
//    
//    var type = YXSearchType.all
//    
//    var defaultParam :YXSearchParam?
//    
//    var services = YXMoyaService<YXSearchAPI>()
//    
//    var error = PublishSubject<Error?>()
//
//    var historyViewModel = YXSearchHistoryViewModel()
//    var resultViewModel = YXSearchResultViewModel()
//    
//    var lastestSearchText :String?
//    var doingSearch :Bool = false
//    
//    let disposeBag = DisposeBag()
//    
//    
//    override init() {
//        
//        super.init()
//        
//        _ = resultViewModel.saveToHistory.asObservable().takeUntil(self.rx.deallocated).subscribe(onNext: { (item) in
//           
//            if let list = YXSearchHistoryManager.shared.list.value {
//                list.add(item: item)
//                YXSearchHistoryManager.shared.list.value = list
//                YXSearchHistoryManager.shared.saveToDisk()
//            }
//        })
//    }
//    
//    //搜索
//    func search(text :String) {
//        
//        lastestSearchText = text
//        
//        if doingSearch {
//            return
//        }
//        
//        doingSearch = true
//
//        doSearch(text: text)
//        
//    }
//    
//    private func doSearch(text :String) {
//        
//        var param = YXSearchParam()
//        
//        if let defaultParam = self.defaultParam {
//            param = defaultParam
//        }
//        
//        param.q = text
//        param.size = 50
//        
//        if type != .all {
//            param.markets = [type.rawValue]
//        }
//       
//        _ = services.request(.search(param))
//            .subscribe(onSuccess: { [weak self] (list :YXSearchList?) in
//                
//                self?.doingSearch = false
//
//                //如果最后一次传入的查询字符串，跟最近一次网络请求的不一致，则再次发送一次查询
//                if let lastestSearchText = self?.lastestSearchText,lastestSearchText != "" {
//                    
//                    list?.param = param
//                    
//                    self?.resultViewModel.list.value = list
//
//                    if  param.q != nil, lastestSearchText != param.q {
//                        self?.search(text: lastestSearchText)
//                    }
//                }
//                
//                
//            }) { [weak self] (error) in
//                self?.error.onNext(error)
//                
//                self?.doingSearch = false
//        }.disposed(by: disposeBag)
//        
//    }
//    
//    deinit {
//        print(">>>>>>> \(NSStringFromClass(YXSearchViewModel.self)) deinit")
//    }
//}
