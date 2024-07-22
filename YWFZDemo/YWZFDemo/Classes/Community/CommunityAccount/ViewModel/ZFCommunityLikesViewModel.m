
//
//  ZFCommunityLikesViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityLikesViewModel.h"
#import "ZFCommunityAccountLikesListModel.h"
#import "ZFCommunityStyleLikesApi.h"
#import "ZFCommunityAccountLikesModel.h"
#import "ZFCommunityFollowApi.h"
#import "ZFCommunityLikeApi.h"
#import "ZFCommunityStyleLikesModel.h"
#import "ZFProgressHUD.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFCommunityLikesViewModel ()
@property (nonatomic, assign) NSInteger                         currentPage;
@end

@implementation ZFCommunityLikesViewModel


- (void)requestCommunityLikesPageData:(BOOL)isFirstPage
                               userId:(NSString *)userId
                           completion:(void (^)(NSArray *currentPageData, NSDictionary *pageInfo))completion
{
    if (isFirstPage) {
        self.currentPage = 1;
    } else {
        self.currentPage = ++self.currentPage;
    }
    
    ZFCommunityStyleLikesApi *api = [[ZFCommunityStyleLikesApi alloc] initWithUserid:userId currentPage:self.currentPage];
    
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        if (completion) {
            ZFCommunityAccountLikesListModel *likesListModel = [self dataAnalysisFromJson: request.responseJSONObject request:api];
            
            NSDictionary *pageInfo = @{ kTotalPageKey  : @(likesListModel.pageCount),
                                        kCurrentPageKey: @(likesListModel.curPage) };
            completion(likesListModel.list, pageInfo);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        @strongify(self)
        --self.currentPage;
        if (completion) {
            completion(nil, nil);
        }
    }];
}

//点赞
- (void)requestLikeNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    ShowLoadingToView(parmaters);
    ZFCommunityAccountLikesModel *model = (ZFCommunityAccountLikesModel *)(parmaters[kRequestModelKey]);
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
            NSString *nickName = model.nickName ?: @"";
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

//关注
- (void)requestFollowNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure; {
    ShowLoadingToView(parmaters);
    ZFCommunityAccountLikesModel *model = (ZFCommunityAccountLikesModel *)(parmaters[kRequestModelKey]);
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
            ShowToastToViewWithText(parmaters, dict[@"msg"]);
            NSDictionary *dic = @{@"userId"   : ZFToString(model.userId),
                                  @"isFollow" : @(!model.isFollow)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowStatusChangeNotification object:dic];
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(parmaters);
        if (failure) {
            failure(nil);
        }
    }];
    
}

- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request {
    YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
    if ([request isKindOfClass:[ZFCommunityStyleLikesApi class]]) {
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json[@"code"] integerValue] == 0) {
            return [ZFCommunityAccountLikesListModel yy_modelWithJSON:json[@"data"]];
        }
    }
    return nil;
}

@end
