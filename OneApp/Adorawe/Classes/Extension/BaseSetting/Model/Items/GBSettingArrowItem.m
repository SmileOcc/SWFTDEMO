//
//  GBSettingArrowItem.m
//  GearBest
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "GBSettingArrowItem.h"

@implementation GBSettingArrowItem
+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title subtitle:(NSString *)subtitle destVcClass:(Class)destVcClass
{
    GBSettingArrowItem *item = [self itemWithIcon:icon title:title subtitle:subtitle];
    item.destVcClass = destVcClass;
    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title destVcClass:(Class)destVcClass
{
    return [self itemWithIcon:nil title:title subtitle:nil destVcClass:destVcClass];
}
@end
