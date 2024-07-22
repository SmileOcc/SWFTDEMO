//
//  ZFCommunityVideoViewModel.m
//  ZZZZZ
//
//  Created by YW on 2016/11/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityVideoViewModel.h"
#import "ZFCommunityLikeApi.h"
#import "VideoDetailApi.h"
#import "ZFCommunityVideoDetailModel.h"
#import "ZFCommunityVideoDetailInfoModel.h"
#import "CommunityReplyApi.h"
#import "CommunityReviewsApi.h"
#import "ZFCommunityPostDetailReviewsModel.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "Constants.h"
#import "Configuration.h"
#import "YWCFunctionTool.h"

@interface ZFCommunityVideoViewModel ()

@property (nonatomic, assign) BOOL isLoadLike; // 是否正在加载点赞接口

@property (nonatomic, strong) ZFCommunityVideoDetailModel *detailmodel;

@property (nonatomic, strong) ZFCommunityPostDetailReviewsModel *reviewsModel;

@property (nonatomic, strong) SYBatchRequest *batchRequest;
@end

@implementation ZFCommunityVideoViewModel

- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSDictionary *dict = parmaters;
    ShowLoadingToView(dict);
    [self.batchRequest.requestArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[SYNetworkManager sharedInstance] removeRequest:obj completion:nil];
    }];
    
    self.batchRequest = [[SYBatchRequest alloc] initWithRequestArray:@[[[VideoDetailApi alloc] initWithVideoId:dict[@"video_id"]],[[CommunityReviewsApi alloc] initWithcurPage:[Refresh integerValue] pageSize:PageSize reviewId:dict[@"video_id"]]] enableAccessory:YES];
    @weakify(self)
    [self.batchRequest startWithBlockSuccess:^(SYBatchRequest *batchRequest) {
        HideLoadingFromView(dict);
        NSArray *requests = batchRequest.requestArray;
        
        VideoDetailApi *detailApi = (VideoDetailApi *)requests[0];
        
        @strongify(self)
        self.detailmodel = [self dataAnalysisFromJson: detailApi.responseJSONObject request:detailApi];
        
        CommunityReviewsApi *reviewsApi = (CommunityReviewsApi *)requests[1];
        
        self.reviewsModel = [self dataAnalysisFromJson: reviewsApi.responseJSONObject request:reviewsApi];
        if (self.reviewsModel == nil) {
            self.reviewsModel = [ZFCommunityPostDetailReviewsModel new];
        }
        
        if (self.detailmodel == nil) {
            self.detailmodel = [ZFCommunityVideoDetailModel new];
        }
        
        if (completion && self) {//防止控制器释放了，还处理操作
            completion(@[self.detailmodel,self.reviewsModel]);
        }
        
    } failure:^(SYBatchRequest *batchRequest) {
        HideLoadingFromView(dict);
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
    ShowLoadingToView(dict);
    CommunityReplyApi *api = [[CommunityReplyApi alloc] initWithDict:parmaters];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(dict);
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        NSDictionary *result = request.responseJSONObject;
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            result = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ShowToastToViewWithText(dict, result[@"msg"]);
        });
        if (completion) {
            completion(result[@"msg"]);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(dict);
        if (failure) {
            failure(nil);
        }
    }];
}


- (void)requestLikeNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSDictionary *dict = parmaters;
    NSInteger flag;
    if (self.detailmodel.videoInfo.isLike) {
        flag = 0;
    }else {
        flag = 1;
    }
    
    ShowLoadingToView(dict);
    ZFCommunityLikeApi *api = [[ZFCommunityLikeApi alloc] initWithReviewId:dict[@"video_id"] flag:flag];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(dict);
        self->_isLoadLike = NO;
        
        NSDictionary *dict = request.responseJSONObject;
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        if ([dict[@"code"] integerValue] == 0) {
            if (flag) { //这里对数据源做处理进行修改
                self.detailmodel.videoInfo.likeNum = [NSString stringWithFormat:@"%d",[self.detailmodel.videoInfo.likeNum intValue]+1];
            } else {
                self.detailmodel.videoInfo.likeNum = [NSString stringWithFormat:@"%d",[self.detailmodel.videoInfo.likeNum intValue]-1];
            }
            self.detailmodel.videoInfo.isLike = flag;
        }
        
        ShowToastToViewWithText(dict, dict[@"msg"]);
        if (completion) {
            completion(self.detailmodel.videoInfo);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(dict);
        self->_isLoadLike = NO;
        if (failure) {
            failure(nil);
        }
    }];
}

//解析
- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request{
    YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
    if ([request isKindOfClass:[VideoDetailApi class]]) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        if ([json[@"msg"] isEqualToString:@"Success"]) {
            return [ZFCommunityVideoDetailModel yy_modelWithJSON:json[@"data"]];
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
