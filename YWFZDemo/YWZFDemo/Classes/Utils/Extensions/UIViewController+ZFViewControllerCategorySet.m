//
//  UIViewController+ZFViewControllerCategorySet.m
//  ZZZZZ
//
//  Created by YW on 2018/12/3.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWLoginViewController.h"
#import "ZFOtherRegisterViewController.h"
#import "ZFWebViewViewController.h"
#import <StoreKit/StoreKit.h>
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "NSObject+Swizzling.h"
#import "ZFGrowingIOAnalytics.h"
#import "SystemConfigUtils.h"
#import "ZF3DTouchHeader.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFNetworkManager.h"
#import "ZFRequestModel.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "Masonry.h"
#import "Constants.h"
#import "YWLocalHostManager.h"
#import "YSAlertView.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFCommunityFullLiveVideoVC.h"

static char *leftBarItemBlockKey  = "leftBarItemBlockKey";
static char *rightBarItemBlockKey = "rightBarItemBlockKey";

@implementation UIViewController (ZFViewControllerCategorySet)

#pragma mark - UIViewController (ZFShowEmptyVeiw) ==================================================

@dynamic edgeInsetTop;
@dynamic emptyImage;
@dynamic emptyTitle;

- (void)setEdgeInsetTop:(CGFloat)edgeInsetTop {
    objc_setAssociatedObject(self, @selector(edgeInsetTop), @(edgeInsetTop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)edgeInsetTop{
    return [objc_getAssociatedObject(self, @selector(edgeInsetTop)) floatValue];
}

- (void)setEmptyImage:(UIImage *)emptyImage {
    objc_setAssociatedObject(self, @selector(emptyImage), emptyImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)emptyImage {
    return objc_getAssociatedObject(self, @selector(emptyImage));
}

- (void)setEmptyTitle:(NSString *)emptyTitle {
    objc_setAssociatedObject(self, @selector(emptyTitle), emptyTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)emptyTitle {
    return objc_getAssociatedObject(self, @selector(emptyTitle));
}

//handler:为nil时，不显示按钮事件
- (void)showEmptyViewHandler:(void (^)(void))handler {
    UIView *view = [self.view viewWithTag:EmptyViewTag];
    if (view && view.tag == EmptyViewTag) {
        return;
    }
    
    UIView *againRequestView = [[UIView alloc] initWithFrame:CGRectZero];
    againRequestView.tag = EmptyViewTag;
    [againRequestView setBackgroundColor:ZFCOLOR(245, 245, 245, 1.0)];
    [self.view addSubview:againRequestView];
    [againRequestView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(self.edgeInsetTop, 0, 0, 0));
    }];
    
    UIView *groundView = [[UIView alloc]initWithFrame:CGRectZero];
    [againRequestView addSubview:groundView];
    [groundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(againRequestView);
        make.width.mas_equalTo(KScreenWidth);
    }];
    
    UIImage *image = [ZFNetworkManager isReachable] ? self.emptyImage : [UIImage imageNamed:@"blankPage_networkError"];
    if (!self.emptyImage) {
        image = [UIImage imageNamed:@"blankPage_networkError"];
    }
    YYAnimatedImageView *img = [[YYAnimatedImageView alloc]initWithFrame:CGRectZero];
    [img setImage:image];
    [groundView addSubview:img];
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.mas_equalTo(groundView);
        make.size.mas_equalTo(CGSizeMake(110, 110));
    }];
    
    NSString *title = [ZFNetworkManager isReachable] ?  self.emptyTitle : ZFLocalizedString(@"BlankPage_NetworkError_tipTitle",nil);
    if (!self.emptyTitle) {
        title = ZFLocalizedString(@"BlankPage_NetworkError_tipTitle",nil);
    }
    CGFloat maxWidth = KScreenWidth - 56;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
    label.text = title;
    label.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    [label setTextColor:ZFCOLOR(45, 45, 45, 1)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setNumberOfLines:0];
    [label setFont:[UIFont systemFontOfSize:16.0f]];
    label.adjustsFontSizeToFitWidth = YES;
    label.preferredMaxLayoutWidth = KScreenWidth - 56;
    [groundView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(img.mas_bottom).offset(36);
        make.centerX.equalTo(img);
        make.width.greaterThanOrEqualTo(@(maxWidth));
    }];
    
    if (handler) {
        CGFloat btnWidth = (KScreenWidth - 56);
        UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        refreshBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        refreshBtn.titleLabel.textColor = ZFCOLOR_WHITE;
        refreshBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        //refreshBtn.backgroundColor = ZFCThemeColor();
        [refreshBtn setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [refreshBtn setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];        
        [refreshBtn setTitle:ZFLocalizedString(@"EmptyCustomViewManager_refreshButton",nil) forState:UIControlStateNormal];
        [refreshBtn addTarget:self action:@selector(operatorAction:) forControlEvents:UIControlEventTouchUpInside];
        [groundView addSubview:refreshBtn];
        [refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(groundView.mas_leading).offset(28);
            make.top.equalTo(label.mas_bottom).offset(36);
            make.size.mas_equalTo(CGSizeMake(btnWidth, 44));
            make.bottom.equalTo(groundView);
        }];
        
        [self zf_setButtonAction:handler];
    }
}

