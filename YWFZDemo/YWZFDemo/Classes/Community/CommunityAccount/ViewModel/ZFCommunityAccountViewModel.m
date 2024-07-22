


//
//  ZFCommunityAccountViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityAccountViewModel.h"
#import "ZFCommunityAccountInfoModel.h"
#import "ZFCommunityUserInfoApi.h"
#import "ZFCommunityFollowApi.h"
#import "ZFCommunityMessageCountApi.h"
#import "ZFCommunityCheckCommissionApi.h"
#import "ZFCommunityJoinCommissionApi.h"
#import "ZFProgressHUD.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "Configuration.h"

@interface ZFCommunityAccountViewModel ()

@end

@implementation ZFCommunityAccountViewModel
- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    @weakify(self)
    ZFCommunityUserInfoApi *api = [[ZFCommunityUserInfoApi alloc] initWithUserid:ZFGetStringFromDict(parmaters, kRequestUserIdKey)];
    
    //社区个人中心页面不要转圈,因为 shows tab 有头部请求
//    ShowLoadingToView(parmaters);
    
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
//        HideLoadingFromView(parmaters);
        @strongify(self)
        id result = [self dataAnalysisFromJson: request.responseJSONObject request:api];
        if (completion) {
            completion(result);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
//        HideLoadingFromView(parmaters);
        if (failure) {
            failure(nil);
        }
    }];
}

//关注
- (void)requestFollowNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    ShowLoadingToView(parmaters);
    ZFCommunityAccountInfoModel *model = (ZFCommunityAccountInfoModel*)parmaters[kRequestModelKey];
    ZFCommunityFollowApi *api = [[ZFCommunityFollowApi alloc] initWithFollowStatue:!model.isFollow followedUserId:model.userId];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(parmaters);
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        
        NSDictionary *dict = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([dict[@"code"] integerValue] == 0) {
            NSDictionary *dic = @{@"userId"   : model.userId ?: @"",
                                  @"isFollow" : @(!model.isFollow)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kFollowStatusChangeNotification object:dic];
        }
        ShowToastToViewWithText(parmaters, dict[@"msg"]);
        
        if (completion) {
            completion(nil);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(parmaters);
        if (failure) {
            failure(nil);
        }
    }];
}


- (void)requestCheckCommissionNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    ZFCommunityCheckCommissionApi *api = [[ZFCommunityCheckCommissionApi alloc] init];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        
        NSDictionary *dict = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([dict[@"code"] integerValue] == 0 && ZFJudgeNSDictionary(dict[@"data"])) {
            if (completion) {
                completion(dict[@"data"]);
            }
        } else {
            if (failure) {
                failure(nil);
            }
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestJionCommissionNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    ZFCommunityJoinCommissionApi *api = [[ZFCommunityJoinCommissionApi alloc] init];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
        
        NSDictionary *dict = request.responseJSONObject;
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            dict = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([dict[@"code"] integerValue] == 0 && ZFJudgeNSDictionary(dict[@"data"])) {
            if (completion) {
                completion(dict[@"data"]);
            }
        } else {
            if (failure) {
                failure(nil);
            }
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request {
    YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
    if ([request isKindOfClass:[ZFCommunityUserInfoApi class]]) {
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json[@"code"] integerValue] == 0) {
            return [ZFCommunityAccountInfoModel yy_modelWithJSON:json[@"data"]];
        }
    } else if ([request isKindOfClass:[ZFCommunityMessageCountApi class]]) {
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json isKindOfClass:[NSDictionary class]]) {
            if ([json[@"statusCode"] integerValue] == 200  && [json[@"data"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dataDic = json[@"data"];
                NSString *messageTotal = ZFGetStringFromDict(dataDic, @"total");
                return messageTotal;
            }
        }
    }

    return nil;
}


@end
