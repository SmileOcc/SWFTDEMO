//
//  ZFCommunityShowsListViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityShowsListViewModel.h"
#import "ZFCommunityLikeApi.h"
#import "ZFCommunityFollowApi.h"
#import "ZFCommunityStyleLikesModel.h"
#import "YWLocalHostManager.h"
#import "ZFProgressHUD.h"
#import "AccountManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "Configuration.h"
#import <GGBrainKeeper/BrainKeeperManager.h>

static NSInteger kZFExploreShowsListSize = 20;


@interface ZFCommunityShowsListViewModel()

@property (nonatomic, assign) NSInteger tempCurPage;
@property (nonatomic, assign) NSInteger totalPage;

@end

@implementation ZFCommunityShowsListViewModel

- (void)requestShowsListData:(BOOL)firstPage
                  completion:(void (^)(NSArray <ZFCommunityFavesItemModel *> *showsListArray,NSDictionary *pageInfo))completion
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    self.tempCurPage =  firstPage ? 1 : self.tempCurPage+1;
    
    info[@"type"] = @"9";
    info[@"directory"] = @"70";
    info[@"site"] = @"ZZZZZcommunity";
    info[@"app_type"] = @"2";
    info[@"userId"] = USERID ?: @"0";
    info[@"curPage"] = @(self.tempCurPage);
    info[@"pageSize"] = @(kZFExploreShowsListSize);
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.parmaters = info;
    requestModel.url = CommunityAPI;
    if (firstPage) {
        requestModel.needToCache = YES;
        // 添加事件链路 在第一页监控
        requestModel.eventName = @"show_channel";
        requestModel.pageName = @"community";
    }
    @weakify(self)
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        @strongify(self)
        NSMutableArray *allListArray = [[NSMutableArray alloc] init];
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        if (ZFJudgeNSDictionary(responseObject[ZFDataKey])) {
            NSDictionary *dic = responseObject[ZFDataKey];
            
            if (ZFJudgeNSArray(dic[@"topList"])) {//国家置顶数据
                NSArray *topListArray = [NSArray yy_modelArrayWithClass:[ZFCommunityFavesItemModel class] json:dic[@"topList"]];
                if (ZFJudgeNSArray(topListArray)) {
                    [allListArray addObjectsFromArray:topListArray];
                }
            }
            if (ZFJudgeNSArray(dic[ZFListKey])) {
                NSArray *listArray = [NSArray yy_modelArrayWithClass:[ZFCommunityFavesItemModel class] json:dic[ZFListKey]];
                if (ZFJudgeNSArray(listArray)) {
                    [allListArray addObjectsFromArray:listArray];
                }
                self.totalPage = [dic[@"pageCount"] intValue];
                self.tempCurPage = [dic[@"curPage"] intValue];
            }
            
            //111,222,333,444
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            
            [allListArray enumerateObjectsUsingBlock:^(ZFCommunityFavesItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.type == 3) {
                    obj.video_width = (KScreenWidth - 10*3) / 2;
                    obj.video_height = (KScreenWidth - 10*3) / 2;
                }
                
                //数量格式化
                NSString *like = ZFToString(obj.likeCount);
                NSString *reply = ZFToString(obj.replyCount);
                NSString *viewNum = ZFToString(obj.view_num);
                NSString *joinNumber = ZFToString(obj.join_number);
                
                obj.formatLikeCount = [formatter stringFromNumber:[NSNumber numberWithInteger:[like integerValue]]];
                obj.formatReplyCount = [formatter stringFromNumber:[NSNumber numberWithInteger:[reply integerValue]]];
                obj.formatView_num = [formatter stringFromNumber:[NSNumber numberWithInteger:[viewNum integerValue]]];
                obj.formatJoin_number = [formatter stringFromNumber:[NSNumber numberWithInteger:[joinNumber integerValue]]];
                
            }];
        }

        if (completion) {
            NSDictionary *pageInfo = @{ kTotalPageKey  : @(self.totalPage),
                                        kCurrentPageKey: @(self.tempCurPage) };
            completion(allListArray,pageInfo);
        }
    } failure:^(NSError *error) {
        //ShowToastToViewWithText(nil, error.domain);
        if (completion) {
            completion(nil,nil);
        }
    }];
}


