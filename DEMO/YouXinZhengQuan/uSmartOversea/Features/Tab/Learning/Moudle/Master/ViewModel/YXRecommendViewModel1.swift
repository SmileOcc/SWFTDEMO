//
//  YXRecommendViewModel.swift
//  uSmartEducation
//
//  Created by 覃明明 on 2021/10/12.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa

class YXRecommendViewModel1 {

    let recommendList: Driver<[YXSpecialArticleItem]?>
    let loadMoreList: Driver<[YXSpecialArticleItem]>
    let collectResult: Driver<YXSpecialArticleItem?>
    
    let resultList: Driver<(YXRecommendChatAskResModel?,[YXSpecialArticleItem]?)>
    
    let chatAskList: Driver<YXRecommendChatAskResModel?>
    
    let activity: ActivityIndicator
    
    init(input:(viewDidLoad: Driver<()>,
                pullRefresh: Driver<()>,
                loadMore: Driver<Int>,
                collectAction: PublishSubject<YXSpecialArticleItem?>,
                emptyButtonTaps: Driver<()>)) {
        
        let pageSize = 20
        
        let activity = ActivityIndicator()
        self.activity = activity
        
        recommendList = Driver.merge(input.viewDidLoad, input.pullRefresh, input.emptyButtonTaps).flatMapLatest({ pageNum in
            return YXSpecialAPI.recommend(pageNum: 1, pageSize: pageSize).request().map { res in
                let model = YXSpecialArticleResModel.yy_model(withJSON: res?.data ?? [:])
                return model?.items
            }.trackActivity(activity).asDriver(onErrorJustReturn: nil)
        })
        
        chatAskList = Driver.merge(input.viewDidLoad, input.pullRefresh, input.emptyButtonTaps).flatMapLatest({ pageNum in
            return YXSpecialAPI.recommendChatAsk.request().map { res in
                let model = YXRecommendChatAskResModel.yy_model(withJSON: res?.data ?? [:])
                return model
            }.trackActivity(activity).asDriver(onErrorJustReturn: nil)
        })
        
        resultList = Driver.combineLatest(chatAskList,recommendList)
        
        loadMoreList = input.loadMore.flatMapLatest({ pageNum in
            return YXSpecialAPI.recommend(pageNum: pageNum, pageSize: pageSize).request().map { res in
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
