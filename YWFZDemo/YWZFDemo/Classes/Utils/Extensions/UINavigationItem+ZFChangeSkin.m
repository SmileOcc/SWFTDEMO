//
//  UINavigationItem+ZFChangeSkin.m
//  ZZZZZ
//
//  Created by YW on 2018/7/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "UINavigationItem+ZFChangeSkin.h"
#import "UIImage+ZFExtended.h"
#import "UIImage+ZFExtended.h"
#import "NSObject+Swizzling.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "AccountManager.h"
#import "Constants.h"

#pragma mark -===========系统导航换肤===========

@implementation UINavigationItem (ZFChangeSkin)

/**
 * 监听表格所有的刷新方法
 */
+(void)load {
    // 交换UINavigationItem设置导航左侧按钮方法
    [self swizzleMethod:@selector(setTitleView:)
       swizzledSelector:@selector(zf_setTitleView:)];
    
    
    // 交换UINavigationItem设置导航左侧按钮方法
    [self swizzleMethod:@selector(setLeftBarButtonItems:)
       swizzledSelector:@selector(zf_setLeftBarButtonItems:)];
    
    [self swizzleMethod:@selector(setLeftBarButtonItem:)
       swizzledSelector:@selector(zf_setLeftBarButtonItem:)];
    
    
    // 交换UINavigationItem设置导航右侧按钮方法
    [self swizzleMethod:@selector(setRightBarButtonItems:)
       swizzledSelector:@selector(zf_setRightBarButtonItems:)];
    
    [self swizzleMethod:@selector(setRightBarButtonItem:)
       swizzledSelector:@selector(zf_setRightBarButtonItem:)];
    
    // 销毁时移除通知
    [self swizzleMethod:NSSelectorFromString(@"dealloc")
       swizzledSelector:@selector(zf_dealloc)];
}

- (void)zf_setTitleView:(UIView *)titleView {
    [self zf_setTitleView:titleView];
    
    //注册通知页面上已经显示的按钮换肤
    [self addNotificationToChangeSkin];

    [self changeNavBarItemSkinNotifycation:nil];
}


#pragma mark -定制左侧按钮样式
- (void)zf_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    [self zf_setLeftBarButtonItems:leftBarButtonItems];
    
    //定制左侧多个按钮颜色
    [self setupCustomButtonColor:leftBarButtonItems];
}

- (void)zf_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    [self zf_setLeftBarButtonItem:leftBarButtonItem];
    
    //定制左侧单个按钮颜色
    if (leftBarButtonItem) {
        [self setupCustomButtonColor:@[leftBarButtonItem]];
    }
}

#pragma mark -定制右侧按钮样式
- (void)zf_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems {
    [self zf_setRightBarButtonItems:rightBarButtonItems];
    
    //定制右侧多个按钮颜色
    [self setupCustomButtonColor:rightBarButtonItems];
}

- (void)zf_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
    [self zf_setRightBarButtonItem:rightBarButtonItem];
    
    //定制右侧单个按钮颜色
    if (rightBarButtonItem) {
        [self setupCustomButtonColor:@[rightBarButtonItem]];
    }
}

/**
 * 定制导航按钮颜色样式
 */
- (void)setupCustomButtonColor:(NSArray<UIBarButtonItem *> *)barButtonItems  {
    //注册通知页面上已经显示的按钮换肤
    [self addNotificationToChangeSkin];
    
    if (![AccountManager sharedManager].needChangeAppSkin) return;
    
    for (UIBarButtonItem *barBtnItem in barButtonItems) {
        if (![barBtnItem isKindOfClass:[UIBarButtonItem class]]) continue;
        // UIBarButtonItem换肤
        [self zfChangeBarButtonItemSkin:barBtnItem];
    }
}

/**
 * 注册通知页面上已经显示的按钮换肤
 */
- (void)addNotificationToChangeSkin {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChangeSkinNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNavBarItemSkinNotifycation:) name:kChangeSkinNotification object:nil];
}

/**
 * UINavigationItem 销毁时移除通知
 */
- (void)zf_dealloc {
    [self zf_dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChangeSkinNotification object:nil];
}

/**
 * 通知页面上已经显示的按钮换肤
 */
- (void)changeNavBarItemSkinNotifycation:(NSNotification *)notification {
    // 导航的TitleView
    UIView *titleView = self.titleView;
    if (titleView) {
        [titleView zfChangeSkinToCustomNavgationBar];
    }
    
    // 导航左边按钮
    NSArray *leftBarArr = self.leftBarButtonItems;
    if (leftBarArr.count > 0) {
        for (UIBarButtonItem *barBtnItem in leftBarArr) {
            if ([barBtnItem isKindOfClass:[UIBarButtonItem class]]) {
                [self zfChangeBarButtonItemSkin:barBtnItem];
            }
        }
    } else if(self.leftBarButtonItem){
        [self zfChangeBarButtonItemSkin:self.leftBarButtonItem];
    }
    
    // 导航右边按钮
    NSArray *rightBarArr = self.rightBarButtonItems;
    if (rightBarArr.count > 0) {
        for (UIBarButtonItem *barBtnItem in rightBarArr) {
            if ([barBtnItem isKindOfClass:[UIBarButtonItem class]]) {
                [self zfChangeBarButtonItemSkin:barBtnItem];
            }
        }
    } else if(self.rightBarButtonItem){
        [self zfChangeBarButtonItemSkin:self.rightBarButtonItem];
    }
}