/// 首页社区帖子列表
- (void)requestPostCategoryListData:(BOOL)firstPage
                              catID:(NSString *)catID
                         completion:(void (^)(NSArray <ZFCommunityFavesItemModel *> *showsListArray,NSDictionary *pageInfo))completion
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    if (firstPage) {
        self.tempCurPage = 1;
    }else{
        self.tempCurPage++;
    }
    
    info[@"type"] = @"9";
    info[@"directory"] = @"76";
    info[@"site"] = @"ZZZZZcommunity";
    info[@"app_type"] = @"2";
    info[@"loginUserId"] = USERID ?: @"0";
    info[@"page"] = @(self.tempCurPage);
    info[@"size"] = @(kZFExploreShowsListSize);
    info[@"cat_id"] = ZFToString(catID);

    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.parmaters = info;
    requestModel.url = CommunityAPI;
    
    if (firstPage) {
        requestModel.needToCache = YES;
        // 添加事件链路
        requestModel.eventName = @"other_channel";
        requestModel.pageName = @"community";
    }
    @weakify(self)
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        @strongify(self)
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        NSArray *dataArray = [NSArray array];
        if (ZFJudgeNSDictionary(responseObject[ZFDataKey])) {
            NSDictionary *dic = responseObject[ZFDataKey];
            if (ZFJudgeNSArray(dic[ZFListKey])) {
                
                dataArray = [NSArray yy_modelArrayWithClass:[ZFCommunityFavesItemModel class] json:dic[ZFListKey]];
                
                //111,222,333,444
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
                formatter.numberStyle = NSNumberFormatterDecimalStyle;
                
                [dataArray enumerateObjectsUsingBlock:^(ZFCommunityFavesItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.type == 3) {
                        obj.video_width = (KScreenWidth - 10*3) / 2;
                        obj.video_height = (KScreenWidth - 10*3) / 2;
                    }
                    
                    //数量格式化
                    NSString *like = ZFToString(obj.likeCount);
                    NSString *reply = ZFToString(obj.replyCount);
                    NSString *viewNum = ZFToString(obj.view_num);
                    NSString *joinNumber = ZFToString(obj.join_number);
                    
                    obj.formatLikeCount = [formatter stringFromNumber:[NSNumber numberWithInteger:[like integerValue]]];
                    obj.formatReplyCount = [formatter stringFromNumber:[NSNumber numberWithInteger:[reply integerValue]]];
                    obj.formatView_num = [formatter stringFromNumber:[NSNumber numberWithInteger:[viewNum integerValue]]];
                    obj.formatJoin_number = [formatter stringFromNumber:[NSNumber numberWithInteger:[joinNumber integerValue]]];
                    
                }];
                
            }
        }
        if (completion) {
            
            //加载判断 因为只返回总数
            BOOL canLoadMore = dataArray.count < kZFExploreShowsListSize ? NO : YES;
            self.totalPage = canLoadMore ? self.tempCurPage + 1 : self.tempCurPage;
            
            NSDictionary *pageInfo = @{ kTotalPageKey  : @(self.totalPage),
                                        kCurrentPageKey: @(self.tempCurPage) };
            completion(dataArray,pageInfo);
        }
    } failure:^(NSError *error) {
        //ShowToastToViewWithText(nil, error.domain);
        if (completion) {
            completion(nil,nil);
        }
    }];
}


/**
 * 点击关注请求
 */
- (void)requestFollowNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    ShowLoadingToView(parmaters);
    
    ZFCommunityFavesItemModel *model = (ZFCommunityFavesItemModel *)(parmaters[kRequestModelKey]);
    ZFCommunityFollowApi *api = [[ZFCommunityFollowApi alloc] initWithFollowStatue:!model.isFollow followedUserId:model.userId];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(parmaters);
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        NSDictionary *dict = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([dict[@"code"] integerValue] == 0) {
            if (completion) {
                completion(nil);
            }
            NSDictionary *dic = @{@"userId"   : ZFToString(model.userId),
                                  @"isFollow" : @(!model.isFollow)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowStatusChangeNotification object:dic];
        } else {
            if (failure) {
                failure(nil);
            }
        }
        ShowToastToViewWithText(parmaters, dict[@"msg"]);
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(parmaters);
        if (failure) {
            failure(nil);
        }
    }];
}

/**
 * 点赞请求
 */
- (void)requestLikeNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    ShowLoadingToView(parmaters);
    
    ZFCommunityFavesItemModel *model = (ZFCommunityFavesItemModel *)(parmaters[kRequestModelKey]);
    ZFCommunityLikeApi *api = [[ZFCommunityLikeApi alloc] initWithReviewId:model.reviewId flag:!model.isLiked];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(parmaters);
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        NSDictionary *dict = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([dict[@"code"] integerValue] == 0) {
            if (completion) {
                completion(nil);
            }
            NSString *addTime = model.addTime ?: @"";
            NSString *avatar  = model.avatar ?: @"";
            NSString *content = model.content ?: @"";
            BOOL isFollow     = model.isFollow;
            NSString *nickName = model.nickname ?: @"";
            NSString *replyCount = model.replyCount ?: @"";
            NSArray *reviewPic = model.reviewPic;
            NSString *userId = model.userId ?: @"";
            NSInteger likeCount = [model.likeCount integerValue];
            NSString *reviewId = model.reviewId ?: @"";
            BOOL isLiked = model.isLiked;
            
            NSDictionary *dic = @{@"addTime" : addTime,
                                  @"avatar" : avatar,
                                  @"content" : content,
                                  @"isFollow" : @(isFollow),
                                  @"isLiked" : @(!isLiked),
                                  @"likeCount" : @(likeCount),
                                  @"nickname" : nickName,
                                  @"replyCount" : replyCount,
                                  @"reviewPic" : reviewPic,
                                  @"userId" : userId,
                                  @"reviewId" : reviewId};
            
            ZFCommunityStyleLikesModel *likeModel = [ZFCommunityStyleLikesModel yy_modelWithJSON:dic];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLikeStatusChangeNotification object:likeModel];
        }
        ShowToastToViewWithText(parmaters, dict[@"msg"]);
    
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(parmaters);
        if (failure) {
            failure(nil);
        }
    }];
}

@end
