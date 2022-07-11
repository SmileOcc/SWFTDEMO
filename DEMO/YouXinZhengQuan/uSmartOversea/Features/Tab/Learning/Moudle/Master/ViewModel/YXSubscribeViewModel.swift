//
//  YXSubscribeViewModel.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/10/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa

class YXSubscribeViewModel {
    let checkSubscribe: Driver<Bool?>
    
    let mySubscribeKOLList: Driver<[YXSpecialKOLItem]>
    
    let subscribeArticleList: Driver<[YXSpecialArticleItem]?>
    let loadMoreArticleList: Driver<[YXSpecialArticleItem]>
    
    let unSubscribeInfo: Driver<YXSpecialKOLListResModel?>
    
    let collectResult: Driver<YXSpecialArticleItem?>
    
    let activity: ActivityIndicator
    
    init(input:(viewWillAppear: Driver<(Bool?)>,
                refreshKOL: Driver<(Int)>,
                pullrefresh: Driver<()>,
                loadMore: Driver<Int>,
                emptyButtonTaps: Driver<(Bool?)>,
                collectAction: PublishSubject<YXSpecialArticleItem?>)) {
        
        let subscribePageSize = 20
        let unSubscribePageSize = 4
        
        // 由于可能在H5页面发生订阅或取消订阅,所以该接口需要在viewwillappear里查询,为了只在状态变更时才刷新列表数据,需要比较状态是否变更,currentState是控制器传过来的当前状态,需要根接口返回的值比较
        // 会发送 true false nil三种信号, 如果发送的是nil 则说明不需要刷新列表
        checkSubscribe = Driver.merge(input.viewWillAppear, input.emptyButtonTaps).flatMapLatest({ currentState in
            return YXSpecialAPI.checkSubscribe.request().map { res in
                if let hasSubscribe = res?.data?["subscribeFlag"] as? Bool {
                    if hasSubscribe == currentState { // 状态无变更
                        return nil
                    }else {
                        return hasSubscribe
                    }
                }else {
                    return nil
                }
                
            }.asDriver(onErrorJustReturn: nil)
        })
        
        let activity = ActivityIndicator()
        self.activity = activity
        
        // 如果有订阅($0==true) 去请求已订阅文章列表
        let pullrefresh: Driver<Bool?> = input.pullrefresh.map { _ in
            return true
        }
        subscribeArticleList = Driver.merge(checkSubscribe, pullrefresh).filter({ isSubscribe in // 如果信号是 nil 则不需要再去请求列表数据了
            if let v = isSubscribe {
                return v
            }else {
                return false
            }
        }).flatMapLatest({ pageNum in
            return YXSpecialAPI.subscribeArticleList(pageNum: 1, pageSize: subscribePageSize).request().map { res in
                let model = YXSpecialArticleResModel.yy_model(withJSON: res?.data ?? [:])
                let list = model?.items ?? []
                return list
            }.trackActivity(activity).asDriver(onErrorJustReturn: nil)
        })
        
        mySubscribeKOLList = Driver.merge(checkSubscribe, pullrefresh).filter({ isSubscribe in // 如果信号是 nil 则不需要再去请求列表数据了
            if let v = isSubscribe {
                return v
            }else {
                return false
            }
        }).flatMapLatest({ _ in
            return YXSpecialAPI.subscribeKOLList.request().map { res in
                let model = YXSpecialKOLListResModel.yy_model(withJSON: res?.data ?? [:])
                let list = model?.items ?? []
                return list
            }.asDriver(onErrorJustReturn: [])
        })
        
        // 如果无订阅($0==false) 去请求推荐用户列表
        // 转换信号 bool 转为 pagenum
        let noSubscribe = checkSubscribe.filter({ isSubscribe in // 如果信号是 nil 则不需要再去请求列表数据了
            if let v = isSubscribe {
                return !v
            }else {
                return false
            }
        }).map { _ in
            return 1 // 第一次请求第一页
        }
        
        unSubscribeInfo = Driver.merge(noSubscribe, input.refreshKOL).flatMapLatest({ pageNum in
            return YXSpecialAPI.unSubscribeList(pageNum: pageNum, pageSize: unSubscribePageSize).request().map { res in
                let model = YXSpecialKOLListResModel.yy_model(withJSON: res?.data ?? [:])
                return model
            }.trackActivity(activity).asDriver(onErrorJustReturn: nil)
        })
        
        loadMoreArticleList = input.loadMore.flatMapLatest({ pageNum in
            return YXSpecialAPI.subscribeArticleList(pageNum: pageNum, pageSize: subscribePageSize).request().map { res in
                let model = YXSpecialArticleResModel.yy_model(withJSON: res?.data ?? [:])
                let list = model?.items ?? []
                return list
            }.asDriver(onErrorJustReturn: [])
        })
        
        collectResult = input.collectAction.asDriver(onErrorJustReturn: nil).flatMapLatest({ item in
            
            let id = item?.postId ?? ""
            let status = (item?.collectFlag ?? false) ? 1 : 0 // 0已收藏 1未收藏
            return YXSpecialAPI.collection(postId: id, status: status).request().map { res in
                if res?.code == .success {
                    item?.collectFlag = status == 0 ? true : false
                    var count = Int(item?.collectionCount ?? "0") ?? 0
                    if status == 0 {
                        count += 1
                    }else {
                        count -= 1
                    }
                    item?.collectionCount = String(count)
                    return item
                }else {
                    return nil
                }
            }.asDriver(onErrorJustReturn: nil)
        })
    }
}
