//
//  ZFAccountNavigationView.h
//  ZZZZZ
//
//  Created by YW on 2018/5/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ZFAccountNavigationAction_UserImageType = 2019,
    ZFAccountNavigationAction_UserNameType,
    ZFAccountNavigationAction_CartType,
    ZFAccountNavigationAction_HelpType,
    ZFAccountNavigationAction_SettingType,
} ZFAccountNavigationActionType;

@interface ZFAccountNavigationView : UIView

@property (nonatomic, copy) void (^jumpToCartVCBlock)(void);
@property (nonatomic, copy) void (^jumpToSettingVCBlock)(void);
@property (nonatomic, copy) void (^jumpToHelpVCBlock)(void);

@property (nonatomic, copy) void (^actionTypeBlock)(ZFAccountNavigationActionType actionType);

- (void)refreshCartNumberInfo;

- (void)refreshBackgroundColorAlpha:(CGFloat)alpha;

- (void)configNavgationUserInfo;

// 处理导航背景色
- (void)changeAccountNavigationNavSkin;

@end
