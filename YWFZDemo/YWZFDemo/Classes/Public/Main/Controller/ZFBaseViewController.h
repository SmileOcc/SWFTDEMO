//
//  ZFBaseViewController.h
//  Dezzal
//
//  Created by 7FD75 on 16/7/21.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFStatisticsKey.h"
#import "Constants.h"

@class ZFBTSModel;

@interface ZFBaseViewController : UIViewController

@property (nonatomic, assign) BOOL alreadyEnter;

/// 是否隐藏时间栏（子类复写对应方法，父类暂时没写）
@property (nonatomic, assign) BOOL                 isStatusBarHidden;


/** 自定义模态弹窗动画 顶部间隙 */
@property (nonatomic, assign) CGFloat              topGapHeight;
@property (nonatomic, strong) UIView               *backgroundView;

@property (nonatomic, assign) BOOL is_13PresentationAutomatic;

/**
 * 父类统一布局导航栏左侧搜索按钮
 */
- (UIButton *)showNavigationLeftSearchBtn:(ZF_Statistics_type)statisticsType;

/**
 * 父类统一布局导航栏右侧购物车按钮
 */
- (UIButton *)showNavigationRightCarBtn:(ZF_Statistics_type)statisticsType;

/**
 * 添加一个占位的返回按钮
 */
- (void)bringTempBackButtonToFront;

/**
 * 是否显示一个占位的返回按钮
 */
- (void)showTempBackButtonToFront:(BOOL)show btnImage:(UIImage *)image;

/**
 * 导航栏左上角返回按钮事件
 */
- (void)goBackAction;


//强制横、竖屏
- (void)forceOrientation:(AppForceOrientation)forceOrientation;

@end
