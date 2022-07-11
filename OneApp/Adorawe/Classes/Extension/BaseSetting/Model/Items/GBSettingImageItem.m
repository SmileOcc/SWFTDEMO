//
//  GBSettingImageItem.m
//  GearBest
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "GBSettingImageItem.h"

@implementation GBSettingImageItem
+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title image:(NSString *)image
{
    GBSettingImageItem *item = [[self alloc] init];
    item.icon = icon;
    item.title = title;
    item.headImage = image;
    return item;
}


+ (instancetype)itemWithTitle:(NSString *)title image:(NSString *)image
{
    return [self itemWithIcon:nil title:title image:image];
}
@end
