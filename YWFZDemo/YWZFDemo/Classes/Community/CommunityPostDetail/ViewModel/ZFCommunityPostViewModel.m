//
//  ZFCommunityPostViewModel.m
//  Yoshop
//
//  Created by YW on 16/7/20.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "ZFCommunityPostViewModel.h"
#import "PostApi.h"
#import "TabObtainApi.h"
#import "ZFCommunityPostResultModel.h"
#import "ZFProgressHUD.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@implementation ZFCommunityPostViewModel
#pragma mark - request
- (void)requestTabObtainNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    @weakify(self)
    TabObtainApi *api = [[TabObtainApi alloc] init];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        id result = [self dataAnalysisFromJson: request.responseJSONObject request:api];
        if (completion) {
            completion(result);
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestPostNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    PostApi *api = [[PostApi alloc] initWithDict:parmaters];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        id result = [self dataAnalysisFromJson: request.responseJSONObject request:api];
        //NSString *msg = request.responseJSONObject[@"msg"];
        ZFCommunityPostResultModel *model = [ZFCommunityPostResultModel yy_modelWithJSON:request.responseJSONObject];
        if (result) {
            if (completion) {
                completion(model);
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
    if ([request isKindOfClass:[TabObtainApi class]]) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json[@"code"] integerValue] == 0) {
            return json[@"data"];
        }else {
            ShowToastToViewWithText(nil, json[@"message"]);
        }
    } else if ([request isKindOfClass:[PostApi class]]) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json[@"code"] integerValue] == 0) {
            return @(YES);
        }else {
            ShowToastToViewWithText(nil, json[@"message"]);
            return @(NO);
        }
    }
    return nil;
}
@end