/**
 * UIBarButtonItem 换肤
 */
- (void)zfChangeBarButtonItemSkin:(UIBarButtonItem *)barBtnItem {
    if (![AccountManager sharedManager].needChangeAppSkin) return;
    UIColor *iconColor = [AccountManager sharedManager].appNavIconColor;
    
    UIButton *barBtnCustomView = barBtnItem.customView;
    if ([barBtnCustomView isKindOfClass:[UIButton class]]) {
        [barBtnCustomView zfChangeButtonSkin];
        
    } else if ([barBtnCustomView isKindOfClass:[UILabel class]]) {
        [barBtnCustomView zfChangeLabelSkin];
        
    } else if ([barBtnCustomView isKindOfClass:[UIView class]]) { // UIBarButtonItem.customView 为自定义View
        if (barBtnCustomView.tag == 2018) return; //特殊处理社区主页右上角不处理换肤, 因为头像PDF是全色块
        
        for (UIView *tempSubView in barBtnCustomView.subviews) {
            if ([tempSubView isKindOfClass:[UIButton class]]) {
                [tempSubView zfChangeButtonSkin];
                
            } else if ([tempSubView isKindOfClass:[UILabel class]]) {
                [tempSubView zfChangeLabelSkin];
            }
        }
        
    } else { // 系统的 UIBarButtonItem
        UIImage *originImage = barBtnItem.image;
        if ([originImage isKindOfClass:[UIImage class]]) {
            
            UIImage *convertImage = [originImage imageWithColor:iconColor];
            if ([convertImage isKindOfClass:[UIImage class]]) {
                originImage = [convertImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                barBtnItem.image = originImage;
            }
        }
    }
}

@end

#pragma mark -===========系统导航栏换肤===========

@implementation UINavigationBar (ZFChangeSkin)

- (void)zfChangeSkinToSystemNavgationBar {
    if (![AccountManager sharedManager].needChangeAppSkin) return;
    UIColor *iconColor = [AccountManager sharedManager].appNavIconColor;
    UIColor *titleColor = [AccountManager sharedManager].appNavFontColor;
    UIColor *navBgColor = [AccountManager sharedManager].appNavBgColor;
    UIImage *navBgImage = [AccountManager sharedManager].appNavBgImage;
    
    NSString *backImageName = ([SystemConfigUtils isRightToLeftShow] ? @"nav_arrow_right" : @"nav_arrow_left");
    UIImage *backBtnImage = [UIImage imageNamed:backImageName];
    UIImage *convertImage = [backBtnImage imageWithColor:iconColor];
    if (![convertImage isKindOfClass:[UIImage class]]) return;
    
    backBtnImage = [convertImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UINavigationBar *navBar = self;
    navBar.backIndicatorImage = backBtnImage;
    navBar.backIndicatorTransitionMaskImage = backBtnImage;
    [navBar setTitleTextAttributes:@{ NSFontAttributeName: ZFFontBoldSize(18),
                                      NSForegroundColorAttributeName:titleColor }];
    
    if ([navBgImage isKindOfClass:[UIImage class]]) {
        //UIImage *image = [UIImage imageWithData:UIImagePNGRepresentation(navBgImage) scale:3];
        CGFloat imageHeight = navBar.frame.size.height + STATUSHEIGHT;
        UIImage *showBarBgImage = [UIImage zf_drawImage:navBgImage size:CGSizeMake(KScreenWidth, imageHeight)];
        if ([showBarBgImage isKindOfClass:[UIImage class]]) {
            [navBar setBackgroundImage:showBarBgImage forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
        }
        
    } else if ([navBgColor isKindOfClass:[UIColor class]]){
        [navBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];//去除导航背景图
        navBar.barTintColor = navBgColor;//导航栏背景色
    }
}

@end



#pragma mark -===========自定义导航换肤===========

@implementation UIView (ZFChangeSkin)

/**
 * 切换普通自定义导航条主题色
 */
- (void)zfChangeSkinToCustomNavgationBar {
    if (![AccountManager sharedManager].needChangeAppSkin) return;
    
    // 自定义导航栏氛围色
    UIColor *navBgColor = [AccountManager sharedManager].appNavBgColor;
    UIImage *navBgImage = [AccountManager sharedManager].appNavBgImage;
    [self zfChangeCustomViewSkin:navBgColor skinImage:navBgImage];
    
    for (UIView *navSubView in self.subviews) {
        // 自定义导航栏按钮
        if ([navSubView isKindOfClass:[UIButton class]]) {
            [navSubView zfChangeButtonSkin];
            
        } else if ([navSubView isKindOfClass:[UILabel class]]) {
            // 自定义导航栏标题
            [navSubView zfChangeLabelSkin];
            
        } else if ([navSubView isKindOfClass:[UIImageView class]]) {
            // 自定义导航栏氛围色
            UIColor *navBgColor = [AccountManager sharedManager].appNavBgColor;
            UIImage *navBgImage = [AccountManager sharedManager].appNavBgImage;
            [navSubView zfChangeCustomViewSkin:navBgColor skinImage:navBgImage];
        }
    }
}

/**
 * 切换需要滚动渐变导航条背景色
 */
- (BOOL)zfChangeSkinToShadowNavgationBar {
    if (![AccountManager sharedManager].needChangeAppSkin) return NO;
    
    for (UIView *navSubView in self.subviews) {
        // 自定义导航栏按钮
        if ([navSubView isKindOfClass:[UIButton class]]) {
            [navSubView zfChangeButtonSkin];
            
        } else if ([navSubView isKindOfClass:[UILabel class]]) {
            // 自定义导航栏标题
            [navSubView zfChangeLabelSkin];
        }
    }
    return YES;
}

/**
 * 自定义UIView换肤
 */
- (BOOL)zfChangeCustomViewSkin:(UIColor *)skinColor skinImage:(UIImage *)skinImage {
    if (![self isKindOfClass:[UIView class]]) return NO;
    if (![AccountManager sharedManager].needChangeAppSkin) return NO;
    
    if ([skinImage isKindOfClass:[UIImage class]]) {
        if ([self isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)self;
            //imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.image = skinImage;
            return YES;
            
        } else if ([self isKindOfClass:[UIView class]]) {
            self.layer.contents = (id)skinImage.CGImage;
            return YES;
        }
        
    } else if ([skinColor isKindOfClass:[UIColor class]]) {
        self.backgroundColor = skinColor;
        return YES;
    }
    return NO;
}

/**
 * 按钮换肤
 */
- (void)zfChangeButtonSkin {
    if (![self isKindOfClass:[UIButton class]]) return;
    if (![AccountManager sharedManager].needChangeAppSkin) return;
    
    UIButton *navSubBtn = (UIButton *)self;
    
    // Normal 状态图标颜色
    [navSubBtn setZFBtnImageForState:UIControlStateNormal];
    // Selected 状态图标颜色
    [navSubBtn setZFBtnImageForState:UIControlStateSelected];
    // Disabled 状态图标颜色
    [navSubBtn setZFBtnImageForState:UIControlStateDisabled];
    
    // Normal 状态标题颜色
    [navSubBtn setZFBtnTitleColorForState:UIControlStateNormal];
    // Selected 状态标题颜色
    [navSubBtn setZFBtnTitleColorForState:UIControlStateSelected];
    // Disabled 状态标题颜色
    [navSubBtn setZFBtnTitleColorForState:UIControlStateDisabled];
}

/**
 * 根据状态设置按钮图标颜色
 */
- (void)setZFBtnImageForState:(UIControlState)buttonState {
    if (![self isKindOfClass:[UIButton class]]) return;
    UIButton *button = (UIButton *)self;
    
    if (![AccountManager sharedManager].needChangeAppSkin) return;
    
    UIImage *originImage =[button imageForState:buttonState];
    if (originImage) {
        UIColor *iconColor = [AccountManager sharedManager].appNavIconColor;
        UIImage *convertImage = [originImage imageWithColor:iconColor];
        if ([convertImage isKindOfClass:[UIImage class]]) {
            originImage = [convertImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [button setImage:originImage forState:0];
        }
    }
}

/**
 * 根据状态设置按钮标题颜色
 */
- (void)setZFBtnTitleColorForState:(UIControlState)buttonState {
    if (![self isKindOfClass:[UIButton class]]) return;
    UIButton *button = (UIButton *)self;
    
    if (![AccountManager sharedManager].needChangeAppSkin) return;
    
    UIColor *originTitleColor =[button titleColorForState:buttonState];
    if (originTitleColor) {
        UIColor *titleColor = [AccountManager sharedManager].appNavFontColor;
        
        if (buttonState == UIControlStateDisabled) {
            titleColor = [titleColor colorWithAlphaComponent:0.5];
        }
        [button setTitleColor:titleColor forState:buttonState];
    }
}

/**
 * 文本换肤
 */
- (void)zfChangeLabelSkin {
    if (![self isKindOfClass:[UILabel class]]) return;
    UILabel *label = (UILabel *)self;
    
    if (![AccountManager sharedManager].needChangeAppSkin) return;
    UIColor *titleColor = [AccountManager sharedManager].appNavFontColor;
    
    label.font = ZFFontBoldSize(18);
    label.textColor = titleColor;
}

@end

