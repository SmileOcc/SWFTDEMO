//
//  ZFTabBarController.m
//  Dezzal
//
//  Created by 7FD75 on 16/7/21.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "ZFTabBarController.h"
#import "ZFNavigationController.h"
#import "ZFCommunityHomeVC.h"
#import "ZFHomePageViewController.h"
#import "PostPhotosManager.h"
#import "ZFSkinViewModel.h"
#import "UIImage+ZFExtended.h"
#import "ZFCommunityZShowView.h"
#import "ZFCommunityOutfitPostVC.h"
#import "UITabBarController+ZFExtension.h"
#import "NSArray+SafeAccess.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ZFStatistics.h"
#import "SystemConfigUtils.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFAccountViewController540.h"
#import "UIImage+ZFExtended.h"
#import <Lottie/Lottie.h>

@interface ZFAnimationTabBar : UITabBar
@property (nonatomic, strong) NSMutableArray    *animViewArray;
@end

@implementation ZFAnimationTabBar

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.animViewArray removeAllObjects];
    
    for (UIView *button in self.subviews) {
        if (![button isKindOfClass:[UIControl class]]) continue;
        
        for (UIView *tmpView in button.subviews) {
            if ([tmpView isKindOfClass:[NSClassFromString(@"UITabBarSwappableImageView") class]]) {
                [self.animViewArray addObject:tmpView];
            }
        }
    }
    
    ///消除TabBar顶部细线
    [self hideTabBarTopLine];
}

- (NSMutableArray *)animViewArray {
    if (!_animViewArray) {
        _animViewArray = [NSMutableArray array];
    }
    return _animViewArray;
}

///消除TabBar顶部细线
- (void)hideTabBarTopLine {
    for (UIView *tempView in self.subviews) {
        if (![tempView isKindOfClass:[NSClassFromString(@"_UIBarBackground") class]]) continue;
        
        for (UIView *tempSubView in tempView.subviews) {
            if (![tempSubView isKindOfClass:[NSClassFromString(@"_UIBarBackgroundShadowView") class]]) continue;
            
            for (UIView *thirdSubView in tempSubView.subviews) {
                if (![thirdSubView isKindOfClass:[NSClassFromString(@"_UIBarBackgroundShadowContentImageView") class]]) continue;
                
                if (thirdSubView.frame.size.height < 1.0) {
                    thirdSubView.backgroundColor = [UIColor clearColor];
                    thirdSubView.layer.backgroundColor = [UIColor clearColor].CGColor;
                }
                return;
            }
        }
    }
}

@end

//===========================================================================


@interface ZFTabBarController ()
<
UITabBarControllerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
>
@end

@implementation ZFTabBarController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupControllers];
    [self setupTabBarAnimation];
    
    [self.tabBar setShadowImage:[UIImage new]];
    [self.tabBar addDropShadowWithOffset:CGSizeMake(0, -2)
                                  radius:2
                                   color:[UIColor blackColor]
                                 opacity:0.1];
    [self addNotification];
    self.tabBar.translucent = NO;
    self.delegate = self;
    [self setTabBarItemSelectedColor];

    [self bringBadgeViewToFront];
}

///设置Tab选中颜色
- (void)setTabBarItemSelectedColor {
    UIColor *selectColor = ColorHex_Alpha(0x2d2d2d, 1);
    if (![selectColor isKindOfClass:[UIColor class]]) {
        selectColor = [UIColor blackColor];
    }
    self.tabBar.tintColor = selectColor;
}

///自定义Tabbar为了获取icon的父视图
- (void)setupTabBarAnimation {
    ZFAnimationTabBar *appTabBar = [[ZFAnimationTabBar alloc] initWithFrame:self.tabBar.bounds];
    [self setValue:appTabBar forKeyPath:@"tabBar"];
}

