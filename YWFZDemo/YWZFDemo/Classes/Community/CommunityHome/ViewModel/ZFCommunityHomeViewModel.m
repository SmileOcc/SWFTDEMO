//
//  ZFCommunityHomeViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/7/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityHomeViewModel.h"
#import "ZFBannerModel.h"
#import "YWLocalHostManager.h"
#import "ZFProgressHUD.h"
#import "ZFAnalytics.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"

@interface ZFCommunityHomeViewModel ()

@property (nonatomic, assign) NSInteger                     pageNum;
@property (nonatomic, strong) NSMutableArray                *tableDataArr;
@property (nonatomic, strong) ZFCommunityChannelModel       *channelModel;

@end

@implementation ZFCommunityHomeViewModel


- (void)requestDiscoverChannelCompletion:(void (^)(ZFCommunityChannelModel *channelModel))completion {
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"type"] = @"9";
    info[@"directory"] = @"75";
    info[@"site"] = @"ZZZZZcommunity";
    info[@"app_type"] = @"2";
    info[@"userId"] = USERID?:@"";
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    
    requestModel.isCommunityRequest = YES;
    requestModel.parmaters = info;
    requestModel.url = CommunityAPI;
    requestModel.needToCache = YES;

    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        ZFCommunityChannelModel *channelModel = [ZFCommunityChannelModel yy_modelWithJSON:responseObject];
        //限制返回个数最多为10个
        if (ZFJudgeNSArray(channelModel.data)) {
            if (channelModel.data.count > 10) {
                NSMutableArray *tenDatas = [[NSMutableArray alloc] initWithArray:channelModel.data];
                [tenDatas removeObjectsInRange:NSMakeRange(10, channelModel.data.count - 10)];
                channelModel.data = tenDatas;
            }
        }
        self.channelModel = channelModel;
        if (completion) {
            completion(channelModel);
        }
        
    } failure:^(NSError *error) {
        ShowToastToViewWithText(nil, error.domain);
        if (completion) {
            completion(nil);
        }
    }];
}

- (void)requestFollowHaveNewMessageCompletion:(void (^)(BOOL isNewMessage))completion
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"type"] = @"9";
    info[@"directory"] = @"72";
    info[@"site"] = @"ZZZZZcommunity";
    info[@"app_type"] = @"2";
    info[@"userId"] = USERID ?: @"0";
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.parmaters = info;
    requestModel.url = CommunityAPI;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        //此接口只有第一页有 bannerlist, topicList数据, 分页数据时, 此model有可能返回nil
        if (ZFJudgeNSDictionary(responseObject[@"data"])) {
            NSDictionary *dic = responseObject[@"data"];
            NSUInteger show = [dic[@"status"] integerValue];
            if (completion) {
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
