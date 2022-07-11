//
//  OSSVCartCouponSelectModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartCouponSelectModel.h"

#import "OSSVMyCouponsListsModel.h"

@implementation OSSVCartCouponSelectModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"available" : [OSSVMyCouponsListsModel class],
             @"unavailable" : [OSSVMyCouponsListsModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[@"available",@"unavailable"];
}

@end
