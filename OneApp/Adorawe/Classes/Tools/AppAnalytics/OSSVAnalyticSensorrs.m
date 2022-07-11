//
//  OSSVAnalyticSensorrs.m
// XStarlinkProject
//
//  Created by odd on 2021/2/24.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVAnalyticSensorrs.h"

@implementation OSSVAnalyticSensorrs

+ (void)sensorsDynamicConfigure {
    
    NSInteger isLogin = [OSSVAccountsManager sharedManager].isSignIn ? 1 : 0;
    NSString *languageCode = [STLLocalizationString shareLocalizable].nomarLocalizable;
//    BOOL isAr = [STLLocalizationString isArlanguage:languageCode];
//    NSString *languageString = isAr ? @"Arabic" : @"English";

    
    NSString *adv_utm_source = [OSSVAdvsEventsManager adv_utm_source];
    NSString *adv_utm_medium = [OSSVAdvsEventsManager adv_utm_medium];
    NSString *adv_utm_campaign = [OSSVAdvsEventsManager adv_utm_campaign];
    NSInteger adv_utm_date = [[OSSVAdvsEventsManager adv_utm_date] integerValue];
    NSString *adv_shared_id = [OSSVAdvsEventsManager adv_shared_uid];
    [[SensorsAnalyticsSDK sharedInstance] registerDynamicSuperProperties:^NSDictionary<NSString *,id> * _Nonnull{
        return @{
            @"is_login" : @(isLogin),@"language_choose" : STLToString(languageCode),
            @"starlink_utm_source":adv_utm_source,
            @"starlink_utm_medium":adv_utm_medium,
            @"starlink_utm_campaign":adv_utm_campaign,
            @"starlink_utm_date":@(adv_utm_date),
            @"upper_id":adv_shared_id,
            @"upper_date":@(adv_utm_date),
        };
    }];
}


+ (void)sensorsLogEvent:(NSString *)eventName parameters:(NSDictionary *)parameters {
    
    [[SensorsAnalyticsSDK sharedInstance] track:eventName
                                 withProperties:parameters];
}

+ (void)sensorsLogEventFlush {
    [[SensorsAnalyticsSDK sharedInstance] flush];
}


@end
