//
//  ZFCMSRecentlyAnalyticsAOP.h
//  ZZZZZ
//
//  Created by YW on 2018/10/9.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  历史浏览记录统计AOP
//  使用于 ZFRecentlyCollectionReusableView

#import "ZFCMSBaseAnalyticsAOP.h"
#import "AnalyticsInjectManager.h"
#import "ZFAnalyticsInjectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCMSRecentlyAnalyticsAOP : ZFCMSBaseAnalyticsAOP
<
    ZFAnalyticsInjectProtocol
>

@property (nonatomic, copy) NSString *channel_id;
@property (nonatomic, copy) NSString *channel_name;

- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx;

@end


NS_ASSUME_NONNULL_END