- (void)setupControllers {
    // 1.首页
    [self setupChildViewController:[ZFHomePageViewController class]
                             title:ZFLocalizedString(@"Tabbar_Home",nil)
                         imageName:@"tab_home_normal"
                 selectedImageName:@"tab_home_selected"];
    
    // 2.社区
    [self setupChildViewController:[ZFCommunityHomeVC class]
                             title:ZFLocalizedString(@"Tabbar_Z-Me",nil)
                         imageName:@"tab_z-me_normal"
                 selectedImageName:@"tab_z-me_selected"];
    
    // 3.个人中心
    [self setupChildViewController:[ZFAccountViewController540 class]
                             title:ZFLocalizedString(@"Tabbar_Account",nil)
                         imageName:@"tab_account_normal"
                 selectedImageName:@"tab_account_selected"];
}

/**
 *  初始化一个子控制器
 *
 *  @param childVc           需要初始化的子控制器Class
 *  @param title             标题
 *  @param imageName         图标
 *  @param selectedImageName 选中的图标
 */
- (void)setupChildViewController:(Class)childVcClass
                           title:(NSString *)title
                       imageName:(NSString *)imageName
               selectedImageName:(NSString *)selectedImageName
{
    
    UIViewController *childVc = [[childVcClass alloc] init];
    if (![childVc isKindOfClass:[UIViewController class]]) return;
    
    // 设置图标
    UIImage *nomalImage = [UIImage imageNamed:imageName];
    childVc.tabBarItem.image = [nomalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 设置选中的图标
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    childVc.tabBarItem.selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // V5.7.0:加上Titl (没有换肤操作时, 才显示标题)
    if ([AccountManager sharedManager].needChangeAppSkin) {
        [childVc.tabBarItem setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    } else {
        childVc.tabBarItem.title = title;
        childVc.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -4);
    }
    
    // 2.包装一个导航控制器
    ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:childVc];

    [self addChildViewController:nav];
}

#pragma mark - <UITabBarControllerDelegate>

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    UIViewController *willSelectVC = viewController;
    if ([willSelectVC isKindOfClass:[UINavigationController class]]) {
        willSelectVC = ((UINavigationController *)willSelectVC).topViewController;
    }
    //统计Tabbar点击事件
    [self statisticsTabbarClick:willSelectVC];
    
    UIViewController *hasSelectedVC = self.selectedViewController;
    if ([hasSelectedVC isKindOfClass:[UINavigationController class]]) {
        hasSelectedVC = ((UINavigationController *)hasSelectedVC).topViewController;
    }
    
    //监听重复点击Tabbar
    if ([willSelectVC isKindOfClass:[hasSelectedVC class]]) {
        ZFPerformSelectorLeakWarning( //忽略警告
            SEL sel = @selector(repeatTapTabBarCurrentController);
            if ([hasSelectedVC respondsToSelector:sel]) {
                [hasSelectedVC performSelector:sel];
                return NO;
            }
        );
    }
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    id object = viewController.tabBarItem;
    YWLog(@"didSelectViewController===%@", object);
    
    //轻微震动
    ZFPlayImpactFeedback(UIImpactFeedbackStyleLight);
    
    [self showAnimationDidSelected];
}

/// 在点击Tabbar时显示动画
- (void)showAnimationDidSelected {
    if ([AccountManager sharedManager].needChangeAppSkin) {
        YWLog(@"Tabbar有换肤操作时, 不显示动画");
        return;
    }
    for (NSInteger i=0; i<self.childViewControllers.count; i++) {
        BOOL isCurrent = NO;
        if (i == self.selectedIndex) {
            isCurrent = YES;//防止前一个动画没完成立即点击其他Tab
        }
        [self startTabbarAnimation:i isCurrent:isCurrent];
    }
}

