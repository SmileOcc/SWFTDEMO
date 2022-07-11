//
//  OSSVAccountMyWishListsModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccountMyWishListsModel.h"

#import "OSSVAccountMysWishsModel.h"

@implementation OSSVAccountMyWishListsModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"goodList" : [OSSVAccountMysWishsModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"goodList"
             ];
}

@end
