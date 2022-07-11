//
//  YXShortVideoItemViewModel.swift
//  uSmartEducation
//
//  Created by usmart on 2022/3/9.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation

enum YXShortVideoCollectionAction: Int {
    case unCollect = 1
    case collect = 0
}

enum YXShortVideoLikeAction: Int {
    case like = 1
    case unLike = 2
}

enum YXShortVideoFollowAction: Int {
    case follow = 0
    case unfollow = 1
}

class YXShortVideoItemViewModel: YXModel {
    
    let lessonPopularData: Driver<YXLessonPopularityResModel?>
    let collectResult: Driver<YXShortVideoCollectionAction?>
    let courseDetailResult: Driver<YXUserPurchasedResModel?>
    let likeResult: Driver<YXShortVideoLikeAction?>
    let followResult: Driver<YXShortVideoFollowAction?>
    let vedioRecordResult: Driver<YXResponseModel?>
    let shareResult: Driver<YXResponseModel?>
    
    init(input: (viewDidLoad: Driver<YXShortVideoRecommendItem?>,
                 collectAction: Driver<YXShortVideoCollectionAction>,
                 refreshCommentCount: Driver<()>,
                 courseDetailAction: Driver<YXShortVideoRecommendItem?>,
                 likeAction: Driver<YXShortVideoLikeAction>,
                 followAction: Driver<YXShortVideoFollowAction>,
                 shareAction: Driver<(Int,String)>,
                 viewDidAppear: Driver<YXShortVideoRecommendItem?>)) {
        
        let videoIdAndLikeAction: Driver<(videoId: String, action: YXShortVideoLikeAction)> = Driver.combineLatest(input.viewDidLoad, input.likeAction).map { (item, action) in
            return (item?.videoIdStr ?? "", action)
        }
        
        let kolIdAndFollowAction: Driver<(videoId: String, action: YXShortVideoFollowAction)> = Driver.combineLatest(input.viewDidLoad, input.followAction).map { (item, action) in
            return (item?.releaseId ?? "", action)
        }
        
        likeResult = input.likeAction.withLatestFrom(videoIdAndLikeAction).flatMapLatest({ (videoId, action) in
            return YXCourseRequestAPI.like(business: 2, businessId: videoId, status: action.rawValue).request().map({ res in
                if res?.code == .success {
                    return action
                }else {
                    return nil
                }
            }).asDriver(onErrorJustReturn: nil)
        })
        
        followResult = input.followAction.withLatestFrom(kolIdAndFollowAction).flatMapLatest({ (id, action) in
            return YXSpecialAPI.follow(state: action.rawValue, subscriptId: id).request().map({ res in
                if res?.code == .success {
                    return action
                }else {
                    return nil
                }
            }).asDriver(onErrorJustReturn: nil)
        })
        
        let itemAndCollectAction = Driver.combineLatest(input.viewDidLoad, input.collectAction) // 收藏操作需要 id和收藏动作
        
        collectResult = input.collectAction.withLatestFrom(itemAndCollectAction).flatMapLatest({ (item, action) in
            // 关联类型 0-无 1-课程 2-课时
            let id = item?.videoIdStr ?? ""
            let type = 6 // 业务类型 1-课时，2-文章，3-课程 6-短视频 7-直播
            return YXCourseRequestAPI.collectAction(bizCode: type, bizId: id, status: action.rawValue).request().map { res in
                if res?.code == .success {
                    return action
                }else {
                    return nil
                }
            }.asDriver(onErrorJustReturn: nil)
        })
        
        shareResult = input.shareAction.flatMapLatest({ value in
            let (type,id) = value
            return YXSpecialAPI.shareDataReport(bizType: 6, businessId: id, channel: type).request().map { res in
                return res
            }.asDriver(onErrorJustReturn: nil)
        })
        
        // viewDidLoad 点击收藏后刷新收藏数 评论后刷新评论数 点赞后刷新点赞数 都需要刷新数据接口 可以合并成一个信号
        let videoIdAndKolId: Driver<(videoId: String, kolId: String)> = input.viewDidLoad.map { item in
            return (item?.videoIdStr ?? "", item?.releaseId ?? "")
        }
        
        // 当点击收藏后
        let collectCompelete = collectResult.filter { collectionAction in
            return collectionAction != nil // 有操作结果才需要发送信号
        }.flatMapLatest { e in
            return videoIdAndKolId
        }
        
        // 当点赞后
        let likeCompelete = likeResult.filter { action in
            return action != nil // 有操作结果才需要发送信号
        }.flatMapLatest { e in
            return videoIdAndKolId
        }
        
        // 当点赞后
        let shareCompelete = shareResult.filter { action in
            return action != nil // 有操作结果才需要发送信号
        }.flatMapLatest { e in
            return videoIdAndKolId
        }
        
        let refreshCommentCount = input.refreshCommentCount.flatMapLatest { e in
            return videoIdAndKolId
        }
         
        lessonPopularData = Driver.merge(videoIdAndKolId, refreshCommentCount, collectCompelete,shareCompelete).flatMapLatest({ e in
            return YXCourseRequestAPI.videoPopularity(videoId: e.videoId, kolId: e.kolId).request().map { res in
                let model = YXLessonPopularityResModel.yy_model(withJSON: res?.data ?? [:])
                return model
            }.asDriver(onErrorJustReturn: nil)
        })
        
        courseDetailResult = input.courseDetailAction.flatMapLatest({ item in
            return YXCourseRequestAPI.checkUserPurchased(businessCode: 1, businessId: item?.courseIdStr ?? "").request().map({ res in
                return YXUserPurchasedResModel.yy_model(withJSON: res?.data ?? [:])
            }).asDriver(onErrorJustReturn: nil)
        })
        
        vedioRecordResult = input.viewDidAppear.filter({ _ in
            return YXUserManager.isLogin()
        }).flatMapLatest { item in
            return YXCourseRequestAPI.addVideoRecord(offset: item?.offset ?? 0,
                                                     version: item?.version ?? 0,
                                                     videoId: item?.videoIdStr ?? "").request().map({ res in
                return res
            }).asDriver(onErrorJustReturn: nil)
        }
        
    }
    
    
}