- (void)startTabbarAnimation:(NSInteger)selectedIndex isCurrent:(BOOL)isCurrent {
    
    if (![self.tabBar isKindOfClass:[ZFAnimationTabBar class]]) return;
    
    NSArray *animViewArray = ((ZFAnimationTabBar *)self.tabBar).animViewArray;
    if (!ZFJudgeNSArray(animViewArray)) return;
    
    if (animViewArray.count <= selectedIndex) return;
    UIView *touchView = animViewArray[selectedIndex];
    if (![touchView isKindOfClass:[UIView class]]) return;
    
    NSInteger animTag = (2020 + selectedIndex);
    LOTAnimationView *animView = [touchView viewWithTag:animTag];
    
    if (![animView isKindOfClass:[LOTAnimationView class]]) {
        if (!isCurrent)return;
        
        NSString *name = [self jsonNameOfTabbarIndex:selectedIndex];
        animView = [LOTAnimationView animationNamed:name];
        animView.backgroundColor = [UIColor whiteColor];
        animView.contentMode = UIViewContentModeScaleAspectFit;
        animView.userInteractionEnabled = YES;
        animView.loopAnimation = NO;
        animView.frame = touchView.bounds;
        animView.tag = animTag;
        if (![animView isKindOfClass:[UIView class]]) return;
        
        ///警告:不能为UIVisualEffectView添加子视图
        if ([touchView isKindOfClass:[UIVisualEffectView class]]) return;
        [touchView addSubview:animView];
    }
    
    if (isCurrent) {
        if (animView.isAnimationPlaying) {
            [animView stop];
        }
        animView.hidden = NO;
        @weakify(animView)
        [animView playWithCompletion:^(BOOL animationFinished) {
             @strongify(animView)
             animView.hidden = YES;
        }];
    } else {
        if (animView.isAnimationPlaying) {
            [animView stop];
        }
    }
}

- (NSString *)jsonNameOfTabbarIndex:(NSInteger)index {
    NSString *animationNamed = @"";
    if (index == 0) {
        animationNamed = @"ZZZZZ_tabBar_home";

    } else if (index == 1) {
        animationNamed = @"ZZZZZ_tabBar_zme";

    } else if (index == 2) {
        animationNamed = @"ZZZZZ_tabBar_user";
    }
    return animationNamed;
}

/**
 *  统计Tabbar点击事件
 */
- (void)statisticsTabbarClick:(UIViewController *)topVC {
    if ([topVC isKindOfClass:ZFHomePageViewController.class]) {
        [ZFStatistics eventType:ZF_Home_Tabbar_type];
        
    } else if ([topVC isKindOfClass:ZFCommunityHomeVC.class]) {
        [ZFStatistics eventType:ZF_Community_Tabbar_type];
        
    } else if ([topVC isKindOfClass:ZFAccountViewController540.class]) {
        [ZFStatistics eventType:ZF_Account_Tabbar_type];
    }
}

- (ZFNavigationController *)navigationControllerWithMoudle:(NSInteger)moudle {
    if (self.viewControllers.count > moudle) {
        ZFNavigationController *nav = [self.viewControllers objectAtIndex:moudle];
        if ([nav isKindOfClass:[UINavigationController class]]) {
            return nav;
        }
    }
    return nil;
}

- (void)setZFTabBarIndex:(NSInteger)tabbarIndex {
    if (self.selectedIndex != tabbarIndex && [self tabBarController:self shouldSelectViewController:[self.viewControllers objectAtIndex:tabbarIndex]]) {
        
        // 选中其他Tababr之前先把之前的Nav退到根
        UINavigationController *navVC = self.selectedViewController;
        if ([navVC isKindOfClass:[UINavigationController class]]) {
            if (navVC.viewControllers.count > 1) {
                [navVC popToRootViewControllerAnimated:NO];
            }
        }
        self.selectedIndex = tabbarIndex;
        
    } else {
        // 选中其他Tababr之前先把之前的Nav退到根
        UINavigationController *navVC = self.selectedViewController;
        if ([navVC isKindOfClass:[UINavigationController class]]) {
            if (navVC.viewControllers.count > 1) {
                [navVC popToRootViewControllerAnimated:NO];
            }
        }
    }
}


