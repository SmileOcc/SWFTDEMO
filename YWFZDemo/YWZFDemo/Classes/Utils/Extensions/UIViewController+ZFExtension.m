//
//  UIViewController+ZFExtension.m
//  IntegrationDemo
//
//  Created by mao wangxin on 2018/3/6.
//  Copyright © 2018年 mao wangxin. All rights reserved.
//

#import "UIViewController+ZFExtension.h"
#import "ZFLoginViewController.h"
#import "ZFOtherRegisterViewController.h"

@implementation UIViewController (ZFExtension)

/**
 *  执行返回到指定控制器
 */
- (BOOL)popToSpecifyVCSuccess:(NSString *)classStr
{
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:NSClassFromString(classStr)]) {
            [self.navigationController popToViewController:vc animated:YES];
            return YES;
        }
    }
    return NO;
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
        if (controller.presentedViewController) {
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


#pragma mark - /*** 顶层控制器 ***/


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
 * 添加一个透明视图让事件传递到顶层,使其能够侧滑返回
 */
- (void)shouldShowLeftHoledSliderView {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIView *tempView = [[UIView alloc] init];
            tempView.frame = CGRectMake(0, 0, 20, self.view.bounds.size.height);
            tempView.backgroundColor = [UIColor clearColor];
            [self.view addSubview:tempView];
        });
//    });
}


#pragma mark -===========携带参数页面跳转===========

/**
 带参数跳转到目标控制器, 如果导航栈中存在目标器则pop, 不存在则push
 
 @param vcName 目标控制器
 @param propertyDic 目标控制器属性字典
 @param selectorStr 跳转完成后需要执行的方法
 */
- (void)pushOrPopToViewController:(NSString *)vcName
                       withObject:(NSDictionary *)vcPropertyDic
                        aSelector:(NSString *)selectorStr
                         animated:(BOOL)animated
{
    if (vcPropertyDic && ![vcPropertyDic isKindOfClass:[NSDictionary class]]) {
        ZFLog(@"❌❌❌ 页面push失败，携带属性字典错误:%@",vcPropertyDic);
        return;
    }
    UIViewController *targetVC = [[NSClassFromString(vcName) alloc] init];
    if (![targetVC isKindOfClass:[UIViewController class]]) {
        ZFLog(@"❌❌❌ 页面push失败，名称对应的控制器不存在: %@",vcName);
        return;
    }
    UINavigationController *navigationController = self.navigationController;
    if ([self isKindOfClass:[UINavigationController class]]) {
        navigationController = (UINavigationController *)self;
    }
    
    // 判断如果导航控制器中存在相同控制器,则先移除相同类型的控制器, 防止循环跳转撑爆内存
    UIViewController *theSameTargetVC = [self isExistClassInSelfNavigation:vcName];
    if (theSameTargetVC) {
        NSArray *childVCs = navigationController.viewControllers;
        if ([childVCs containsObject:theSameTargetVC]) {
            NSMutableArray *tempChildVCs = [NSMutableArray arrayWithArray:childVCs];
            [tempChildVCs removeObject:theSameTargetVC];
            navigationController.viewControllers = tempChildVCs;
        }
    }
    
    //KVC赋值控制器的属性
    if (vcPropertyDic && [vcPropertyDic isKindOfClass:[NSDictionary class]]) {
        [targetVC setValuesForKeysWithDictionary:vcPropertyDic];
    }
    targetVC.hidesBottomBarWhenPushed = YES;
    [navigationController pushViewController:targetVC animated:animated];
    
    //判断在跳转后是否需要执行相关方法
    SEL selector = NSSelectorFromString(selectorStr);
    if (selectorStr.length>0 && [targetVC respondsToSelector:selector]) {
        OKPerformSelectorLeakWarning(
            [targetVC performSelector:selector withObject:nil];
        );
    }
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
        ZFLog(@"❌❌❌ 页面push失败，携带属性字典错误:%@",propertyDic);
        return;
    }
    UIViewController *pushVC = [[NSClassFromString(vcName) alloc] init];
    if (![pushVC isKindOfClass:[UIViewController class]]) {
        ZFLog(@"❌❌❌ 页面push失败，名称对应的控制器不存在: %@",vcName);
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


/**
 *  执行页面present跳转
 *
 *  @param vcName 当前的控制器
 *  @param propertyDic 控制器需要的参数
 */
- (void)presentToViewController:(NSString *)vcName
                     withObject:(NSDictionary *)propertyDic
                  showTargetNav:(BOOL)showNavigation
                     completion:(void(^)(void))completionBlcok
{
    if (propertyDic && ![propertyDic isKindOfClass:[NSDictionary class]]) {
        ZFLog(@"❌❌❌ 页面push失败，携带属性字典错误:%@",propertyDic);
        return;
    }
    UIViewController *presentVC = [[NSClassFromString(vcName) alloc] init];
    if (![presentVC isKindOfClass:[UIViewController class]]) {
        ZFLog(@"❌❌❌ 页面push失败，名称对应的控制器不存在: %@",vcName);
        return;
    }
    if (propertyDic && [propertyDic isKindOfClass:[NSDictionary class]]) {
        [presentVC setValuesForKeysWithDictionary:propertyDic];
    }
    
    if (showNavigation) {
        if (self.navigationController) {
            presentVC = [[[self.navigationController class] alloc] initWithRootViewController:presentVC];
        } else {
            presentVC = [[UINavigationController alloc] initWithRootViewController:presentVC];
        }
    }
    [self presentViewController:presentVC animated:YES completion:completionBlcok];
}

/**
 * 警告：此方法不要删除，在上面的方法(pushController: parm:)的参数携带错误时防止崩溃
 */
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    ZFLog(@"❌❌❌ 警告:< %@ >: 类没有实现该属性: %@",[self class],key);
}

/**
 判断是否需要, 如果需要登录则弹出登录页面
 @param loginSuccessBlock 登录成功回调
 */
- (void)judgePresentLoginVCCompletion:(void(^)(void))loginSuccessBlock
{
    if ([AccountManager sharedManager].isSignIn) {
        if (loginSuccessBlock) {
            loginSuccessBlock();
        }
    } else {
        ZFLoginViewController *loginVC = [[ZFLoginViewController alloc] init];
        loginVC.successBlock = loginSuccessBlock;
        ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

/**
 *  判断是否需要, 如果需要登录则弹出登录页面
 *  @param loginSuccessBlock 登录成功回调
 *  @param type 登录页面的状态
 */
- (void)judgePresentLoginVCChooseType:(ZFLoginEnterType)type
                         comeFromType:(NSInteger)comeFromType
                           Completion:(void(^)(void))loginSuccessBlock
{
    if ([AccountManager sharedManager].isSignIn) {
        if (loginSuccessBlock) {
            loginSuccessBlock();
        }
    } else {
        ZFLoginViewController *loginVC = [[ZFLoginViewController alloc] init];
        loginVC.successBlock = loginSuccessBlock;
        loginVC.type = type;
        loginVC.comefromType = comeFromType;
        ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

/**
 * 切换语言后切换系统UI布局方式
 */
+ (void)convertAppUILayoutDirection
{
    // 切换语言关键: 设置系统布局样式 (左到右, 右到左)
    if ([SystemConfigUtils isCanRightToLeftShow]) {
        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    } else {
        [UIView appearance].semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    }
    
    // 设置导航全局返回按钮图片
    UIImage *backImage = [UIImage imageNamed:([SystemConfigUtils isRightToLeftShow] ? @"nav_arrow_right" : @"nav_arrow_left")];
    [[UINavigationBar appearance] setBackIndicatorImage:backImage];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backImage];
}

@end

