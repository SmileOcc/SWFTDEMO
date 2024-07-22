//
//  ZFCategroyWaterfallItemViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/8/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityCategroyPostViewModel.h"
#import "YWLocalHostManager.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"

@interface ZFCommunityCategroyPostViewModel()

@end

@implementation ZFCommunityCategroyPostViewModel


-(void)requestCategroyWaterData:(id)parmaters Completion:(void (^)(ZFCommunityCategoryPostModel *postModel))completion failure:(void (^)(id obj))failure {
    
    NSDictionary *dict = parmaters;
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"type"] = @"9";
    info[@"directory"] = @"74";
    info[@"site"] = @"ZZZZZcommunity";
    info[@"app_type"] = @"2";
    info[@"cat_id"] = ZFToString(dict[@"cat_id"]);
    info[@"loginUserId"] = USERID ?: @"0";
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.parmaters = info;
    requestModel.url = CommunityAPI;
    requestModel.taget = self.controller;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        ZFCommunityCategoryPostModel *postModel = [ZFCommunityCategoryPostModel yy_modelWithJSON:responseObject[@"data"]];
        if (completion) {
            completion(postModel);
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}


@end
