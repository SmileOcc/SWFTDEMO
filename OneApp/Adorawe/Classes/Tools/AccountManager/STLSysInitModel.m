//
//  STLSysInitModel.m
// XStarlinkProject
//
//  Created by fan wang on 2021/8/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLSysInitModel.h"

@implementation STLSysInitModel
+(NSDictionary<NSString *,id> *)modelCustomPropertyMapper{
    return @{
        @"latitude"                :@"lat_long_info.latitude",
        @"longitude"               :@"lat_long_info.longitude",
        @"abtest_switch"           :@"abtest_switch",
        @"recommend_abtest_switch" :@"recommend_ab_switch",
        @"isShowWhatsAppSubscribe" : @"show_what_apps_subscribe"
    };
}
@end