- (void)operatorAction:(UIButton *)button {
    void (^buttonAction)(void) = [self zf_buttonAction];
    if (buttonAction) {
        buttonAction();
    }
}

- (void (^)(void))zf_buttonAction {
    void (^buttonAction)(void) = (void (^)(void))objc_getAssociatedObject(self,@selector(action));
    if (!buttonAction) return nil;
    return buttonAction;
}

- (void)zf_setButtonAction:(void (^)(void))action {
    if (action) {
        objc_setAssociatedObject(self,@selector(action),action,OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (void)removeEmptyView {
    UIView *againRequestView = [self.view viewWithTag:EmptyViewTag];
    if (!againRequestView) {
        return;
    }
    [againRequestView removeFromSuperview];
}

#pragma mark - UIViewController (Dealloc) ==================================================

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        // GrowingIO SDK统计每个页面的标题
        [class swizzleMethod:NSSelectorFromString(@"viewWillAppear:") swizzledSelector:@selector(zf_viewWillAppear:)];
        
        [class swizzleMethod:NSSelectorFromString(@"viewDidAppear:") swizzledSelector:@selector(zf_viewDidAppear:)];
        
        [class swizzleMethod:NSSelectorFromString(@"viewDidDisappear:") swizzledSelector:@selector(zf_viewDidDisappear:)];
        
        Method setTextMethod = class_getInstanceMethod(class, @selector(presentViewController:animated:completion:));
        Method replaceSetTextMethod = class_getInstanceMethod(class, @selector(zf_presentViewController:animated:completion:));
        method_exchangeImplementations(setTextMethod, replaceSetTextMethod);
        
        if ([YWLocalHostManager isDistributionOnlineRelease]) {
            YWLog(@"打包发布不需要监控dealloc操作");
        } else {
            [class swizzleMethod:NSSelectorFromString(@"dealloc") swizzledSelector:@selector(zf_dealloc)];
        }
    });
}

/**
 *  GrowingIO SDK统计每个页面的标题
 */
- (void)zf_viewWillAppear:(BOOL)animated {
    [self zf_viewWillAppear:animated];
    
    NSString *vcTitle = self.title;
    if (!vcTitle) {
        vcTitle = self.navigationItem.title;
    }
    if(!ZFIsEmptyString(vcTitle)) {
        self.view.growingAttributesUniqueTag = vcTitle;
    }
}

- (void)zf_viewDidAppear:(BOOL)animated
{
    [self zf_viewDidAppear:animated];
    
    [ZFAppsflyerAnalytics appsflyerViewViewDidAppear:self];
}

- (void)zf_viewDidDisappear:(BOOL)animated
{
    [self zf_viewDidDisappear:animated];
    
    [ZFAppsflyerAnalytics appsflyerViewViewDisAppear:self];
}

-(void)zf_dealloc {
    YWLog(@"%@->>>>已经释放了",[self class]);
    [self zf_dealloc];
}

#pragma mark - UIViewController (NavagationBar) ==================================================

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
    NSArray *itemsArray = [self barBackButtonWithImage:image];
    self.navigationItem.leftBarButtonItems = [self isTabbarRoot] ? nil : itemsArray;
    self.view.layer.shouldRasterize = YES;
    self.view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

