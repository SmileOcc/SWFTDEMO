//
//  ZF3DTouchManager.m
//  ZZZZZ
//
//  Created by YW on 2018/4/9.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZF3DTouchManager.h"
#import <UIKit/UIKit.h>
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

#define k3DTouchPushSearchType          @"com.ZZZZZ.3DTouch-Search"
#define k3DTouchPushSaveType            @"com.ZZZZZ.3DTouch-Save"
#define k3DTouchPushBagType             @"com.ZZZZZ.3DTouch-MyBag"
#define k3DTouchPushShareType           @"com.ZZZZZ.3DTouch-Share"

@implementation ZF3DTouchManager

/**
 *  注册3DTouch快捷方式
 */
+ (void)register3DTouchShortcut
{
    //搜索
    NSString *searchTitle = ZFLocalizedString(@"3DTouch_icon_Search", nil);
    UIApplicationShortcutIcon *searchIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"3DTouch_search"];
    
    UIApplicationShortcutItem *searchItem = [[UIApplicationShortcutItem alloc] initWithType:k3DTouchPushSearchType localizedTitle:searchTitle localizedSubtitle:nil icon:searchIcon userInfo:nil];
    
    
    //收藏
    NSString *saveTitle = ZFLocalizedString(@"3DTouch_icon_Favorites", nil);
    UIApplicationShortcutIcon *saveIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"3DTouch_save"];
    
    UIApplicationShortcutItem *saveItem = [[UIApplicationShortcutItem alloc] initWithType:k3DTouchPushSaveType localizedTitle:saveTitle localizedSubtitle:nil icon:saveIcon userInfo:nil];
    
    
    //购物车
    NSString *bagTitle = ZFLocalizedString(@"3DTouch_icon_Bag", nil);
    UIApplicationShortcutIcon *bagIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"3DTouch_bag"];
    
    UIApplicationShortcutItem *bagItem = [[UIApplicationShortcutItem alloc] initWithType:k3DTouchPushBagType localizedTitle:bagTitle localizedSubtitle:nil icon:bagIcon userInfo:nil];
    
    
    //注册到APP
    [UIApplication sharedApplication].shortcutItems = @[ bagItem, saveItem, searchItem];
}

/**
 * 处理3DTouch页面跳转
 */
+ (void)dealWith3DTouchPushVC:(UIApplicationShortcutItem *)shortcutItem
{
    //顶层导航控制器
    UIViewController *topVC = [UIViewController currentTopViewController];
    UINavigationController *topNavVC = topVC.navigationController;
    if (![topNavVC isKindOfClass:[UINavigationController class]]) return;
    YWLog(@"处理3DTouch页面跳转==%@==%@",shortcutItem, topNavVC);
    
    if ([shortcutItem.type isEqualToString:k3DTouchPushSearchType]) { //搜索
        [topNavVC pushToViewController:@"ZFSearchViewController" propertyDic:nil animated:NO];
        
    } else if ([shortcutItem.type isEqualToString:k3DTouchPushSaveType]) { //收藏
        [topNavVC pushToViewController:@"ZFCollectionViewController" propertyDic:nil animated:NO];
        
    } else if ([shortcutItem.type isEqualToString:k3DTouchPushBagType]) { //购物车
        [topNavVC pushToViewController:@"ZFCartViewController" propertyDic:nil animated:NO];
    }
    
    //appsFlyer统计
    if (shortcutItem.type.length>0) {
        NSDictionary *valuesDic = @{AFEventParamContentType:ZFToString(shortcutItem.type)};
        [ZFAnalytics appsFlyerTrackEvent:@"af_icon3DTouch" withValues:valuesDic];
    }
    
    //标识已经3DTouch进入App
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AccountManager sharedManager].isAppIcon3DTouchIntoApp = NO;
    });
}


@end
