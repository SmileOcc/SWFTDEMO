//
//  ZFCommunityPostOperateViewModel.m
//  Yoshop
//
//  Created by YW on 16/7/11.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "ZFCommunityPostOperateViewModel.h"

#import "ZFCommunityLikeApi.h"//点赞
#import "CommunityDetailApi.h"//详情
#import "CommunityReplyApi.h"//回复
#import "CommunityReviewsApi.h"//评论

#import "ZFCommunityStyleLikesModel.h"
#import "ZFCommunityPostDetailModel.h"
#import "ZFCommunityPostDetailReviewsModel.h"
#import "ZFCommunityPostDetailReviewsListMode.h"
#import "ZFCommunityFollowApi.h"
#import "ZFCommunityDeleteApi.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@interface ZFCommunityPostOperateViewModel ()

@property (nonatomic,strong) ZFCommunityPostDetailModel *detailModel;
@property (nonatomic,strong) ZFCommunityPostDetailReviewsModel *reviewsModel;
@property (nonatomic,strong) SYBatchRequest *batchRequest;
@property (nonatomic,assign) BOOL isLoadLike;     // 是否正在加载点攒接口
@property (nonatomic,assign) BOOL isLoadfollow;

@end

@implementation ZFCommunityPostOperateViewModel

#define PageSize @"15"

#pragma mark Requset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    YWLog(@"parmaters:%@",parmaters);
    
    NSDictionary *dict = parmaters;
    ShowLoadingToView(dict);
    [self.batchRequest.requestArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[SYNetworkManager sharedInstance] removeRequest:obj completion:nil];
    }];
    
    self.batchRequest = [[SYBatchRequest alloc] initWithRequestArray:@[[[CommunityDetailApi alloc] initWithReviewId:dict[@"review_id"]],[[CommunityReviewsApi alloc] initWithcurPage:[Refresh integerValue] pageSize:PageSize reviewId:dict[@"review_id"]]] enableAccessory:YES];
    @weakify(self);
    [self.batchRequest startWithBlockSuccess:^(SYBatchRequest *batchRequest) {
        
        NSArray *requests = batchRequest.requestArray;
        CommunityDetailApi *detailApi = (CommunityDetailApi *)requests[0];
        
        @strongify(self);
        self.detailModel = [self dataAnalysisFromJson: detailApi.responseJSONObject request:detailApi];
        
        CommunityReviewsApi *reviewsApi = (CommunityReviewsApi *)requests[1];
        
        self.reviewsModel = [self dataAnalysisFromJson: reviewsApi.responseJSONObject request:reviewsApi];
        
        //这个参数是从首页一直带过来的 评论需要 因为后台没有返回这个参数
        self.detailModel.reviewsId = [parmaters objectForKey:@"review_id"] ?: @"";
        
        if (completion) {
            completion(@[self.detailModel == nil ? [ZFCommunityPostDetailModel new] : self.detailModel,self.reviewsModel == nil ? [ZFCommunityPostDetailReviewsModel new] : self.reviewsModel]);
        }
        HideLoadingFromView(dict);
        
    } failure:^(SYBatchRequest *batchRequest) {
        HideLoadingFromView(parmaters);
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestReviewsListNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    CommunityReviewsApi *api = [[CommunityReviewsApi alloc] initWithcurPage:[parmaters[0] integerValue] pageSize:PageSize reviewId:parmaters[1]];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        self.reviewsModel = [self dataAnalysisFromJson: request.responseJSONObject request:api];
        
        if (completion) {
            completion(self.reviewsModel);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestReplyNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSDictionary *dict = parmaters;
    CommunityReplyApi *api = [[CommunityReplyApi alloc] initWithDict:parmaters];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        NSDictionary *result = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            result = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        ZFCommunityPostDetailReviewsListMode *reviewModel;
        
        if ([result[@"code"] integerValue] == 0) {
            ZFCommunityStyleLikesModel *likeModel = [ZFCommunityStyleLikesModel new];
            likeModel.addTime = self.detailModel.addTime;
            likeModel.avatar = self.detailModel.avatar;
            likeModel.content = self.detailModel.content;
            likeModel.isFollow = self.detailModel.isFollow;
            likeModel.isLiked = !self.detailModel.isLiked;
            likeModel.likeCount = self.detailModel.likeCount;
            likeModel.nickname = self.detailModel.nickname;
            likeModel.replyCount = self.detailModel.replyCount;
            likeModel.reviewId = self.detailModel.reviewsId;
            likeModel.reviewPic = self.detailModel.reviewPic;
            likeModel.userId = self.detailModel.userId;
            
            if (ZFJudgeNSDictionary(result[@"data"])) {
                reviewModel = [ZFCommunityPostDetailReviewsListMode yy_modelWithDictionary:result[@"data"]];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kReviewCountsChangeNotification object:likeModel];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                ShowToastToViewWithText(dict, result[@"msg"]);
            });
        }

        if (completion) {
            completion(reviewModel);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
    
}

//关注
- (void)requestFollowNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSDictionary *dict = parmaters;
    if (_isLoadfollow) {
        return;
    }
    _isLoadfollow = YES;
    
    ZFCommunityPostDetailModel *model = (ZFCommunityPostDetailModel *)dict[@"model"];
    ZFCommunityFollowApi *api = [[ZFCommunityFollowApi alloc] initWithFollowStatue:!model.isFollow followedUserId:model.userId];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        self->_isLoadfollow = NO;
        NSDictionary *dict = request.responseJSONObject;
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        if ([dict[@"code"] integerValue] == 0) {
            NSDictionary *dic = @{@"userId"   : model.userId,
                                  @"isFollow" : @(!model.isFollow)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowStatusChangeNotification object:dic];
        }
        ShowToastToViewWithText(dict, dict[@"msg"]);
        if (completion) {
            completion(nil);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        self->_isLoadfollow = NO;
        if (failure) {
            failure(nil);
        }
    }];
}

