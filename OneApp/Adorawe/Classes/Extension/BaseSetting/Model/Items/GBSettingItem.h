//
//  GBSettingItem.h
//  GearBest
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
//点击该cell的时候执行的操作
typedef void (^SettingItemOption)();
//为cell添加提醒数字badge
typedef int (^AddbBadgeOption)();

@interface GBSettingItem : NSObject
/**
 *  图标
 */
@property (nonatomic, copy) NSString *icon;
/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;

/**
 *  子标题
 */
@property (nonatomic, copy) NSString *subtitle;

/**
 *  头像
 */
@property (nonatomic, copy) NSString *headImage;

/**
 *  label显示的文字
 */
@property (nonatomic, copy) NSString *content;
/**
 *  label显示文字的Color
 */
@property (nonatomic, strong) UIColor *contentColor;

/**
 *  存储数据用的key
 */
//@property (nonatomic, copy) NSString *key;

/**
 *  点击那个cell需要做什么事情
 */
@property (nonatomic, copy) SettingItemOption option;

/**
 *  为这个cell增加数字提醒badge
 */
@property (nonatomic, copy) AddbBadgeOption badgeBlock;

/**
 *  这个主要是为了web页面跳转标识
 */
@property (nonatomic, assign) NSInteger tag;

+ (instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title subtitle:(NSString *)subtitle;
+ (instancetype)itemWithTitle:(NSString *)title;
@end
