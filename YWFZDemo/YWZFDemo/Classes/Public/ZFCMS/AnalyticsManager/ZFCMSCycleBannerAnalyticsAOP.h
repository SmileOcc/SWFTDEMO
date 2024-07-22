//
//  ZFCMSCycleBannerAnalyticsAOP.h
//  ZZZZZ
//
//  Created by YW on 2018/10/17.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  顶部广告统计AOP
//  使用于 ZFHomeCycleBannerCell
//  使用于 ZFCMSCycleBannerCell

#import "ZFCMSBaseAnalyticsAOP.h"
#import "AnalyticsInjectManager.h"
#import "ZFAnalyticsInjectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCMSCycleBannerAnalyticsAOP : ZFCMSBaseAnalyticsAOP
<
    ZFAnalyticsInjectProtocol
>
- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx;

@property (nonatomic, copy) NSString *channel_name;

@end

NS_ASSUME_NONNULL_END

