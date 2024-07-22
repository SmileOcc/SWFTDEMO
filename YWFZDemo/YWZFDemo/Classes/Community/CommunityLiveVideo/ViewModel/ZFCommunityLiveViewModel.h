//
//  ZFCommunityLiveViewModel.h
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFCommunityLiveListModel.h"
#import "ZFCommunityVideoLiveGoodsModel.h"
#import "ZFCommunityLiveZegoLikeModel.h"
#import "ZFCommunityLiveZegoHistoryMessageModel.h"

#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveViewModel : BaseViewModel<YYModel>

@property (nonatomic, strong) NSMutableArray <ZFCommunityLiveListModel *> *live_list;
@property (nonatomic, strong) NSMutableArray <ZFCommunityLiveListModel *> *end_live_list;


@property (nonatomic, assign) NSInteger historyCurPage;
@property (nonatomic, assign) NSInteger historyTotalPage;
//不能在刷新了
@property (nonatomic, assign) BOOL      historyCanNotRefresh;

//直播列表
- (void)requestCommunityLiveListisFirstPage:(BOOL)isFirstPage
                                 completion:(void (^)(NSDictionary *pageInfo))completion;

//播放详情
- (void)requestCommunityLiveDetailLiveID:(NSString *)liveID
                              completion:(void (^)(ZFCommunityLiveListModel *liveModel))completion;

//直播播放弹窗推荐商品
- (void)requestCommunityLiveDetailLiveGoods:(NSString *)url completion:(void (^)(ZFCommunityVideoLiveGoodsModel *liveGoodsModel))completion;

//播放浏览统计 1第一次播放 0之前播放过
- (void)requestCommunityLivePlayStatisticsLiveID:(NSString *)liveID
                                      completion:(void (^)(NSString *status))completion;

/**
 直播视频评论

 @param liveID
 @param type 是否登录房间: 0 1
 @param completion
 */

//0: 直播外（包含直播前、录播）
//1: 直播中（使用的接口： 2，5）
- (void)requestCommunityLiveLikeLiveID:(NSString *)liveID
                              liveType:(NSString *)isLive
                              nickname:(NSString *)nickname
                                 phase:(NSString *)phase
                            completion:(void (^)(ZFCommunityLiveZegoLikeModel *likeModel))completion;


/**
 直播视频评论

 @param liveID
 @param isLive 是否登录房间: 0 1
 @param content
 @param completion
 */
- (void)requestCommunityLiveCommentLiveID:(NSString *)liveID
                                 liveType:(NSString *)isLive
                                  content:(NSString *)content
                                 nickname:(NSString *)nickname
                                    phase:(NSString *)phase
                               completion:(void (^)(BOOL success, NSString *msg))completion;
/**
  直播视频历史数据
  
  @param liveID
  @param completion
  */
- (void)requestCommunityLiveHistory:(NSDictionary *)parmaters
                         completion:(void (^)(ZFCommunityLiveZegoHistoryMessageModel *messagModels))completion;

- (void)requestLiveRemind:(NSDictionary *)parmaters completion:(void (^)(BOOL success, NSString *msg))completion;

- (void)requestLiveRemindState:(NSDictionary *)parmaters completion:(void (^)(BOOL success, NSInteger status, NSString *msg))completion;
@end

NS_ASSUME_NONNULL_END