#pragma mark - 红点
- (void)isShowNewCouponDot {
    if ([[AccountManager sharedManager].account.has_new_coupon boolValue]) {
        [self showBadgeOnItemIndex:TabBarIndexAccount];
    } else {
        [self hideBadgeOnItemIndex:TabBarIndexAccount];
    }
}


/**
 * 将红点提高到最上层
 */
- (void)bringBadgeViewToFront {
    NSArray *subCtrls = self.childViewControllers;
    for (int i=0; i<subCtrls.count; i++) {
        UIView *badgeView = [self.tabBar viewWithTag:(kTabBarBadgeTag + i)];
        if (badgeView) {
            [self.tabBar bringSubviewToFront:badgeView];
        }
    }
}


#pragma mark - ===========通知相关===========

/**
 * 注册通知
 */
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTabbar) name:kChangeSkinNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needLoginAction:) name:kNeedLoginNotification object:nil];
}

/**
 更新tabbar
 */
- (void)updateTabbar {
    [ZFSkinViewModel isNeedToShow:^(BOOL need) {
        UIImage *homeImage              = [UIImage imageNamed:@"tab_home_normal"];
        UIImage *homeSelectedImage      = [UIImage imageNamed:@"tab_home_selected"];
        UIImage *communityImage         = [UIImage imageNamed:@"tab_z-me_normal"];
        UIImage *communitySelectedImage = [UIImage imageNamed:@"tab_z-me_selected"];
        UIImage *personImage            = [UIImage imageNamed:@"tab_account_normal"];
        UIImage *personSelectedImage    = [UIImage imageNamed:@"tab_account_selected"];
        UIImage *tabbarBgImg            = [UIImage zf_createImageWithColor:[UIColor whiteColor]];
        if (need) {
            homeImage               = [ZFSkinViewModel tabbarHomeImage];
            homeSelectedImage       = [ZFSkinViewModel tabbarHomeOnImage];
            communityImage          = [ZFSkinViewModel tabbarCommunityImage];
            communitySelectedImage  = [ZFSkinViewModel tabbarCommunityOnImage];
            personImage             = [ZFSkinViewModel tabbarPersonImage];
            personSelectedImage     = [ZFSkinViewModel tabbarPersonOnImage];
            tabbarBgImg             = [ZFSkinViewModel tabbarBgImage];
            
            ZFSkinModel *appHomeSkinModel = [AccountManager sharedManager].currentHomeSkinModel;
            UIImage *tabbarColorBgImg = [UIImage zf_createImageWithColor:[UIColor colorWithHexString:appHomeSkinModel.bottomColor]];
            tabbarBgImg = appHomeSkinModel.bottomUseType == 1 ? tabbarColorBgImg : tabbarBgImg;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (tabbarBgImg.size.height > self.tabBar.frame.size.height) {
                self.tabBar.shadowImage = [UIImage new];
            }
            
            [self setBabbarBackgroudImage:tabbarBgImg];
            [self setBabbarItemIndex:TabBarIndexHome
                               image:homeImage
                       selectedImage:homeSelectedImage];
            
            [self setBabbarItemIndex:TabBarIndexCommunity
                               image:communityImage
                       selectedImage:communitySelectedImage];
            
            [self setBabbarItemIndex:TabBarIndexAccount
                               image:personImage
                       selectedImage:personSelectedImage];
            
            [self bringBadgeViewToFront];
        });
    }];
}

/**
 * 服务器接口报202时,需要弹出登录页面
 */
- (void)needLoginAction:(NSNotification *)notify {
    //清楚App数据
    [[AccountManager sharedManager] clearUserInfo];
    
    //弹出登录页面
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIViewController currentTopViewController] judgePresentLoginVCCompletion:nil];
    });
    
}
@end
