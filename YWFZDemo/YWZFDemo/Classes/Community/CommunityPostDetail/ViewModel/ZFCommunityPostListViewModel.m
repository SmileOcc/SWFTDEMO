
//
//  ZFCommunityPostListViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostListViewModel.h"
#import "ZFCommunityPostListResultModel.h"
#import "ZFCommunityPostListModel.h"
#import "ZFCommunityLabelDetailApi.h"
#import "ZFCommunityLikeApi.h"
#import "ZFCommunityFollowApi.h"
#import "ZFCommunityStyleLikesModel.h"
#import "ZFProgressHUD.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFCommunityPostListViewModel ()
@property (nonatomic, strong) ZFCommunityPostListResultModel                 *topicModel;
@property (nonatomic, strong) NSMutableArray<ZFCommunityPostListModel *>   *dataArray;
@end

@implementation ZFCommunityPostListViewModel

- (void)requestTopicListData:(id)parmaters
                  completion:(void (^)(id obj, NSDictionary *pageDic))completion
                    failure:(void (^)(id))failure
{
    NSArray *array = (NSArray *)parmaters;
    NSInteger page = 1;
    if ([array[0] integerValue] == 0) {
        // 假如最后一页的时候
        if ([self.topicModel.curPage integerValue] == self.topicModel.pageCount) {
            if (completion) {
                NSDictionary *pageDic = @{kTotalPageKey:@(self.topicModel.pageCount),
                                          kCurrentPageKey:@([self.topicModel.curPage integerValue])};
                completion(NoMoreToLoad, pageDic);
            }
            return;
        }
        page = [self.topicModel.curPage integerValue]  + 1;
    }
    ZFCommunityLabelDetailApi *api = [[ZFCommunityLabelDetailApi alloc] initWithcurPage:page pageSize:PageSize topicLabel:parmaters[1]];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        @strongify(self)
        self.topicModel = [self dataAnalysisFromJson: request.responseJSONObject request:api];
        
        if (page == 1) {
            self.dataArray = [NSMutableArray arrayWithArray:self.topicModel.list];
            // 谷歌统计
            // [self analyticsCommunityBannerWithBannerArray:self.homeModel.bannerlist];
        } else{
            [self.dataArray addObjectsFromArray:self.topicModel.list];
        }
        
        if (completion) {
            NSDictionary *pageDic = @{kTotalPageKey:@(self.topicModel.pageCount),
                                      kCurrentPageKey:@([self.topicModel.curPage integerValue])};
            completion(self.dataArray, pageDic);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

//关注
- (void)requestFollowNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    ShowLoadingToView(parmaters);
    
    ZFCommunityPostListModel *model = (ZFCommunityPostListModel *)(parmaters[kRequestModelKey]);
    ZFCommunityFollowApi *api = [[ZFCommunityFollowApi alloc] initWithFollowStatue:!model.isFollow followedUserId:model.userId];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(parmaters);
        
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        NSDictionary *dict = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([dict[@"code"] integerValue] == 0) {
            BOOL isFollow = !model.isFollow;
            NSDictionary *dic = @{@"userId"   : model.userId,
                                  @"isFollow" : @(isFollow)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowStatusChangeNotification object:dic];

            if (completion) {
                completion(nil);
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

- (void)requestLikeNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
   
    ShowLoadingToView(parmaters);
    
    ZFCommunityPostListModel *model = (ZFCommunityPostListModel *)(parmaters[kRequestModelKey]);
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


- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request{
    YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
    if ([request isKindOfClass:[ZFCommunityLabelDetailApi class]]) {
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json[@"code"] integerValue] == 0) {
            return [ZFCommunityPostListResultModel yy_modelWithJSON:json[@"data"]];
        }
    }
    return nil;
}

@end
