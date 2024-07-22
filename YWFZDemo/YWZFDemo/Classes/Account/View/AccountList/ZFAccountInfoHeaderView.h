//
//  ZFAccountInfoHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2018/4/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZFAccountInfoStatusType) {
    ZFAccountInfoStatusTypeLogin = 0,
    ZFAccountInfoStatusTypeUnLogin
};

typedef NS_OPTIONS(NSInteger, ZFAccountInfoHeaderOptionType) {
    ZFAccountInfoHeaderOptionTypeSign = 1 << 0,
    ZFAccountInfoHeaderOptionTypeZmeHome = 1 << 1,
    ZFAccountInfoHeaderOptionTypeEditProfile = 1 << 2,
    ZFAccountInfoHeaderOptionTypeChangeAvator = 1 << 3,
};

typedef void(^ZFAccountInfoHeaderActionCompletionHandler)(ZFAccountInfoHeaderOptionType type);

@interface ZFAccountInfoHeaderView : UIView

@property (nonatomic, strong) UIImage                   *editAvatorImage;
//显示状态类型
@property (nonatomic, assign) ZFAccountInfoStatusType   showType;
//点击相应回调
@property (nonatomic, copy)   ZFAccountInfoHeaderActionCompletionHandler        accountInfoHeaderActionCompletionHandler;

// 换肤: by maownagxin
- (void)changeAccountHeadInfoViewSkin;

@end
