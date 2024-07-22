//
//  ZFBKManager.m
//  ZZZZZ
//
//  Created by YW on 2019/7/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBKManager.h"
#import <GGBrainKeeper/BrainKeeperManager.h>
#import "NSStringUtils.h"
#import "YWCFunctionTool.h"

@implementation ZFBKManager

+ (instancetype)sharedManager {
    static ZFBKManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZFBKManager alloc] init];
    });
    
    return manager;
}

#pragma mark ========= ZFNetworkDelegate =============
/**
 请求开始
 
 @param requestModel 请求对象
 */
- (void)zfNetworkStartRequestWithModel:(ZFNetworkRequestModel *)requestModel {
    if ([requestModel isKindOfClass:[ZFRequestModel class]]) {
        ZFRequestModel *zfRequestModel = (ZFRequestModel *)requestModel;
        if (![NSStringUtils isEmptyString:zfRequestModel.eventName]) {
            // 事件链路
            zfRequestModel.span = [[BrainKeeperManager sharedManager] startNetWithPageName:zfRequestModel.pageName event:zfRequestModel.eventName target:zfRequestModel.taget url:requestModel.url parentId:nil isNew:YES isChained:zfRequestModel.isChained];
        } else {
            // 页面链路
            if (zfRequestModel.taget && [zfRequestModel.taget isKindOfClass:[ZFBaseViewController class]]) {
                zfRequestModel.span = [[BrainKeeperManager sharedManager] startNetWithPageName:nil event:nil target:zfRequestModel.taget url:requestModel.url parentId:nil isNew:NO isChained:zfRequestModel.isChained];
            }
        }
    }
}

/**
 请求成功
 
 @param requestModel 请求对象
 */
- (void)zfNetworkRequestSuccessWithModel:(ZFNetworkRequestModel *)requestModel {
    if ([requestModel isKindOfClass:[ZFRequestModel class]]) {
        ZFRequestModel *zfRequestModel = (ZFRequestModel *)requestModel;
        if (zfRequestModel.span) {
            [zfRequestModel.span end];
            if (![NSStringUtils isEmptyString:zfRequestModel.eventName]) {
                // 事件链路
                if (!zfRequestModel.notAutoSubmit) {
                    [[BrainKeeperManager sharedManager] subTrackWithPageName:zfRequestModel.pageName event:zfRequestModel.eventName target:zfRequestModel.taget];
                }
            } else {
                // 页面链路
            }
        }
    }
}

/**
 请求失败
 
 @param requestModel 请求对象
 @param error 失败参数
 */
- (void)zfNetworkRequestErrorWithModel:(ZFNetworkRequestModel *)requestModel error:(NSError *)error {
    if ([requestModel isKindOfClass:[ZFRequestModel class]]) {
        ZFRequestModel *zfRequestModel = (ZFRequestModel *)requestModel;
        if (zfRequestModel.span) {
            // 过滤取消请求链路
            if (error.code == -999 || [error.localizedDescription isEqualToString:@"cancelled"]) return;
            [zfRequestModel.span endWithError:ZFToString(error.userInfo[NSRecoveryAttempterErrorKey]) statusCode:error.userInfo[NSHelpAnchorErrorKey]];
            if (![NSStringUtils isEmptyString:zfRequestModel.eventName]) {
                // 事件链路
                if (!zfRequestModel.notAutoSubmit) {
                    [[BrainKeeperManager sharedManager] subTrackWithPageName:zfRequestModel.pageName event:zfRequestModel.eventName target:zfRequestModel.taget];
                }
            } else {
                // 页面链路
                if (!zfRequestModel.notAutoSubmit) {
                    [[BrainKeeperManager sharedManager] subTrackWithPageName:nil event:nil target:zfRequestModel.taget];
                }
            }
        }
    }
}

/**
 渲染结束自动提交链路
 
 @param requestModel 请求对象
 */
- (void)zfNetworkRenderEndSubTrackWithModel:(ZFNetworkRequestModel *)requestModel {
    if ([requestModel isKindOfClass:[ZFRequestModel class]]) {
        ZFRequestModel *zfRequestModel = (ZFRequestModel *)requestModel;
        if (zfRequestModel.taget && [zfRequestModel.taget isKindOfClass:[ZFBaseViewController class]] && !zfRequestModel.notAutoSubmit && [NSStringUtils isEmptyString:zfRequestModel.eventName]) {
            [[BrainKeeperManager sharedManager] endRenderAndTrackWithPageName:nil event:nil target:zfRequestModel.taget];
        }
    }
}

@end
