//
//  ZFTrackerWhiteListManager.m
//  ZZZZZ
//
//  Created by YW on 2019/2/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFTrackerWhiteListManager.h"
#import "ZFHomeCMSViewController.h"
#import "GGViewTrackerManager.h"
#import "GGTrackerCommitProxy.h"

#import "YWLocalHostManager.h"
#import "ZFCMSHomeAnalyticsAOP.h"

@interface ZFTrackerWhiteListManager ()

/**
 *  统计代码白名单列表
 *  方便全局统一查看哪些控制器有统计需求
 */
- (NSArray<NSString *> *)trackerControllerWhiteList;

@property (nonatomic, strong) NSMutableDictionary <NSString *, id<ZFAnalyticsInjectProtocol>> *trackAop;

@end

@implementation ZFTrackerWhiteListManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZFTrackerWhiteListManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZFTrackerWhiteListManager alloc] init];
    });
    return manager;
}

-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.trackAop = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)startTrack
{
    GGViewTrackerManager *manager = [GGViewTrackerManager sharedManager];
    GGViewTrackerConfigModel *config = [[GGViewTrackerConfigModel alloc] init];
    config.exposureSwitch = YES;
    manager.config = config;
    if ([YWLocalHostManager isOnlineRelease]) {
        manager.isDebugModeOn = NO;
        config.exposureUploadMode = GGExposureDataUploadModePolymer;
    }else{
        manager.isDebugModeOn = YES;
        config.exposureUploadMode = GGExposureDataUploadModeSingleInPage;
    }
    manager.commitProtocol = [GGTrackerCommitProxy new];
    [manager setViewTrackerConfig:@{kExposureWhiteList : [self trackerControllerWhiteList]}];
}


- (id<ZFAnalyticsInjectProtocol>)gainAnalyticsInjectWithPageName:(NSString *)pageName
{
    if (self.trackAop[pageName]) {
        return self.trackAop[pageName];
    }
    Class injectClass = [self injectClassWithPageName:pageName];
    if (injectClass) {
        id<ZFAnalyticsInjectProtocol>injectObject = [[injectClass alloc] init];
        self.trackAop[pageName] = injectObject;
        return injectObject;
    }
    return nil;
}

- (Class)injectClassWithPageName:(NSString *)pageName
{
    if ([pageName isEqualToString:NSStringFromClass(ZFHomeCMSViewController.class)]) {
        return ZFCMSHomeAnalyticsAOP.class;
    }
    return nil;
}

- (NSArray<NSString *> *)trackerControllerWhiteList
{
    NSArray *list = @[
                      NSStringFromClass(ZFHomeCMSViewController.class),
                      ];
    return list;
}

@end
