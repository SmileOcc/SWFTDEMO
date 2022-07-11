//
//  YXKOLHomeContentViewModel.swift
//  uSmartEducation
//
//  Created by usmart on 2021/12/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class YXKOLHomeContentViewModel {
    static let pageSize = 10
    
    let result: Driver<[Any]?>
    
    let loadMoreListResult: Driver<[Any]?>
    
    let activity: ActivityIndicator
    
    let collectResult: Driver<YXSpecialArticleItem?>
    
    init(input: (viewDidLoad: Driver<()>,
                 kolId: Driver<String>,
                 businessType: Driver<YXKOLHomeContentType>,
                 collectAction: PublishSubject<YXSpecialArticleItem?>,
                 loadMore: Driver<(Int)>,
                 reload: Driver<()>)) {
        
        let activity = ActivityIndicator()
        self.activity = activity
        
        let api: Driver<YXSpecialAPI> = Driver.combineLatest(input.viewDidLoad,input.kolId,input.businessType).map{ _, id, type in
            switch type {
            case .articles:
                return YXSpecialAPI.KOLCollection(id: id, pageNum: 0, pageSize: YXKOLHomeContentViewModel.pageSize)
            case .chat:
                return YXSpecialAPI.KOLChatList(id: id)
            case .video:
                return YXSpecialAPI.KOLVideoList(id: id, pageNum: 0, pageSize: YXKOLHomeContentViewModel.pageSize)
            }
        }
        result = Driver.combineLatest(input.businessType,api).flatMapLatest({(type,api) in
            return api.request().map { res in
                switch type {
                case .articles:
                    let models = YXSpecialArticleResModel.yy_model(withJSON: res?.data ?? [:])
                    return models?.items
                case .chat:
                    let models = NSArray.yy_modelArray(with: YXKOLChatGroupResModel.self, json: res?.data?["list"] ?? []) as? [YXKOLChatGroupResModel] ?? []
                    return models
                case .video:
                    let models = NSArray.yy_modelArray(with: YXKOLVideoResModel.self, json: res?.data?["items"] ?? []) as? [YXKOLVideoResModel] ?? []
                    return models
                }
            }.trackActivity(activity).asDriver(onErrorJustReturn: nil)
        })
        
        loadMoreListResult = Driver.combineLatest(input.loadMore,input.kolId,input.businessType).map{ pageNum,id,type -> (YXSpecialAPI,YXKOLHomeContentType) in
            switch type {
            case .articles:
                return (YXSpecialAPI.KOLCollection(id: id, pageNum: pageNum, pageSize: YXKOLHomeContentViewModel.pageSize),type)
            case .chat:
                return (YXSpecialAPI.KOLChatList(id: id),type)
            case .video:
                return ( YXSpecialAPI.KOLVideoList(id: id, pageNum: pageNum, pageSize: YXKOLHomeContentViewModel.pageSize),type)
            }
        }.flatMapLatest({ value in
            let (api,type) = value
            return api.request().map { res in
                switch type {
                case .articles:
                    let models = YXSpecialArticleResModel.yy_model(withJSON: res?.data ?? [:])
                    return models?.items
                case .chat:
                    let models = NSArray.yy_modelArray(with: YXKOLChatGroupResModel.self, json: res?.data?["list"] ?? []) as? [YXKOLChatGroupResModel] ?? []
                    return models
                case .video:
                    let models = NSArray.yy_modelArray(with: YXKOLVideoResModel.self, json: res?.data?["items"] ?? []) as? [YXKOLVideoResModel] ?? []
                    return models
                }
            }.trackActivity(activity).asDriver(onErrorJustReturn: nil)
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
