//
//  ZFCustomerManager.m
//  ZZZZZ
//
//  Created by YW on 2018/6/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCustomerManager.h"
#import "ZFMyOrderListViewController.h"
#import "UIImage+ZFExtended.h"
#import "YWLocalHostManager.h"
#import "IQKeyboardManager.h"
#import "SystemConfigUtils.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "Configuration.h"
#import "ZFContactUsViewController.h"

@import GlobalegrowIMSDK;

@implementation ZFCustomerManager

#pragma mark - 初始化 客服单利 单例

+ (instancetype)shareInstance {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static ZFCustomerManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

/**
 * 在聊天页面点击图片/文件跳转到系统浏览器打开
 */
- (void)handleWithURL:(NSURL *)URL {
    [[UIApplication sharedApplication] openURL:URL];
}

/**
 * 携带商品信息弹出客服聊天页面
 */
- (void)presentLiveChatWithGoodsInfo:(NSString *)goodsInfo {
    [ChatConfig share].goodsInfo = goodsInfo;
    [self presentLiveChat];
}

/**
 * 弹出客服聊天页面
 */
- (void)presentLiveChat {
    [[UIViewController currentTopViewController] judgePresentLoginVCCompletion:^{
        [IQKeyboardManager sharedManager].enable = NO;
        [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
        
        [ChatConfig share].userName  = ZFToString([AccountManager sharedManager].account.nickname);
        [ChatConfig share].email     = ZFToString([AccountManager sharedManager].account.email);
        [ChatConfig share].avatarURL = ZFToString([AccountManager sharedManager].account.avatar);
        [ChatConfig share].webSiteKey = ZF_WEBSITE_KEY;

        // 特殊处理导航栏换肤
        UIImage *originImage = [UIImage imageNamed:([SystemConfigUtils isRightToLeftShow] ? @"nav_arrow_right" : @"nav_arrow_left")];
        if ([AccountManager sharedManager].needChangeAppSkin) {
            [ChatConfig share].navigationTitleColor = [AccountManager sharedManager].appNavFontColor;
            [ChatConfig share].navigationBarColor = [AccountManager sharedManager].appNavBgColor;
            originImage = [originImage imageWithColor:[AccountManager sharedManager].appNavIconColor];
        }
        // 返回按钮图标
        [ChatConfig share].backImage = originImage;
        
        [ChatConfig share].isDebug = ![YWLocalHostManager isOnlineRelease];
//        [ChatConfig share].isLog   = YES;
        [ChatViewController shared].menuToolItemHandle = ^(NSInteger index) {
            switch (index) {
                case 0: {
                    ZFMyOrderListViewController *orderListViewController = [[ZFMyOrderListViewController alloc] init];
                    orderListViewController.isFromChat = YES;
                    [[ChatViewController shared].navigationController pushViewController:orderListViewController animated:YES];
                    orderListViewController.selectedOrderHandle = ^(NSString *orderSN) {
                        [[ChatViewController shared] sendMenuMessageWithMessage:orderSN];
                    };
                    break;
                }
                default:
                    break;
            }
        };
        
        ChatConfig.share.turnBackHandle = ^{
            [IQKeyboardManager sharedManager].enable = YES;
            [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
        };
        
        // app内部自己实现的ticket功能页面
        [ChatConfig share].ticketHandle = ^(NSString * url) {
            ZFContactUsViewController *webVC = [[ZFContactUsViewController alloc]init];
            webVC.link_url = url;
            [[ChatViewController shared].navigationController pushViewController:webVC animated:YES];
        };
        
        // 跳转
        id currentVC = [UIViewController currentTopViewController];
        if ([currentVC isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)currentVC setNavigationBarHidden:NO animated:NO];
            [(UINavigationController *)currentVC pushViewController:[ChatViewController shared] animated:YES];
        } else {
            UIViewController *vc = (UIViewController *)currentVC;
            [vc.navigationController setNavigationBarHidden:NO animated:NO];
            [vc.navigationController pushViewController:[ChatViewController shared] animated:YES];
        }
    }];
}

@end