- (BOOL)isTabbarRoot {
    for (ZFNavigationController *nc in self.tabBarController.viewControllers) {
        if (nc.viewControllers.firstObject == self) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)barBackButtonWithImage:(UIImage *)aImage {
    UIImage *image;
    image = aImage ? aImage : [UIImage imageNamed:[SystemConfigUtils isRightToLeftShow] ? @"nav_arrow_right" : @"nav_arrow_left"];
    CGRect buttonFrame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button addTarget:self action:@selector(popToSuperView) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    // 1.调整图片距左间距可以这样设置
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
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
    [self setNavagationBarRightButtonWithTitle:title font:font color:color enabled:YES];
}

- (void)setNavagationBarRightButtonWithTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color enabled:(BOOL)enabled {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect buttonFrame = CGRectMake(0, 0, 43, 43);
    [btn setFrame:buttonFrame];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:color forState:UIControlStateNormal];
    btn.titleLabel.font = font;
    btn.titleLabel.textAlignment = NSTextAlignmentRight;
    [btn addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    btn.userInteractionEnabled = enabled;
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    //    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    //    spaceItem.width = -25;
    self.navigationItem.rightBarButtonItems = @[buttonItem];
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

#pragma mark - UIViewController (ZFExtension) ==================================================

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

/**
 *  执行返回到指定控制器的上层控制器，若没有就返回到上层
 */
- (void)popUpperClassRelativeClass:(NSString *)classStr {
    
    UIViewController *targetCtrl;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:NSClassFromString(classStr)]) {
            if (targetCtrl) {
                [self.navigationController popToViewController:targetCtrl animated:YES];
                return;
            }
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        targetCtrl = vc;
    }
    [self.navigationController popViewControllerAnimated:YES];
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
 * 在有些页面上添加一个透明视图到控制器.View上让事件传递到顶层, 使其能够侧滑返回
 */
- (void)shouldShowLeftHoledSliderView:(CGFloat)height {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIView *tempView = [[UIView alloc] init];
        tempView.frame = CGRectMake(0, 0, 20, height);
        tempView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tempView];
    });
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
        YWLog(@"❌❌❌ 页面push失败，携带属性字典错误:%@",vcPropertyDic);
        return;
    }
    UIViewController *targetVC = [[NSClassFromString(vcName) alloc] init];
    if (![targetVC isKindOfClass:[UIViewController class]]) {
        YWLog(@"❌❌❌ 页面push失败，名称对应的控制器不存在: %@",vcName);
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
        ZFPerformSelectorLeakWarning(
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
        YWLog(@"❌❌❌ 页面push失败，携带属性字典错误:%@",propertyDic);
        return;
    }
    UIViewController *pushVC = [[NSClassFromString(vcName) alloc] init];
    if (![pushVC isKindOfClass:[UIViewController class]]) {
        YWLog(@"❌❌❌ 页面push失败，名称对应的控制器不存在: %@",vcName);
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
        YWLog(@"❌❌❌ 页面push失败，携带属性字典错误:%@",propertyDic);
        return;
    }
    UIViewController *presentVC = [[NSClassFromString(vcName) alloc] init];
    if (![presentVC isKindOfClass:[UIViewController class]]) {
        YWLog(@"❌❌❌ 页面push失败，名称对应的控制器不存在: %@",vcName);
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
    YWLog(@"❌❌❌ 警告:< %@ >: 类没有实现该属性: %@",[self class],key);
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
        YWLoginViewController *loginVC = [[YWLoginViewController alloc] init];
        loginVC.successBlock = loginSuccessBlock;
        ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

/**
 判断是否需要, 如果需要登录则弹出登录页面
 @param loginSuccessBlock 登录成功回调
 @param cancelSuccessBlock 取消登录回调
 */
- (void)judgePresentLoginVCCompletion:(void(^)(void))loginSuccessBlock
                      cancelCompetion:(void(^)(void))cancelSuccessBlock
{
    if ([AccountManager sharedManager].isSignIn) {
        if (loginSuccessBlock) {
            loginSuccessBlock();
        }
    } else {
        YWLoginViewController *loginVC = [[YWLoginViewController alloc] init];
        loginVC.successBlock = loginSuccessBlock;
        loginVC.cancelSignBlock = cancelSuccessBlock;
        ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

/**
 *  判断是否需要, 如果需要登录则弹出登录页面
 *  @param loginSuccessBlock 登录成功回调
 *  @param type 登录页面的状态
 */
- (void)judgePresentLoginVCChooseType:(YWLoginEnterType)type
                         comeFromType:(YWLoginViewControllerEnterType)comeFromType
                           Completion:(void(^)(void))loginSuccessBlock
{
    if ([AccountManager sharedManager].isSignIn) {
        if (loginSuccessBlock) {
            loginSuccessBlock();
        }
    } else {
        YWLoginViewController *loginVC = [[YWLoginViewController alloc] init];
        loginVC.successBlock = loginSuccessBlock;
        loginVC.type = type;
        loginVC.comefromType = comeFromType;
        ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - UIViewController (ZFChangeIcon) ==================================================

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


- (void)zf_presentViewController:(UIViewController *)viewControllerToPresent
                        animated:(BOOL)flag
                      completion:(void (^)(void))completion {
    if (![viewControllerToPresent isKindOfClass:[UIViewController class]]) {
        ShowAlertSingleBtnView(@"Tips", ZFLocalizedString(@"EmptyCustomViewManager_titleLabel", nil), @"OK");
        return;
    }
    // presentVC时需要判断换肤
    if ([viewControllerToPresent isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navVC = (UINavigationController *)viewControllerToPresent;
        [navVC.navigationBar zfChangeSkinToSystemNavgationBar];
    }
    
    if ([viewControllerToPresent isKindOfClass:[UIAlertController class]]) {
        YWLog(@"title: %@",((UIAlertController *)viewControllerToPresent).title);
        YWLog(@"message: %@",((UIAlertController *)viewControllerToPresent).message);
        
        UIAlertController *alertController = (UIAlertController *)viewControllerToPresent;
        if (alertController.title == nil &&
            alertController.message == nil &&
            alertController.actions.count == 1) {
            
            //此场景为切换系统桌面icon时, 需要隐藏弹框, 经过测试其他系统语言都是"OK"
            UIAlertAction *alertAction = [alertController.actions firstObject];
            if ([alertAction.title isEqualToString:@"OK"] ||
                [alertAction.title isEqualToString:@"好"] ||
                [alertAction.title isEqualToString:@"OKE"] ||
                [alertAction.title isEqualToString:@"موافق"] ||
                [alertAction.title isEqualToString:@"ОК"]) { //此ОК为俄语的,切勿删除
                return;
            }
        }
    }
    [self zf_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

#pragma mark - UIViewController (ZFAppStoreComment) ==================================================

- (void)showAppStoreCommentWithContactUs:(NSString *)contactUs {
    
    NSString *alertTitle = ZFLocalizedString(@"GuideReviewAppStore_Title", nil);
    NSString *alertMessage = ZFLocalizedString(@"GuideReviewAppStore_Tips", nil);
    NSString *rateTitle = ZFLocalizedString(@"GuideReviewAppStore_Rate", nil);
    NSString *notNowTitle = ZFLocalizedString(@"GuideReviewAppStore_NotNow", nil);
    NSString *writeFeedbackTitle = ZFLocalizedString(@"GuideReviewAppStore_FeedBack", nil);
    
    UIAlertController *alertController =  [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *rateAction = [UIAlertAction actionWithTitle:rateTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //跳转App store 评论App界面
        [UIViewController showAppStoreReviewVC];
    }];
    
    UIAlertAction *notNowAction = [UIAlertAction actionWithTitle:notNowTitle style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction *writeFeedbackAction = [UIAlertAction actionWithTitle:writeFeedbackTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //跳转Contact Us页面，进行app反馈。
        if (![NSStringUtils isEmptyString:contactUs]) {
            ZFWebViewViewController *webVC = [[ZFWebViewViewController alloc] init];
            webVC.link_url = contactUs;
            [self.navigationController pushViewController:webVC animated:YES];
        }
    }];
    
    [alertController addAction:rateAction];
    [alertController addAction:notNowAction];
    [alertController addAction:writeFeedbackAction];
    
    [[UIViewController currentTopViewController] presentViewController:alertController animated:YES completion:nil];
}

/**
 * 跳转App store 评论App界面  (SKStoreProductViewController)
 * 如果评论App过三次, 系统不会再次弹出, 因此需要记录弹出次数, 否则下次直接去AppStore页面
 */
+ (void)showAppStoreReviewVC {
    NSInteger showTimes = [GetUserDefault(kShowAppStoreReviewTimes) integerValue];
    if (IOS103UP && showTimes < 4) {
        [SKStoreReviewController requestReview];
        showTimes = showTimes+1;
        SaveUserDefault(kShowAppStoreReviewTimes, @(showTimes));
        
    } else {
        NSURL *appReviewUrl = [NSURL URLWithString:ZFAppStoreCommentUrl];
        if ([[UIApplication sharedApplication] canOpenURL:appReviewUrl]) {
            [[UIApplication sharedApplication] openURL:appReviewUrl];
        } else {
            NSURL *appInfoUrl = [NSURL URLWithString:ZFAppStoreUrl];
            [[UIApplication sharedApplication] openURL:appInfoUrl];
        }
    }
}


#pragma mark - UIViewController (Touch3DProtocolForward) ==================================================

/**
 * 检测3DTouch是否可用,并且注册3DTouch事件
 */
- (void)register3DTouchAlertWithDelegate:(id)delegate
                              sourceView:(UIView *)sourceView
                              goodsModel:(ZFGoodsModel *)goodsModel
{
    // 记录3DTouch需要的信息
    if (![goodsModel isKindOfClass:[ZFGoodsModel class]]) return;
    
    if (![sourceView isKindOfClass:[UIView class]]) return;
    
    // 是否支持3DTouch
    if (self.traitCollection.forceTouchCapability != UIForceTouchCapabilityAvailable) return;
    
    if (!delegate || ![delegate conformsToProtocol:@protocol(UIViewControllerPreviewingDelegate)]) return;
    
    NSMutableDictionary *touchCellDict = [NSMutableDictionary dictionary];
    NSString *fromType = [NSString stringWithFormat:@"comefrom_%@", NSStringFromClass([self class])];
    [touchCellDict setValue:fromType forKey:k3DTouchComeFromTypeKey];
    [touchCellDict setValue:ZFToString(goodsModel.goods_id) forKey:@"goods_id"];
    [touchCellDict setValue:ZFToString(goodsModel.is_collect) forKey:@"is_collect"];
    [touchCellDict setValue:ZFToString(goodsModel.goods_number) forKey:@"goods_number"];
    [touchCellDict setValue:ZFToString(goodsModel.is_on_sale) forKey:@"is_on_sale"];
    [touchCellDict setValue:ZFToString(goodsModel.wp_image) forKey:@"smallPicUrl"];
    [touchCellDict setValue:ZFToString(goodsModel.goods_thumb) forKey:@"goods_thumb"];
    objc_setAssociatedObject(sourceView, k3DTouchPreviewingModelKey, touchCellDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    BOOL isregister = [objc_getAssociatedObject(sourceView, k3DTouchRelationCellisRegister) boolValue];
    if (!isregister) {
        objc_setAssociatedObject(sourceView, k3DTouchRelationCellisRegister, [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self registerForPreviewingWithDelegate:delegate sourceView:sourceView];
    }
}

///删除导航栈中指定的控制器
- (void)deleteVCFromNavgation:(Class)className {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *subVCArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        
        for (UIViewController *subVC in self.navigationController.viewControllers) {
            if ([subVC isKindOfClass:className]){
                [subVCArray removeObject:subVC];
                break;
            }
        }
        [self.navigationController setViewControllers:subVCArray animated:YES];
    });
}

///删除导航栈中前面指定的控制器
- (void)deletePreviousVCFromNavgation:(Class)className {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *subVCArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        
        for (UIViewController *subVC in self.navigationController.viewControllers) {
            if ([subVC isKindOfClass:className] && self != subVC){
                
                if ([subVC isKindOfClass:[ZFCommunityFullLiveVideoVC class]]) {
                    ZFCommunityFullLiveVideoVC *videoVC = (ZFCommunityFullLiveVideoVC *)subVC;
                    [videoVC clearPlay];
                }
                [subVCArray removeObject:subVC];
                break;
            }
        }
        [self.navigationController setViewControllers:subVCArray animated:YES];
    });
}
@end
