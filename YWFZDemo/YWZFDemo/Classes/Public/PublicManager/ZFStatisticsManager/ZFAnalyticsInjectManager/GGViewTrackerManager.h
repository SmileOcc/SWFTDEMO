//
//  GGViewTrackerManager.h
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "GGTrackerCommitProtocol.h"
#import "GGViewTrackerConfigModel.h"

/*
 Note:
 GGViewTrackerManager *manager = [GGViewTrackerManager sharedManager];
 GGViewTrackerConfigModel *config = [[GGViewTrackerConfigModel alloc] init];
 config.exposureSwitch = YES;
 manager.config = config;
 manager.commitProtocol = [id<GGTrackerCommitProtocol> new];
 [manager setViewTrackerConfig:@{ kExposureWhiteList : @[@"ViewController"] }];
 */

/**
 *  可通过发送TMViewTrackerManagerInitSwitchsNotification通知，来初始化开关
 *
 */
UIKIT_EXTERN NSString *const GGViewTrackerInitSwitchesNotification;

//ViewTrackerConfig的key值
UIKIT_EXTERN NSString *const kExposureSwitch;       //BOOL
UIKIT_EXTERN NSString *const kExposureBatchOpen;
UIKIT_EXTERN NSString *const kExposureUploadMode;   //NSUInteger, 0, normal; 1. PolyerUpload; 2. Single In Page
UIKIT_EXTERN NSString *const kExposureTimeThreshold;//NSUInteger (ms)
UIKIT_EXTERN NSString *const kExposureDimThreshold; //float
UIKIT_EXTERN NSString *const kExposureWhiteList;    //NSArray
UIKIT_EXTERN NSString *const kExposureSampling;     //NSUInteger, 0-10000

UIKIT_EXTERN NSString *const kClickSwitch;          //BOOL
UIKIT_EXTERN NSString *const kClickWhiteList;       //NSArray
UIKIT_EXTERN NSString *const kClickSampling;        //NSUInteger, 0-10000

@interface GGViewTrackerManager : NSObject

@property (nonatomic, strong) id<GGTrackerCommitProtocol> commitProtocol;
+ (instancetype)sharedManager;

+ (void)setCurrentPageName:(NSString*)pageName;
+ (NSString*)currentPageName;


+ (void)turnOnDebugMode;
+ (void)turnOffDebugMode;

/**
 set config for switches
 
 @param config key为上面的值。
 */
- (void)setViewTrackerConfig:(NSDictionary*)config;

//特殊用途，用于开关设置较晚，不能拿到view曝光初始状态时，调用该函数强制将某个view及子view中满足条件的view置为开始曝光。
//该方法会下层遍历，直到找到满足条件的叶子view。
+ (void)forceBeginExposureForView:(UIView*)view;

+ (void)resetPageIndexOnCurrentPage;


@property (nonatomic, strong) GGViewTrackerConfigModel *config;
@property (nonatomic, assign) BOOL isDebugModeOn;

- (BOOL)exposureNeedUpload:(UIView*)view;
- (BOOL)exposureNeedUploadWithWhiteList:(UIView*)view;
- (BOOL)isPageNameInExposureWhiteList:(NSString*)pageName;

- (NSUInteger)exposureTimeThreshold;
- (CGFloat)exposureDimThreshold;

- (BOOL)isClickHitSampling;
- (BOOL)isExposureHitSampling;

@end

