//
//  OSSVMyCouponsListsModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMyCouponsListsModel.h"

@implementation OSSVMyCouponsListsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"couponCode" : @"coupon_code",
             @"discountMode" : @"discount_mode",
             @"over" : @"discount_over",
             @"save" : @"discount_save",
             @"startTime" : @"start_time",
             @"endTime" : @"end_time",
             @"userId" : @"user_id",
             @"showFlag" : @"show_flag_type",
             @"isOnlyApp" : @"is_only_app",
             @"condition" : @"goods_condition_string",
             @"uc_id" : @"uc_id",
             @"is_new": @"is_new",
             };
}
@end

