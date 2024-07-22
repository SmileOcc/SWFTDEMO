//
//  ZFBaseViewController.m
//  Dezzal
//
//  Created by 7FD75 on 16/7/21.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFStatistics.h"
#import "SystemConfigUtils.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import <GGBrainKeeper/BrainKeeperManager.h>

static char const * const kNavBtnStatisticsTypeKey  = "kNavBtnStatisticsTypeKey";

@interface ZFBaseViewController ()
@property (nonatomic, strong) UIButton  *backButton;
@end

@implementation ZFBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    if (IOS7UP) {
        self.tabBarController.tabBar.translucent = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    // 链路埋点
    [[BrainKeeperManager sharedManager] startLoadWithPageName:nil event:nil target:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    NSString *selfClass = NSStringFromClass(self.class);
    BOOL defaultSkin = [AccountManager sharedManager].needChangeAppSkin;
    BOOL iSLogin = [selfClass isEqualToString:@"YWLoginViewController"];
    
    if (iSLogin || !defaultSkin) {
        //不换肤状态,使用默认状态栏(黑色)
        return UIStatusBarStyleDefault;
    }
    
    //statusBarType (0:黑色, 1:白色)
    BOOL isHome = [selfClass isEqualToString:@"ZFHomePageViewController"];
    ZFSkinModel *skinModel = [AccountManager sharedManager].currentHomeSkinModel;
    NSNumber *statusBarType = isHome ? skinModel.homeNavStatusBarType : skinModel.subNavStatusBarType;
    
    if ([statusBarType boolValue]) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

/** 场景: 部分子类是自定义导航, 在子页面请求时loading会盖住整个页面
 *  网络差时无法点击返回,因此子类懒加载一个返回按钮
 */
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = [UIColor clearColor];
        CGFloat height = IPHONE_X_5_15 ? 94 : 64;
        CGFloat x = [SystemConfigUtils isRightToLeftShow] ? (KScreenWidth - height) : 0;
        _backButton.frame = CGRectMake(x, 0, 64, height);
        [_backButton addTarget:self action:@selector(goBackAction) forControlEvents:UIControlEventTouchUpInside];
        _backButton.imageEdgeInsets = UIEdgeInsetsMake(30, -3, 0, 0);
        [self.view addSubview:_backButton];
    }
    return _backButton;
}

- (void)showTempBackButtonToFront:(BOOL)show btnImage:(UIImage *)image {
    if (show) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.backButton.isHidden) {
                self.backButton.hidden = NO;
                [self.backButton setImage:image forState:UIControlStateNormal];
                [self.view bringSubviewToFront:self.backButton];
            }
        });
    } else {
        self.backButton.hidden = YES;
    }
}

/**
 * 显示一个占位的返回按钮
 */
- (void)bringTempBackButtonToFront {
    self.backButton.hidden = NO;
    [self.view bringSubviewToFront:self.backButton];
}

/**
 * 父类统一布局导航栏左侧搜索按钮
 */
- (UIButton *)showNavigationLeftSearchBtn:(ZF_Statistics_type)statisticsType {
    //搜索按钮
    UIImage *leftImage = [ZFImageWithName(@"search") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIButton *leftNavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftNavBtn setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
    [leftNavBtn setImage:leftImage forState:UIControlStateNormal];
    [leftNavBtn addTarget:self action:@selector(leftSearchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:leftNavBtn];
    self.navigationItem.leftBarButtonItems = @[buttonItem];
    
    //标记类型
    objc_setAssociatedObject(leftNavBtn, kNavBtnStatisticsTypeKey, @(statisticsType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return leftNavBtn;
}

/**
 * 父类统一布局导航栏右侧购物车按钮
 */
- (UIButton *)showNavigationRightCarBtn:(ZF_Statistics_type)statisticsType {
    //购物车按钮
    UIButton *rightNavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightNavBtn setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
    [rightNavBtn setImage:ZFImageWithName(@"public_bag") forState:UIControlStateNormal];
    [rightNavBtn addTarget:self action:@selector(rightSearchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:rightNavBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, buttonItem];
    
    //标记类型
    objc_setAssociatedObject(rightNavBtn, kNavBtnStatisticsTypeKey, @(statisticsType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return rightNavBtn;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _backgroundView.backgroundColor = ZFC0x000000_04();
    }
    return _backgroundView;
}

#pragma mark -===========导航按钮事件===========

/**
 * 导航左侧按钮
 */
- (void)leftSearchBtnClick:(UIButton *)button {
    //搜索按钮统计事件
    NSNumber *type = objc_getAssociatedObject(button, kNavBtnStatisticsTypeKey);
    if (type) {
        [ZFStatistics eventType:[type integerValue]];
    }
    //进入搜索页面
    [self pushToViewController:@"ZFSearchViewController" propertyDic:nil];
}

/**
 * 导航右侧按钮
 */
- (void)rightSearchBtnClick:(UIButton *)button {
    //购物车按钮统计事件
    NSNumber *type = objc_getAssociatedObject(button, kNavBtnStatisticsTypeKey);
    if (type) {
        [ZFStatistics eventType:[type integerValue]];
    }
    //进入购物车页面
    [self pushToViewController:@"ZFCartViewController" propertyDic:nil];
}

/**
 * 导航栏左上角返回按钮事件
 */
-(void)goBackAction {
    NSArray *viewcontrollers=self.navigationController.viewControllers;
    if (viewcontrollers.count > 1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count - 1] == self){
            //push方式
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        //present方式
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma  mark - 强制横、竖屏
//强制横、竖屏
- (void)forceOrientation:(AppForceOrientation)forceOrientation {
    
    APPDELEGATE.forceOrientation = forceOrientation;
    [APPDELEGATE application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
    
    if (forceOrientation == AppForceOrientationJustOnceLandscape || forceOrientation == AppForceOrientationLandscape) {
        
        UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationLandscapeRight;
        ZFNavigationController *nav = (ZFNavigationController *)self.navigationController;
        
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
            YWLog(@"------- lascape---lef");
            interfaceOrientation = UIInterfaceOrientationLandscapeRight;
        } else {
            YWLog(@"------- lascape---right");
            interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
        }
        
        if (nav.interfaceOrientation == interfaceOrientation) {
            YWLog(@"------- lascape--- equal");
            return;
        }
        nav.interfaceOrientation = interfaceOrientation;

        //强制翻转屏幕，Home键在右边。
        [[UIDevice currentDevice] setValue:@(interfaceOrientation) forKey:@"orientation"];
        //刷新
        [UIViewController attemptRotationToDeviceOrientation];
        
    } else if(forceOrientation == AppForceOrientationPortrait){
        
        ZFNavigationController *navi = (ZFNavigationController *)self.navigationController;
        if (navi.interfaceOrientation == UIInterfaceOrientationPortrait) {
            return;
        }
        navi.interfaceOrientation = UIInterfaceOrientationPortrait;
        
        //设置屏幕的转向为竖屏
        [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
        //刷新
        [UIViewController attemptRotationToDeviceOrientation];
    }
}

@end
