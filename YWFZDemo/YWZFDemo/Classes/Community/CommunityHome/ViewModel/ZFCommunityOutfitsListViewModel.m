//
//  ZFCommunityOutfitsListViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/7/11.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityOutfitsListViewModel.h"
#import "ZFCommunityLikeApi.h"
#import "ZFCommunityStyleLikesModel.h"
#import "YWLocalHostManager.h"
#import "ZFProgressHUD.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import <GGBrainKeeper/BrainKeeperManager.h>

@implementation ZFCommunityOutfitsListViewModel
{
    __block int totalPage;
    __block int tempCurPage;
}

- (void)requestOutfitsListData:(BOOL)firstPage
                    completion:(void (^)(NSArray <ZFCommunityOutfitsModel *> *outfitsListArray, NSDictionary *pageInfo))completion
{
    
    if (firstPage) {
        tempCurPage = 1;
    }else{
        tempCurPage++;
    }
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"type"] = @(9);
    info[@"directory"] = @(60);
    info[@"site"] = @"ZZZZZcommunity";
    info[@"userId"] = USERID ?: @"0";
    info[@"size"] = @"20";
    info[@"page"] = @(tempCurPage);
    info[@"app_type"] = @"2";

    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.parmaters = info;
    requestModel.url = CommunityAPI;
    
    if (firstPage) {
        requestModel.needToCache = YES;
        // 添加事件链路
        requestModel.eventName = @"outfits_channel";
        requestModel.pageName = @"community";
    }
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        NSMutableArray *allListArray = [[NSMutableArray alloc] init];
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        if (ZFJudgeNSDictionary(responseObject[ZFDataKey])) {
            NSDictionary *dic = responseObject[ZFDataKey];
            
            if (ZFJudgeNSArray(dic[@"topList"])) {//国家置顶数据
                NSArray *topListArray = [NSArray yy_modelArrayWithClass:[ZFCommunityOutfitsModel class] json:dic[@"topList"]];
                if (ZFJudgeNSArray(topListArray)) {
                    [allListArray addObjectsFromArray:topListArray];
                }
            }
            
            if (ZFJudgeNSArray(dic[ZFListKey])) {
                
                NSArray *listArray = [NSArray yy_modelArrayWithClass:[ZFCommunityOutfitsModel class] json:dic[ZFListKey]];
                if (ZFJudgeNSArray(listArray)) {
                    [allListArray addObjectsFromArray:listArray];
                }
            }
            
            if (ZFJudgeNSString(dic[@"total"])) {
                self->totalPage = [dic[@"total"] intValue];
            }
            if (ZFJudgeNSString(dic[@"curPage"])) {
                self->tempCurPage = [dic[@"curPage"] intValue];
            }
        }
        
        if (completion) {
            NSDictionary *pageInfo = @{ kTotalPageKey  : @(self->totalPage),
                                        kCurrentPageKey: @(self->tempCurPage) };
            completion(allListArray,pageInfo);
        }
    } failure:^(NSError *error) {
        //ShowToastToViewWithText(nil, error.domain);
        if (completion) {
            completion(nil,0);
        }
    }];
}

- (void)requestLikeNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    ShowLoadingToView(parmaters);
    
    ZFCommunityOutfitsModel *model = (ZFCommunityOutfitsModel *)(parmaters[kRequestModelKey]);
    ZFCommunityLikeApi *api = [[ZFCommunityLikeApi alloc] initWithReviewId:model.reviewId flag:![model.liked boolValue]];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(parmaters);
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        NSDictionary *dict = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        ShowToastToViewWithText(parmaters, dict[@"msg"]);
        if ([dict[@"code"] integerValue] == 0) {
            if (completion) {
                completion(nil);
            }
            NSString *addTime = model.reviewAddTime ?: @"";
            NSString *avatar  = model.avatar ?: @"";
            NSString *content = model.reviewContent ?: @"";
            BOOL isFollow     = 0;
            NSString *nickName = model.nikename ?: @"";
            NSString *replyCount = model.replyCount ?: @"";
            NSArray *reviewPic = @[];
            NSString *userId = model.userId ?: @"";
            NSInteger likeCount = [model.likeCount integerValue];
            NSString *reviewId = model.reviewId ?: @"";
            BOOL isLiked = [model.liked boolValue];
            
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
