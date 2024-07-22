//
//  UITabBarController+ZFExtension.m
//  ZZZZZ
//
//  Created by YW on 2018/3/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "UITabBarController+ZFExtension.h"
#import "ZFCommunityHomeVC.h"
#import <objc/runtime.h>
#import "ZFThemeManager.h"
#import "NSArray+SafeAccess.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"

#pragma mark =============================自定义UITabBar======================================

@interface ZFAppTabBar : UITabBar
/** 重复点击tabBar回调 */
@property (nonatomic, copy) void (^repeatTouchDownItemBlock)(UITabBarItem *item);
@end

@implementation ZFAppTabBar

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSInteger index = 0;
    for (UIControl *button in self.subviews) {
        if (![button isKindOfClass:[UIControl class]]) continue;
        button.tag = index;
        
        // 增加索引
        index++;
        //添加双击事件
        [button addTarget:self action:@selector(repeatClickButton:) forControlEvents:UIControlEventTouchDownRepeat];
    }
}

#pragma mark - 添加tabbar双击事件

/**
 * 双击tabbar按钮事件
 */

- (void)repeatClickButton:(UIControl *)button
{
    if (self.items.count>button.tag) {
        if (self.repeatTouchDownItemBlock) {
            UITabBarItem *touchItem = self.items[button.tag];
            self.repeatTouchDownItemBlock(touchItem);
        }
    }
}

@end

#pragma mark ====================扩展当前Tabbar,添加双击事件====================

@interface UITabBarController ()
@property (nonatomic, strong) ZFAppTabBar *appTabBar;
@end

@implementation UITabBarController (ZFExtension)

#pragma mark - ========== 自定义TabBar ==========

