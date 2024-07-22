//
//  ZFCommunityRedDotModel.m
//  ZZZZZ
//
//  Created by YW on 2018/8/14.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityRedDotViewModel.h"
#import "YWLocalHostManager.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"

@implementation ZFCommunityRedDotViewModel

- (void)requestCommunityNewMessageCompletion:(void (^)(BOOL isNewMessage))completion
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"type"] = @"9";
    info[@"directory"] = @"73";
    info[@"site"] = @"ZZZZZcommunity";
    info[@"app_type"] = @"2";
    info[@"loginUserId"] = USERID ?: @"0";
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.parmaters = info;
    requestModel.url = CommunityAPI;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        if (ZFJudgeNSDictionary(responseObject[@"data"])) {
            NSDictionary *dic = responseObject[@"data"];
            NSUInteger show = [dic[@"status"] integerValue];
            if (completion) {//1表示有新内容, 2表示没有新内容
                if (show == 1) {
                    completion(YES);
                }else{
                    completion(NO);
                }
            }
        }
        
    } failure:^(NSError *error) {
        if (completion) {
            completion(nil);
        }
    }];
}

@end
