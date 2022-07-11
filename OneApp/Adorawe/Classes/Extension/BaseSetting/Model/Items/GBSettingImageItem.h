//
//  GBSettingImageItem.h
//  GearBest
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "GBSettingItem.h"

@interface GBSettingImageItem : GBSettingItem
+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title image:(NSString *)image;

+ (instancetype)itemWithTitle:(NSString *)title image:(NSString *)image;
@end