- (void)setAppTabBar:(ZFAppTabBar *)appTabBar;
{
    objc_setAssociatedObject(self, "ZFAppTabBar", appTabBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ZFAppTabBar *)appTabBar
{
    return objc_getAssociatedObject(self, "ZFAppTabBar");
}

/**
 * 在页面上懒加载初始化TabBar
 */
- (void)setupZFTabBarSkin
{
    if (!self.appTabBar) {
        self.appTabBar = [[ZFAppTabBar alloc] initWithFrame:self.tabBar.bounds];
        @weakify(self) //监听重复点击tabBar回调
        [self.appTabBar setRepeatTouchDownItemBlock:^(UITabBarItem *item) {
            @strongify(self)
            [self didRepeatTouchDownTabBarItem:item];
        }];
        [self setValue:self.appTabBar forKeyPath:@"tabBar"];
    }
}

#pragma mark - 监听tabBar双击事件

/**
 * 监听重复点击tabBar按钮事件
 */
- (void)didRepeatTouchDownTabBarItem:(UITabBarItem *)item
{
    //YWLog(@"重复点击tabBar按钮事件, 页面上可监听 repeatTouchTabBarToViewController:方法处理相应逻辑");
    NSInteger touchIndex = [self.tabBar.items indexOfObject:item];
    if (self.viewControllers.count > touchIndex) {
        UIViewController *touchItemVC = self.viewControllers[touchIndex];
        
        if ([touchItemVC isKindOfClass:[UINavigationController class]]) {
            touchItemVC = [((UINavigationController *)touchItemVC).viewControllers firstObject];
        }
        
        // 下面只服务于 首页 tab 双击
        NSArray *VCArray = touchItemVC.childViewControllers;
        if (VCArray.count > 0) {
            touchItemVC = [VCArray objectWithIndex:0];
        }
        
        //忽略警告
        ZFPerformSelectorLeakWarning(
            if ([touchItemVC respondsToSelector:@selector(repeatTouchTabBarToViewController:)]) {
                [touchItemVC performSelector:@selector(repeatTouchTabBarToViewController:) withObject:touchItemVC];
            }
        );
    }
}

#pragma mark - setter
- (void)setBabbarBackgroudImage:(UIImage *)image {
    if (!image) {
        return;
    }
    BOOL haveSet = NO;
    for (UIView *tempBarBackground in self.tabBar.subviews) {
        if ([tempBarBackground isKindOfClass:NSClassFromString(@"_UIBarBackground")]
            || ([tempBarBackground isKindOfClass:NSClassFromString(@"_UITabBarBackgroundView")] && kiOSSystemVersion < 10.0)) {
            tempBarBackground.backgroundColor = [UIColor clearColor];
            tempBarBackground.layer.contents = (id)image.CGImage;
            haveSet = YES;
        }
    }
    
    if (!haveSet) {
        self.tabBar.backgroundImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

- (void)setBabbarItemIndex:(NSInteger)index image:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    
    if (self.viewControllers.count > index && image) {
        ZFNavigationController *navigationController = [self.viewControllers objectAtIndex:index];
        navigationController.tabBarItem.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        navigationController.tabBarItem.selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        navigationController.tabBarItem.title = nil; //设置图片时需要清掉Tab标题
        [navigationController.tabBarItem setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
        navigationController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, 0);
    }
}


- (void)showBadgeOnItemIndex:(NSInteger)index{
    
    //适配阿语
    NSInteger itemCount = self.tabBar.items.count;
    index = [SystemConfigUtils isRightToLeftShow] ? itemCount - index -1 : index;
    
    //移除之前的小红点
    [self removeBadgeOnItemIndex:index];
    
    //新建小红点
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = kTabBarBadgeTag + index;
    badgeView.backgroundColor = ZFC0xFE5269();
    
    
    //确定小红点的位置
    CGRect tabFrame = self.tabBar.frame;
    CGFloat spaceY = IPHONE_X_5_15 ? 2 : 5;
    float percentX = (index +0.6) / itemCount;
    CGFloat centerX = floorf(percentX * tabFrame.size.width) + 3;
    CGFloat centerY = floorf(0.1 * tabFrame.size.height) + spaceY;
    badgeView.frame = CGRectMake(centerX, centerY, 8, 8);
    badgeView.layer.cornerRadius = badgeView.frame.size.width/2;

    //centerX = itemWidth / 2.0 + itemWidth * index + itemImageWidth / 2.0;
    badgeView.center = CGPointMake(centerX, centerY);

    [self.tabBar addSubview:badgeView];
}

- (void)hideBadgeOnItemIndex:(NSInteger)index{
    //移除小红点
    [self removeBadgeOnItemIndex:index];
}

- (void)removeBadgeOnItemIndex:(NSInteger)index{
    //适配阿语
    index = [SystemConfigUtils isRightToLeftShow] ? self.tabBar.items.count - index -1 : index;
    //按照tag值进行移除
    UIView *dotView = [self.tabBar viewWithTag:(kTabBarBadgeTag + index)];
    if (dotView) {
        [dotView removeFromSuperview];
    }
}

- (void)updateBadgeOnItemIndex:(NSInteger)index hide:(BOOL)hide{
    //适配阿语
    index = [SystemConfigUtils isRightToLeftShow] ? self.tabBar.items.count - index -1 : index;
    
    UIView *dotView = [self.tabBar viewWithTag:(kTabBarBadgeTag + index)];
    if (dotView) {
        dotView.hidden = hide;
    }
}

- (void)resetBadgeOnItems:(NSArray *)indexsArray {
    
    for(int i=0; i<5; i++) {
        UIView *dotView = [self.tabBar viewWithTag:(kTabBarBadgeTag + i)];
        if (dotView) {
            [dotView removeFromSuperview];
        }
    }
    
    if (!indexsArray) {
        return;
    }
    if ([indexsArray isKindOfClass:[NSArray class]]) {
        for (NSNumber *numberIndex in indexsArray) {
            NSInteger index = [numberIndex integerValue];
            [self showBadgeOnItemIndex:index];
        }
    }
}
@end
