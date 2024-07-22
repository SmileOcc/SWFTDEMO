//
//  ZFCMSSKUBannerAnalyticsAOP.h
//  ZZZZZ
//
//  Created by YW on 2018/10/9.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//  首页SKUBanner统计AOP
//  使用于 ZFHomeSKUBannerCell

#import "ZFCMSBaseAnalyticsAOP.h"
#import "AnalyticsInjectManager.h"
#import "ZFAnalyticsInjectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCMSSKUBannerAnalyticsAOP : ZFCMSBaseAnalyticsAOP
<
    ZFAnalyticsInjectProtocol
>

@property (nonatomic, assign) NSInteger branch;
///SKU Banner Name
@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *channel_id;
@property (nonatomic, copy) NSString *channel_name;

- (void)baseConfigureSource:(ZFAnalyticsAOPSource)source analyticsId:(NSString *)idx;
@end


NS_ASSUME_NONNULL_END
