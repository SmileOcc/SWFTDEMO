//
//  UIViewController+STLCategory.m
// XStarlinkProject
//
//  Created by odd on 2020/7/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "UIViewController+STLCategory.h"
#import <objc/runtime.h>
#import "AppDelegate+STLCategory.h"

static char *leftBarItemBlockKey  = "leftBarItemBlockKey";
static char *rightBarItemBlockKey = "rightBarItemBlockKey";

@implementation UIViewController (STLCategory)

/**
 * 切换语言后切换系统UI布局方式
 */
+ (void)convertAppUILayoutDirection
{
    // 切换语言关键: 设置系统布局样式 (左到右, 右到左)
    if ([OSSVSystemsConfigsUtils isCanRightToLeftShow]) {
        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    } else {
        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    }
    
//    // 设置导航全局返回按钮图片
//    UIImage *backImage = [UIImage imageNamed:([OSSVSystemsConfigsUtils isRightToLeftShow] ? @"nav_arrow_right" : @"nav_arrow_left")];
//    [[UINavigationBar appearance] setBackIndicatorImage:backImage];
//    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backImage];
}

/** 获取当前控制器 */
+ (UIViewController *)currentTopViewController
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];

    //当前windows的根控制器
    UIViewController *controller = window.rootViewController;

    //通过循环一层一层往下查找
    while (YES) {
        //先判断是否有present的控制器
        if (controller.presentedViewController && ![controller.presentedViewController isKindOfClass:STLAlertViewController.class]) {
            //有的话直接拿到弹出控制器，省去多余的判断
            controller = controller.presentedViewController;
        } else {
            if ([controller isKindOfClass:[UINavigationController class]]) {
                //如果是NavigationController，取最后一个控制器（当前）
                controller = [controller.childViewControllers lastObject];
            } else if ([controller isKindOfClass:[UITabBarController class]]) {
                //如果TabBarController，取当前控制器
                UITabBarController *tabBarController = (UITabBarController *)controller;
                controller = tabBarController.selectedViewController;
            } else {
                if (controller.childViewControllers.count > 0) {
                    //如果是普通控制器，找childViewControllers最后一个
                    controller = [controller.childViewControllers lastObject];
                } else {
                    //没有present，没有childViewController，则表示当前控制器
                    return controller;
                }
            }
        }
    }
}

/**
 *  获取App最顶层的控制器
 */
+ (UIViewController *)lastNavTopViewController {
    
//    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//
//    //当前windows的根控制器
//    UIViewController *controller = window.rootViewController;
//    //通过循环一层一层往下查找
//    while (YES) {
//        //先判断是否有present的控制器
//        if (controller.presentedViewController && ![controller.presentedViewController isKindOfClass:STLAlertViewController.class]) {
//            //有的话直接拿到弹出控制器，省去多余的判断
//            controller = controller.presentedViewController;
//        } else {
//            if ([controller isKindOfClass:[UINavigationController class]]) {
//                //如果是NavigationController，取最后一个控制器（当前）
//                controller = [controller.childViewControllers lastObject];
//            } else if ([controller isKindOfClass:[UITabBarController class]]) {
//                //如果TabBarController，取当前控制器
//                UITabBarController *tabBarController = (UITabBarController *)controller;
//                controller = tabBarController.selectedViewController;
//            } else {
//                if (controller.childViewControllers.count > 0) {
//                    //如果是普通控制器，找childViewControllers最后一个
//                    controller = [controller.childViewControllers lastObject];
//                } else {
//                    //没有present，没有childViewController，则表示当前控制器
////                    return controller;
//                    break;
//                }
//            }
//        }
//    }
//
    
    UIViewController *controller;
//    if (!controller.navigationController) {
        OSSVTabBarVC *tab = [AppDelegate mainTabBar];
        NSInteger currentIndex = tab.selectedIndex;
        
        OSSVNavigationVC *nav = [tab navigationControllerWithMoudle:currentIndex];
        controller = nav.viewControllers.lastObject;
        
//    }
    
    return controller;
}

