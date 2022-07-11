//
//  GBSettingLabelItem.m
//  GearBest
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "GBSettingLabelItem.h"

@implementation GBSettingLabelItem
+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title content:(NSString *)content
{
    GBSettingLabelItem *item = [self itemWithIcon:icon title:title subtitle:nil];
    item.content = content;
    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title content:(NSString *)content
{
    return [self itemWithIcon:nil title:title content:content];
}
@end
