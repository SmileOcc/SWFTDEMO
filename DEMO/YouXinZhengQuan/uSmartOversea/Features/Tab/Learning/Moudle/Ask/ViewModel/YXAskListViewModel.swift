//
//  YXAskListViewModel.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/8.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class YXAskListViewModel {
    
    static let pageSize = 10
    
    let activity: ActivityIndicator
    
    ///列表
    let listResult: Driver<YXAskResModel?>
    
    ///点赞
    let likeResult: Driver<(YXResponseModel?,String?)>
    
    //加载更多
    let loadMoreListResult: Driver<YXAskResModel?>
    
    //删除
//    let deleteResult: Driver<(YXResponseModel?,Bool)>
    let deleteQuestionResult: Driver<(YXResponseModel?,String?)>
    let deleteAnswerResult: Driver<(YXResponseModel?,String?,String?)>
    
    init(input: (viewDidLoad: Driver<()>,
                 kolId: Driver<String?>,
                 businessType: Driver<YXAskListType>,
                 likeAction: Driver<(Bool,String)>,
                 deleteQuestionAction: Driver<String?>,
                 deleteReplyAction: Driver<(String?,String?)>,
                 stocksAction: Driver<[String]?>,
                 loadMore: Driver<(Int)>,
                 reload: Driver<()>)) {
        
        let activity = ActivityIndicator()
        self.activity = activity
        
        listResult = Driver.combineLatest(Driver.merge(input.viewDidLoad,input.reload),
                                          input.businessType,
                                          input.kolId,
                                          input.stocksAction).map{ _,type,kolId,stocks in
            return type == .kol ? YXSpecialAPI.KOLAnswerList(id: kolId ?? "", pageNum: 1, pageSize: YXAskListViewModel.pageSize) : YXSpecialAPI.askQuery(pageNum: 1, pageSize: YXAskListViewModel.pageSize, type : type.rawValue ,stockCode: stocks)}
        .flatMapLatest({api in
            return api.request().map { res in
                return YXAskResModel.yy_model(withJSON: res?.data ?? [:])
            }.trackActivity(activity).asDriver(onErrorJustReturn: nil)
        })
        
        likeResult = input.likeAction.flatMapLatest({ value in
            let (state,replyId) = value
            return YXSpecialAPI.like(likeStatus: state ? 2 : 1, replyId: replyId).request().map({ api in
                return (api,replyId)
            }).asDriver(onErrorJustReturn: (nil,nil))
        })
        
        loadMoreListResult = Driver.combineLatest(input.loadMore,input.businessType,input.kolId,input.stocksAction).map{ pageNum,type,kolId,stocks in
            return type == .kol ? YXSpecialAPI.KOLAnswerList(id: kolId ?? "", pageNum: pageNum, pageSize: YXAskListViewModel.pageSize) : YXSpecialAPI.askQuery(pageNum: pageNum, pageSize: YXAskListViewModel.pageSize, type : type.rawValue, stockCode: stocks )}
        .flatMapLatest({api in
            return api.request().map { res in
                return YXAskResModel.yy_model(withJSON: res?.data ?? [:])
            }.asDriver(onErrorJustReturn: nil)
        })
        
        deleteQuestionResult = input.deleteQuestionAction.flatMapLatest({ questionId in
            return YXSpecialAPI.delAsk(id: questionId ?? "").request().map { res in
                                return (res,questionId)
                            }.asDriver(onErrorJustReturn: (nil,nil))
        })
        
        deleteAnswerResult = input.deleteReplyAction.flatMapLatest({ questionId,replyId in
            return YXSpecialAPI.delReply(id: replyId ?? "").request().map { res in
                                return (res,questionId,replyId)
                            }.asDriver(onErrorJustReturn: (nil,nil,nil))
        })
    }
}