+ (NSString *)currentTopViewControllerPageName {
    UIViewController *viewCtrl = [UIViewController currentTopViewController];
    NSString *pageName = NSStringFromClass(viewCtrl.class);
    return pageName;
}

+ (NSString *)lastViewControllerPageName {
    UIViewController *viewCtrl = [UIViewController currentTopViewController];
    NSString *pageName = NSStringFromClass(viewCtrl.class);
    if (viewCtrl.navigationController) {
        NSArray *viewCtrls = viewCtrl.navigationController.viewControllers;
        
        if (viewCtrls.count > 1) {
            UIViewController *lastCtrl = viewCtrls[viewCtrls.count-2];
            pageName = NSStringFromClass(lastCtrl.class);
        }
    }
    
    return pageName;
}

/**
 *  判断在导航栏控制器中有没存在该类
 *
 *  @param className 类名
 *
 *  @return 返回存在的控制器  没有存在则为nil
 */
- (UIViewController *)isExistClassInSelfNavigation:(NSString *)className
{
    UIViewController *existVC = nil;
    if (className.length>0) {
        for (UIViewController *tempVC in self.navigationController.viewControllers) {
            if ([tempVC isKindOfClass:NSClassFromString(className)]) {
                existVC = tempVC;
                break;
            }
        }
    }
    return existVC;
}


/**
 *  执行push页面跳转
 *
 *  @param vcName 当前的控制器
 *  @param propertyDic 控制器需要的参数
 */
- (void)pushToViewController:(NSString *)vcName
                 propertyDic:(NSDictionary *)propertyDic
{
    //执行push页面跳转
    [self pushToViewController:vcName propertyDic:propertyDic animated:YES];
}

/**
 *  执行push页面跳转
 *
 *  @param vcName 当前的控制器
 *  @param propertyDic 控制器需要的参数
 *  @param animated 是否显示动画
 */
- (void)pushToViewController:(NSString *)vcName
                 propertyDic:(NSDictionary *)propertyDic
                    animated:(BOOL)animated
{
    if (propertyDic && ![propertyDic isKindOfClass:[NSDictionary class]]) {
        STLLog(@"❌❌❌ 页面push失败，携带属性字典错误:%@",propertyDic);
        return;
    }
    UIViewController *pushVC = [[NSClassFromString(vcName) alloc] init];
    if (![pushVC isKindOfClass:[UIViewController class]]) {
        STLLog(@"❌❌❌ 页面push失败，名称对应的控制器不存在: %@",vcName);
        return;
    }
    
    if (propertyDic && [propertyDic isKindOfClass:[NSDictionary class]]) {
        [pushVC setValuesForKeysWithDictionary:propertyDic];
    }
    pushVC.hidesBottomBarWhenPushed = YES;
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)self pushViewController:pushVC animated:animated];
    } else {
        [self.navigationController pushViewController:pushVC animated:animated];
    }
}

#pragma mark - (Navigation)

- (void)setLeftBarItemBlock:(LeftBarItemBlock)leftBarItemBlock {
    objc_setAssociatedObject(self, leftBarItemBlockKey, leftBarItemBlock, OBJC_ASSOCIATION_COPY);
}

- (LeftBarItemBlock)leftBarItemBlock {
    return objc_getAssociatedObject(self, leftBarItemBlockKey);
}

- (void)setRightBarItemBlock:(RightBarItemBlock)rightBarItemBlock {
    objc_setAssociatedObject(self, rightBarItemBlockKey, rightBarItemBlock, OBJC_ASSOCIATION_COPY);
}

- (RightBarItemBlock)rightBarItemBlock {
    return objc_getAssociatedObject(self, rightBarItemBlockKey);
}

/*********************  设置导航栏左侧图片按钮  *****************************/

- (void)setNavagationBarDefaultBackButton {
    [self setNavagationBarBackBtnWithImage:nil];
}

