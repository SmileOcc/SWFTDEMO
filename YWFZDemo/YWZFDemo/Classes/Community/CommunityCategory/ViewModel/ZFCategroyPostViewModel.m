//
//  ZFCategroyWaterfallItemViewModel.m
//  Zaful
//
//  Created by occ on 2018/8/15.
//  Copyright © 2018年 Zaful. All rights reserved.
//

#import "ZFCommunityCategroyPostViewModel.h"


@interface ZFCommunityCategroyPostViewModel()

@end

@implementation ZFCommunityCategroyPostViewModel


-(void)requestCategroyWaterData:(id)parmaters Completion:(void (^)(ZFCategoryPostModel *postModel))completion failure:(void (^)(id obj))failure {
    
    NSDictionary *dict = parmaters;
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"type"] = @"9";
    info[@"directory"] = @"74";
    info[@"site"] = @"zafulcommunity";
    info[@"app_type"] = @"2";
    info[@"cat_id"] = ZFToString(dict[@"cat_id"]);
    info[@"loginUserId"] = USERID ?: @"0";
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.parmaters = info;
    requestModel.url = CommunityAPI;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
        ZFCategoryPostModel *postModel = [ZFCategoryPostModel yy_modelWithJSON:responseObject[@"data"]];
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
