//
//  OSSVNavigationVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVNavigationVC.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import "Adorawe-Swift.h"

@interface OSSVNavigationVC ()
<
    UINavigationControllerDelegate
>

@property (nonatomic, assign) BOOL prohibitPush;
@property (nonatomic, assign) BOOL prohibitPop;

@end

@implementation OSSVNavigationVC


+ (void)initialize {
    //设置背景图片
    NSString *bgName = @"";//@"nav_bg";
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:bgName] forBarMetrics:UIBarMetricsDefault];
    [UINavigationBar appearance].backgroundColor = UIColor.whiteColor;

    //设置NavigationBar背景颜色
    [[UINavigationBar appearance] setBarTintColor:[OSSVThemesColors stlWhiteColor]];
    [[UINavigationBar appearance] setTintColor:[OSSVThemesColors col_262626]];
    
 
    
    // 将返回按钮的文字position设置不在屏幕上显示
    if (DSYSTEM_VERSION < 11) {
        //设置全局返回按钮样式
        [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:[OSSVSystemsConfigsUtils isRightToLeftShow] ? @"arrow_right_new" : @"arrow_left_new"]];
        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:[OSSVSystemsConfigsUtils isRightToLeftShow] ? @"arrow_right_new" : @"arrow_left_new"]];
    } else {
        [UINavigationBar appearance].backIndicatorImage = [UIImage imageNamed:@"arrow_left_new"];
        [UINavigationBar appearance].backIndicatorTransitionMaskImage = [UIImage imageNamed:@"arrow_left_new"];
    }

    //设置item普通状态
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:16];
    attrs[NSForegroundColorAttributeName] = OSSVThemesColors.col_333333;
    [[UIBarButtonItem appearance] setTitleTextAttributes:attrs forState:UIControlStateNormal];

    //设置item不可用状态
    NSMutableDictionary *disabledAttrs = [NSMutableDictionary dictionary];
    disabledAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    disabledAttrs[NSForegroundColorAttributeName] = [UIColor lightGrayColor];
    [[UIBarButtonItem appearance] setTitleTextAttributes:disabledAttrs forState:UIControlStateDisabled];
    
    //设置导航栏字体颜色及大小
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[OSSVThemesColors col_000000:1.0],NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    self.navigationBar.translucent = NO;
    self.delegate = self;
    [self.navigationBar setBarStyle:UIBarStyleDefault];
     
     if (@available(iOS 15, *)) {
         UINavigationBarAppearance *app = [[UINavigationBarAppearance alloc] init];
         [app configureWithOpaqueBackground];
         app.backgroundColor = [OSSVThemesColors stlWhiteColor];
         app.shadowImage = [UIImage yy_imageWithColor:UIColor.whiteColor];
         self.navigationBar.scrollEdgeAppearance = app;
         self.navigationBar.standardAppearance = app;
     }
   
}

- (void)config {
    NSString *backImageName = @"return_nav";
    
    UIImage *image = [UIImage imageNamed:backImageName];
    CGFloat w = image.size.width;
    if (SCREEN_WIDTH <= 320) {
        w = 30;
    }
    self.navigationBar.backIndicatorImage = image;
    UIImage *backButtonImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, w, 0, -w)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    // 将返回按钮的文字position设置不在屏幕上显示
    if (DSYSTEM_VERSION < 11) {
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
    }
    self.interactivePopGestureRecognizer.enabled = YES;
    return;
}

//重写这个方法,能拦截所有的push操作
//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    if (self.viewControllers.count > 0) {
//        viewController.hidesBottomBarWhenPushed = YES;
//    }
//    [super pushViewController:viewController animated:animated];
//}

/**
 *  重写这个方法,能拦截所有的push操作
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    if (self.prohibitPush) {
//        self.prohibitPush = NO;
//        return;
//    }
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    self.prohibitPush = animated;
    
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
    
//    if (animated) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
//            self.prohibitPush = NO;
//        });
//    }
    
    NSArray *viewControllerArray = [self viewControllers];
    if ([viewControllerArray count] > 1) {
        viewController.navigationItem.hidesBackButton = YES;
        id target = nil;
        if ([viewController isKindOfClass:[STLBaseCtrl class]]) {
            target = viewController;
        }else{
            target = self;
        }
        NSString *imageName = ([OSSVSystemsConfigsUtils isRightToLeftShow] ? @"arrow_right_new" : @"arrow_left_new");
        UIImage *image = [UIImage imageNamed:imageName];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        [backButton setImage:image forState:UIControlStateNormal];
        [backButton addTarget:target action:@selector(goBackAction) forControlEvents:UIControlEventTouchUpInside];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            viewController.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        } else {
            viewController.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(0, -6, 0, 0);
        }
    }
}

- (void)goBackAction {
    [self popViewControllerAnimated:YES];
}
@end
