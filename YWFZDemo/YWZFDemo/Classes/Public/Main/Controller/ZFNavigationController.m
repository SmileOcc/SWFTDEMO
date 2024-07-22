//
//  ZFNavigationController.m
//  Dezzal
//
//  Created by 7FD75 on 16/7/21.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "ZFNavigationController.h"
#import "UIImage+ZFExtended.h"
#import "UIImage+ZFExtended.h"
#import "ZFBaseViewController.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "Constants.h"

@interface ZFNavigationController ()
@property (nonatomic, assign) BOOL prohibitPush;
@property (nonatomic, assign) BOOL prohibitPop;
@end

@implementation ZFNavigationController

/**
 *  系统在第一次使用这个类的时候调用(1个类只会调用一次)
 */
+ (void)initialize {
    // 设置NavigationBar背景颜色, 字体颜色, 字体大小
    UINavigationBar *navBar = [UINavigationBar appearance];
    [navBar setBarTintColor:[UIColor whiteColor]];
    [navBar setTintColor:ZFCOLOR(0, 0, 0, 1.0)];
    [navBar setTitleTextAttributes:@{
        NSFontAttributeName: ZFFontBoldSize(18),
        NSForegroundColorAttributeName:ZFCOLOR(51, 51, 51, 1.0)
    }];
    
    UIImage *backImage = [UIImage imageNamed:([SystemConfigUtils isRightToLeftShow] ? @"nav_arrow_right" : @"nav_arrow_left")];
    [navBar setBackIndicatorImage:backImage];
    [navBar setBackIndicatorTransitionMaskImage:backImage];
    
    if(kiOSSystemVersion < 11.0) {
        // 将返回按钮的文字position设置不在屏幕上显示
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
    }
    
    // v5.5.0
    [navBar setShadowImage:[UIImage new]];//去导航线条
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    self.navigationBar.translucent = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNavigationBarSkin) name:kChangeSkinNotification object:nil];
}

/**
 *  重写这个方法,能拦截所有的push操作
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.prohibitPush) {
        self.prohibitPush = NO;
        return;
    }
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    self.prohibitPush = animated;
    
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
    
    if (animated) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            self.prohibitPush = NO;
        });
    }
    
    NSArray *viewControllerArray = [self viewControllers];
    if ([viewControllerArray count] > 1) {
        viewController.navigationItem.hidesBackButton = YES;
        id target = nil;
        if ([viewController isKindOfClass:[ZFBaseViewController class]]) {
            target = viewController;
        }else{
            target = self;
        }
        NSString *imageName = ([SystemConfigUtils isRightToLeftShow] ? @"nav_arrow_right" : @"nav_arrow_left");
        UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                                 style:UIBarButtonItemStylePlain
                                                                                 target:target
                                                                                 action:@selector(goBackAction)];
        viewController.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(0, -8, 0, 0);
    }
}

- (void)goBackAction {
    [self popViewControllerAnimated:YES];
}

/**
 * 服务器换肤数据回调通知
 */
- (void)changeNavigationBarSkin {
    [self.navigationBar zfChangeSkinToSystemNavgationBar];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  拦截所有的pop操作
 */
- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (self.prohibitPop) {
        self.prohibitPop = NO;
        return nil;
    }
    self.prohibitPop = animated;
    
    UIViewController *vc = [super popViewControllerAnimated:animated];
    
    if (animated) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            self.prohibitPop = NO;
        });
    }
    return vc;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if ([self.childViewControllers count]) {
        return [self.childViewControllers lastObject].preferredStatusBarStyle;
    } else {
        return UIStatusBarStyleDefault;
    }
}

/// 当前的导航控制器是否可以旋转
-(BOOL)shouldAutorotate{
    return YES;
}

//设置支持的屏幕旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self cureentSupportedOrientations];
}

//设置presentation方式展示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (!self.interfaceOrientation) {
        self.interfaceOrientation = UIInterfaceOrientationPortrait;
    }
    return self.interfaceOrientation;
}

// 需要设置 UIInterfaceOrientation 支持的，不然会C...
- (UIInterfaceOrientationMask)cureentSupportedOrientations {
    
    UIInterfaceOrientationMask interfaceMask;
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            interfaceMask = UIInterfaceOrientationMaskPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            interfaceMask = UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            interfaceMask = UIInterfaceOrientationMaskLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            interfaceMask = UIInterfaceOrientationMaskLandscapeRight;
            break;
        default:
            interfaceMask = UIInterfaceOrientationMaskAll;
            break;
    }
    return interfaceMask;
}

@end
