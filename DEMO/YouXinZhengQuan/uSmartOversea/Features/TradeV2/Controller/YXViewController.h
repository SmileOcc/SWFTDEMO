//
//  YXViewController.h
//  YouXinZhengQuan
//
//  Created by RuiQuan Dai on 2018/7/2.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXViewModel.h"

#import "YXStrongNoticeView.h"
#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YXMessageButton2;

@interface YXViewController : QMUICommonViewController
@property (nonatomic, strong, readonly) YXViewModel *viewModel;
@property (nonatomic, strong, readonly) UIPercentDrivenInteractiveTransition *interactivePopTransition;

//emptyLoadingStyle
@property (nonatomic, assign) UIActivityIndicatorViewStyle emptyIndicatorViewStyle;

//是否进入时是横屏页面
@property (nonatomic, assign) BOOL forceToLandscapeRight;

@property (nonatomic, strong, readonly) UIBarButtonItem *messageItem;

//强通知
@property (nonatomic, strong, readonly) YXStrongNoticeView *strongNoticeView;

@property (nonatomic, strong, nullable) UIView *snapshot;
// 设置viewController的状态栏样式
//@property(readwrite, nonatomic) UIStatusBarStyle statusBarStyle;

- (instancetype)initWithViewModel:(YXViewModel *)viewModel;

- (void)bindViewModel;

////返回按钮是否隐藏 YES 隐藏 NO不隐藏  默认NO 需子类重写
//- (BOOL)isBackBtnHidden;
//
////底部线是否隐藏 YES 隐藏 NO不隐藏  默认YES 需子类重写
//- (BOOL)isBottomLineHidden;
//
////导航栏是否隐藏  YES 隐藏 NO 不隐藏 默认 NO 需子类重写
//- (BOOL)isNavigationBarHidden;

/// 定位偶现tabbar不显示的问题，初步怀疑可能是tabbar hidden为了YES;因此在首页、资讯、智投、个人中心和交易等页面设置一下tabbar的显示状态
- (void)setTabbarVisibleIfNeed;

#pragma mark- hud相关
- (void)showLoading:(NSString *)message;
- (void)showText:(NSString *)message;
- (void)showError:(NSString *)message;
- (void)showSuccess:(NSString *)message;

- (void)showLoading:(NSString *)message inView:(UIView *)view;
- (void)showText:(NSString *)message inView:(UIView *)view;
- (void)showError:(NSString *)message inView:(UIView *)view;
- (void)showSuccess:(NSString *)message inView:(UIView *)view;

- (void)hideHud;

@end

NS_ASSUME_NONNULL_END