//点赞
- (void)requestLikeNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSDictionary *dict = parmaters;
    if (self->_isLoadLike) {
        return;
    }
    self->_isLoadLike = YES;
    
    self.detailModel = (ZFCommunityPostDetailModel *)dict[@"model"];
    ZFCommunityLikeApi *api = [[ZFCommunityLikeApi alloc] initWithReviewId:self.detailModel.reviewsId flag:!self.detailModel.isLiked];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        self->_isLoadLike = NO;
        NSDictionary *result = request.responseJSONObject;
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            result = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        ShowToastToViewWithText(dict, result[@"msg"]);
        if ([dict[@"code"] integerValue] == 0) {
            
            NSString *addTime = self.detailModel.addTime ?: @"";
            NSString *avatar  = self.detailModel.avatar ?: @"";
            NSString *content = self.detailModel.content ?: @"";
            BOOL isFollow     = self.detailModel.isFollow;
            NSString *nickName = self.detailModel.nickname ?: @"";
            NSString *replyCount = self.detailModel.replyCount ?: @"";
            NSArray *reviewPic = self.detailModel.reviewPic;
            NSString *userId = self.detailModel.userId ?: @"";
            NSInteger likeCount = [self.detailModel.likeCount integerValue];
            NSString *reviewId = self.detailModel.reviewsId ?: @"";
            BOOL isLiked = self.detailModel.isLiked;
            
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
         ShowToastToViewWithText(dict, dict[@"msg"]);
        if (completion) {
            completion(nil);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        self->_isLoadLike = NO;
        if (failure) {
            failure(nil);
        }
    }];
}

//删除帖子
- (void)requestDeleteNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSDictionary *dict = parmaters;
    self.detailModel   = parmaters[@"model"];
    NSString *reviewId = self.detailModel.reviewsId;
    ZFCommunityDeleteApi *api = [[ZFCommunityDeleteApi alloc]initWithDeleteId:reviewId andUserId:self.detailModel.userId];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        BOOL isSuccess = NO;
        
        id responseObject = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        NSString *code = ZFToString(responseObject[@"code"]);
        NSString *msg  = responseObject[@"msg"];
        
        if ([code isEqualToString:@"0"])     // 获取评论成功
        {
            isSuccess = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteStatusChangeNotification object:self.detailModel.reviewsId];
        } else {
            isSuccess = NO;
        }
        ShowToastToViewWithText(dict, msg);
        if (completion) {
            completion(@(isSuccess));
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}


- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request{
    YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
    if ([request isKindOfClass:[CommunityDetailApi class]]) {
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json[@"code"] integerValue] == 0) {
            return [ZFCommunityPostDetailModel yy_modelWithJSON:json[@"data"]];
        }
    }else if ([request isKindOfClass:[CommunityReviewsApi class]]) {
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json[@"code"] integerValue] == 0) {
            return [ZFCommunityPostDetailReviewsModel yy_modelWithJSON:json[@"data"]];
        }
    }
    return nil;
}

@end
