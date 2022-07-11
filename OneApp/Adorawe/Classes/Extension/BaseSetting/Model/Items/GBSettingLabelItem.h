//
//  GBSettingLabelItem.h
//  GearBest
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "GBSettingItem.h"

@interface GBSettingLabelItem : GBSettingItem

+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title content:(NSString *)content;

+ (instancetype)itemWithTitle:(NSString *)title content:(NSString *)content;
@end