- (void)setNavagationBarBackBtnWithImage:(UIImage *)image {
//    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
//    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:nil];
//    self.navigationController.navigationBar.translucent = NO;
//    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
//    NSShadow *shadow = [[NSShadow alloc]init];
//    shadow.shadowColor = [UIColor whiteColor];
//    shadow.shadowOffset = CGSizeZero;
//
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                          [UIColor blackColor],NSForegroundColorAttributeName,
//                          [UIFont boldSystemFontOfSize:18],NSFontAttributeName,
//                          shadow,NSShadowAttributeName,
//                          shadow,NSShadowAttributeName,
//                          nil];
//
//    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    NSArray *itemsArray = [self barBackButtonWithImage:image];
    self.navigationItem.leftBarButtonItems = [self isTabbarRoot] ? nil : itemsArray;
    self.view.layer.shouldRasterize = YES;
    self.view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

- (BOOL)isTabbarRoot {
    for (OSSVNavigationVC *nc in self.tabBarController.viewControllers) {
        if (nc.viewControllers.firstObject == self) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)barBackButtonWithImage:(UIImage *)aImage {
    UIImage *image;
    image = aImage ? aImage : [UIImage imageNamed:[OSSVSystemsConfigsUtils isRightToLeftShow] ? @"arrow_right_new" : @"arrow_left_new"];
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button addTarget:self action:@selector(popToSuperView) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    // 1.调整图片距左间距可以这样设置
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -6, 0, 0)];
//    button.accessibilityLabel = nil;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    // 2.调整图片距左间距可以这样设置
//    spaceItem.width = -8;
    return @[spaceItem, item];
}

- (void)popToSuperView {
    if (self.leftBarItemBlock) {
        self.leftBarItemBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

/*********************  设置导航栏右侧图片按钮  *****************************/
- (void)setNavagationBarRightButtonWithImage:(UIImage *)image {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width, image.size.height);
    [btn setFrame:buttonFrame];
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    btn.accessibilityLabel = nil;
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = 0;
    self.navigationItem.rightBarButtonItems = @[spaceItem, buttonItem];
}

- (void)buttonClick {
    if (self.rightBarItemBlock) {
        self.rightBarItemBlock();
    }
}

/*********************  设置导航栏左侧文字按钮  *****************************/
- (void)setNavagationBarLeftButtonWithTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect buttonFrame = CGRectMake(0, 0, 83, 30); // (83,30)是系统的尺寸
    [btn setFrame:buttonFrame];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:color forState:UIControlStateNormal];
    btn.titleLabel.font = font;
    btn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [btn addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -30; // 根据效果，初步猜测这里是取（-宽度）值
    self.navigationItem.leftBarButtonItems = @[spaceItem, buttonItem];
}


/*********************  设置导航栏右侧文字按钮  *****************************/
- (void)setNavagationBarRightButtonWithTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect buttonFrame = CGRectMake(0, 0, 83, 30);
    [btn setFrame:buttonFrame];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:color forState:UIControlStateNormal];
    btn.titleLabel.font = font;
    btn.titleLabel.textAlignment = NSTextAlignmentRight;
    [btn addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -25;
    self.navigationItem.rightBarButtonItems = @[spaceItem, buttonItem];
}

/********************* 设置导航栏标题文字 **********************************/
- (void)setNavagationBarTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color {
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor whiteColor];
    shadow.shadowOffset = CGSizeZero;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          color,NSForegroundColorAttributeName,
                          font,NSFontAttributeName,
                          shadow,NSShadowAttributeName,
                          shadow,NSShadowAttributeName,
                          nil];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    self.navigationItem.title = title;
}

/********************* 弹出半透明控制器 ************************************/
- (void)presentTranslucentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion
{
    
    // 用于显示这个视图控制器的视图是否覆盖当视图控制器或其后代提供了一个视图控制器。默认为NO
    self.definesPresentationContext = YES;
    // 设置页面切换效果
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    // UIModalPresentationOverCurrentContext能在当前VC上present一个新的VC同时不覆盖之前的内容
    viewControllerToPresent.modalPresentationStyle = UIModalPresentationOverCurrentContext|UIModalPresentationFullScreen;
    
    [self presentViewController:viewControllerToPresent animated:flag completion:^{
        
        self.presentedViewController.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    }];
    
    if (completion) {
        
        completion();
    }
    
}

@end
