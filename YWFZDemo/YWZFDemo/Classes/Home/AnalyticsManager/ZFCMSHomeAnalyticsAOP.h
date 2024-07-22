//
//  ZFCMSHomeAnalyticsAOP.h
//  ZZZZZ
//
//  Created by YW on 2018/12/24.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//   

#import "ZFCMSBaseAnalyticsAOP.h"
#import "AnalyticsInjectManager.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const TrackerCustomeArgsRow;
UIKIT_EXTERN NSString *const TrackerCustomeArgsSection;
UIKIT_EXTERN NSString *const TrackerCustomeArgsModel;
UIKIT_EXTERN NSString *const TrackerCustomePublicParams;

UIKIT_EXTERN NSString *const TrackerCustomePublicParamsisHome;
UIKIT_EXTERN NSString *const TrackerCustomePublicParamsAfParams;
UIKIT_EXTERN NSString *const TrackerCustomePublicParamsChannelId;
UIKIT_EXTERN NSString *const TrackerCustomePublicParamsChannelTitle;

@interface ZFCMSHomeAnalyticsAOP : ZFCMSBaseAnalyticsAOP
<
    ZFAnalyticsInjectProtocol
>

///因为首页是多频道
- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx;

///如果不为空就是首页，为空就是推荐分区
@property (nonatomic, assign) BOOL isHomePage;

///首页推荐商品实验id
@property (nonatomic, strong) NSDictionary *af_params;

///channel_id
@property (nonatomic, copy) NSString *channel_id;

///频道名
@property (nonatomic, copy) NSString *channel_name;

@end

NS_ASSUME_NONNULL_END
