//
//  ZFCommunityShowViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityShowViewModel.h"
#import "ZFCommunityAccountShowsListModel.h"
#import "ZFCommunityStyleShowsApi.h"
#import "ZFCommunityLikeApi.h"
#import "ZFCommunityAccountShowsModel.h"
#import "ZFCommunityDeleteApi.h"
#import "NSArrayUtils.h"
#import "ZFCommunityStyleLikesModel.h"
#import "ZFProgressHUD.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@interface ZFCommunityShowViewModel ()
@property (nonatomic, strong) ZFCommunityAccountShowsListModel      *showsListModel;
@end

@implementation ZFCommunityShowViewModel
- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    @weakify(self)
    
    ZFCommunityStyleShowsApi *api = [[ZFCommunityStyleShowsApi alloc] initWithUserid:parmaters[0] currentPage:[parmaters[1] integerValue]];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        self.showsListModel = [self dataAnalysisFromJson:request.responseJSONObject request:api];
        self.emptyViewShowType = ![NSArrayUtils isEmptyArray:self.showsListModel.list] ? EmptyViewHideType : EmptyShowNoDataType;
        if (completion) {
            completion(self.showsListModel);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        @strongify(self)
        self.emptyViewShowType = ![NSArrayUtils isEmptyArray:self.showsListModel.list] ? EmptyViewHideType : EmptyShowNoDataType;
        if (failure) {
            failure(nil);
        }
    }];
    
}

//点赞
- (void)requestLikeNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    ShowLoadingToView(parmaters);
    ZFCommunityAccountShowsModel *model = (ZFCommunityAccountShowsModel *)(parmaters[kRequestModelKey]);
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

//删除帖子
- (void)requestDeleteNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    ShowLoadingToView(parmaters);
    
    @weakify(self)
    NSDictionary *requestDic = parmaters[kRequestModelKey];
    NSString *reviewId = [requestDic valueForKey:@"reviewId"];
    NSString *userId = [requestDic valueForKey:@"userId"];
    ZFCommunityDeleteApi *api = [[ZFCommunityDeleteApi alloc]initWithDeleteId:reviewId andUserId:userId];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(parmaters);
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        @strongify(self)
        BOOL isSuccess = NO;
        NSString *code = request.responseJSONObject[@"code"];
//        NSString *msg  = request.responseJSONObject[@"msg"];
        
        if ([ZFToString(code) isEqualToString:@"0"])     // 获取评论成功
        {
            isSuccess = YES;
        } else {
            isSuccess = NO;
        }
        self.showsListModel = [self dataAnalysisFromJson: request.responseJSONObject request:api];
        self.emptyViewShowType = ![NSArrayUtils isEmptyArray:self.showsListModel.list] ? EmptyViewHideType : EmptyShowNoDataType;
        if (completion) {
            completion(@(isSuccess));
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        @strongify(self)
        HideLoadingFromView(parmaters);
        self.emptyViewShowType = ![NSArrayUtils isEmptyArray:self.showsListModel.list] ? EmptyViewHideType : EmptyShowNoDataType;
        if (failure) {
            failure(nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request {
    YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
    if ([request isKindOfClass:[ZFCommunityStyleShowsApi class]]) {
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json[@"code"] integerValue] == 0) {
            return [ZFCommunityAccountShowsListModel yy_modelWithJSON:json[@"data"]];
        }
    }
    return nil;
}
@end
