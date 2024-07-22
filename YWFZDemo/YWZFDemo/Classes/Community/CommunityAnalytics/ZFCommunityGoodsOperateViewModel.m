//
//  ZFCommunityGoodsOperateViewModel.m
//  ZZZZZ
//
//  Created by YW on 2019/5/24.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityGoodsOperateViewModel.h"
#import "YWLocalHostManager.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"

@implementation ZFCommunityGoodsOperateViewModel

+ (void)requestGoodsTap:(id)parmaters
            completion:(void (^)(BOOL success))completion
{
    if (!ZFJudgeNSDictionary(parmaters)) {
        return;
    }

    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"type"] = @"6";
    info[@"site"] = @"ZZZZZcommunity";
    info[@"app_type"] = @"2";
    info[@"reviewId"] = ZFToString(parmaters[@"reviewId"]);
    info[@"goods_sku"] = ZFToString(parmaters[@"goods_sku"]);
    info[@"loginUserId"] = USERID ?: @"0";
    //添加一个随机数
    info[@"random"] = [NSString stringWithFormat:@"%d",arc4random() % 10000];
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.parmaters = info;
    requestModel.url = CommunityAPI;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        YWLog(@"%@",responseObject);
        NSDictionary *dict = responseObject;
        BOOL state = NO;
        if ([dict[@"statusCode"] integerValue] == 200) {
            state = YES;
        }
        if (completion) {
            completion(state);
        }
        
    } failure:^(NSError *error) {
        if (completion) {
            completion(NO);
        }
    }];
}

@end
