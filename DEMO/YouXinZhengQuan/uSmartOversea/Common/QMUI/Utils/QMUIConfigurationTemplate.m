//
//  QMUIConfigurationTemplate.m
//  qmui
//
//  Created by QMUI Team on 15/3/29.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIConfigurationTemplate.h"

@implementation QMUIConfigurationTemplate

#pragma mark - <QMUIConfigurationTemplateProtocol>

- (void)applyConfigurationTemplate {
    #pragma mark - Others
    QMUICMI.sendAnalyticsToQMUITeam = NO;                                      // SendAnalyticsToQMUITeam : 是否允许在 DEBUG 模式下上报 Bundle Identifier 和 Display Name 给 QMUI 统计用
    QMUICMI.needsBackBarButtonItemTitle = NO;                                   // NeedsBackBarButtonItemTitle : 全局是否需要返回按钮的 title，不需要则只显示一个返回image
    
    if (@available(iOS 15.0, *)) {
        QMUICMI.navBarUsesStandardAppearanceOnly = YES;
        QMUICMI.navBarRemoveBackgroundEffectAutomatically = YES;
        QMUICMI.tabBarUsesStandardAppearanceOnly = YES;
        QMUICMI.tabBarRemoveBackgroundEffectAutomatically = YES;
        QMUICMI.toolBarUsesStandardAppearanceOnly = YES;
        QMUICMI.toolBarRemoveBackgroundEffectAutomatically = YES;
        QMUICMI.tableViewSectionHeaderTopPadding = 0;
    }
    
    QMUICMI.tableViewSeparatorColor = QMUITheme.separatorLineColor;             // TableViewSeparatorColor : 列表的分隔线颜色
    QMUICMI.tableViewCellBackgroundColor = QMUITheme.foregroundColor;           // TableViewCellBackgroundColor : QMUITableViewCell 的背景色
    #pragma mark - UIWindowLevel
    QMUICMI.windowLevelQMUIAlertView = UIWindowLevelAlert - 4.0;                // UIWindowLevelQMUIAlertView : QMUIModalPresentationViewController、QMUIPopupContainerView 里使用的 UIWindow 的 windowLevel
    QMUICMI.windowLevelQMUIConsole = 1;                                         // UIWindowLevelQMUIConsole : QMUIConsole 内部的 UIWindow 的 windowLevel
    QMUICMI.backgroundColor = QMUITheme.foregroundColor;                                     // UIColorForBackground : 界面背景色，默认用于 QMUICommonViewController.view 的背景色
    QMUICMI.hidesBottomBarWhenPushedInitially = YES;                            // HidesBottomBarWhenPushedInitially : QMUICommonViewController.hidesBottomBarWhenPushed 的初始值，默认为 NO，以保持与系统默认值一致，但通常建议改为 YES，因为一般只有 tabBar 首页那几个界面要求为 NO
    
    QMUICMI.tabBarShadowImageColor = QMUITheme.separatorLineColor;                          // TabBarShadowImageColor : UITabBar 的 shadowImage
    
#pragma mark - NavigationBar
    QMUICMI.navBarHighlightedAlpha = 0.2f;                                      // NavBarHighlightedAlpha : QMUINavigationButton 在 highlighted 时的 alpha
    QMUICMI.navBarDisabledAlpha = 0.2f;                                         // NavBarDisabledAlpha : QMUINavigationButton 在 disabled 时的 alpha
    QMUICMI.navBarButtonFont = UIFontMake(14);                                  // NavBarButtonFont : QMUINavigationButtonTypeNormal 的字体（由于系统存在一些 bug，这个属性默认不对 UIBarButtonItem 生效）
    //    QMUICMI.navBarButtonFontBold = UIFontBoldMake(17);                          // NavBarButtonFontBold : QMUINavigationButtonTypeBold 的字体
    QMUICMI.navBarBackgroundImage = [UIImage imageNamed:@"nav_bg"];   // NavBarBackgroundImage : UINavigationBar 的背景图，注意 navigationBar 的高度会受多个因素（是否全面屏、是否使用了 navigationItem.prompt、是否将 UISearchBar 作为 titleView）的影响，要检查各种情况是否都显示正常。
    QMUICMI.navBarShadowImage = [UIImage qmui_imageWithColor:[UIColor clearColor] size:CGSizeMake(1, 1) cornerRadius:0];                                                  // NavBarShadowImage : UINavigationBar.shadowImage，也即导航栏底部那条分隔线
    QMUICMI.navBarShadowImageColor = [UIColor clearColor];
    QMUICMI.navBarBarTintColor = nil;                                    // NavBarBarTintColor : UINavigationBar.barTintColor，也即背景色
    QMUICMI.navBarTintColor = QMUITheme.textColorLevel1;                               // NavBarTintColor : QMUINavigationBar 的 tintColor，也即导航栏上面的按钮颜色
    QMUICMI.navBarTitleColor = QMUITheme.textColorLevel1;                              // NavBarTitleColor : UINavigationBar 的标题颜色，以及 QMUINavigationTitleView 的默认文字颜色
    QMUICMI.navBarTitleFont = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];                                   // NavBarTitleFont : UINavigationBar 的标题字体，以及 QMUINavigationTitleView 的默认字体
    QMUICMI.navBarLargeTitleColor = nil;                                        // NavBarLargeTitleColor : UINavigationBar 在大标题模式下的标题颜色，仅在 iOS 11 之后才有效
    QMUICMI.navBarLargeTitleFont = nil;                                         // NavBarLargeTitleFont : UINavigationBar 在大标题模式下的标题字体，仅在 iOS 11 之后才有效
    QMUICMI.navBarBackButtonTitlePositionAdjustment = UIOffsetZero;             // NavBarBarBackButtonTitlePositionAdjustment : 导航栏返回按钮的文字偏移
    QMUICMI.sizeNavBarBackIndicatorImageAutomatically = false;                    // SizeNavBarBackIndicatorImageAutomatically : 是否要自动调整 NavBarBackIndicatorImage 的 size 为 (13, 21)
    QMUICMI.navBarBackIndicatorImage = [[UIImage imageNamed:@"nav_back"] qmui_imageWithSpacingExtensionInsets:UIEdgeInsetsMake(0, [UIScreen mainScreen].scale > 2 ? 3 : 7, 0, 0)];                                     // NavBarBackIndicatorImage : 导航栏的返回按钮的图片，图片尺寸建议为(13, 21)，否则最终的图片位置无法与系统原生的位置保持一致
    QMUICMI.navBarCloseButtonImage = [UIImage qmui_imageWithShape:QMUIImageShapeNavClose size:CGSizeMake(16, 16) tintColor:QMUITheme.textColorLevel1];
        
#pragma mark - TableView
    QMUICMI.tableViewCellSelectedBackgroundColor = QMUITheme.backgroundColor;  // TableViewCellSelectedBackgroundColor : QMUITableViewCell 点击时的背景色
    QMUICMI.tableViewCellBackgroundColor = QMUITheme.foregroundColor;                 // TableViewCellBackgroundColor : QMUITableViewCell 的背景色
    QMUICMI.tableViewGroupedCellBackgroundColor = QMUITheme.foregroundColor;
    
}

// QMUI 2.3.0 版本里，配置表新增这个方法，返回 YES 表示在 App 启动时要自动应用这份配置表。仅当你的 App 里存在多份配置表时，才需要把除默认配置表之外的其他配置表的返回值改为 NO。
- (BOOL)shouldApplyTemplateAutomatically {
    return YES;
}

@end
