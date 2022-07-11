//
//  GBSettingArrowItem.h
//  GearBest
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "GBSettingItem.h"

@interface GBSettingArrowItem : GBSettingItem
/**
 *  点击这行cell需要跳转的控制器
 */
@property (nonatomic, assign) Class destVcClass;

//@property (nonatomic, assign)  MJSettingArrowItemVcShowType  vcShowType;

+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title subtitle:(NSString *)subtitle destVcClass:(Class)destVcClass;
+ (instancetype)itemWithTitle:(NSString *)title destVcClass:(Class)destVcClass;
@end
