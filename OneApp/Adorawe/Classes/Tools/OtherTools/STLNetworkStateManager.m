//
//  STLNetworkStateManager.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLNetworkStateManager.h"
#import <objc/runtime.h>
#import "AFNetworkReachabilityManager.h"
#import "AppDelegate.h"

/** 记住上一次的网络状态key */
static char const * const kRememberReachabilityStatusKey = "kRememberReachabilityStatusKey";
typedef void(^FailNetworkBlock)();

@interface STLNetworkStateManager ()

@property (nonatomic, strong) UIAlertView *windowAlert;

@property (nonatomic, copy) FailNetworkBlock failNetworkBlock;

@property (nonatomic, assign) BOOL        hadGetReachabilityState;

@end

@implementation STLNetworkStateManager

+ (STLNetworkStateManager *)sharedManager {
    static STLNetworkStateManager *networkStateManager = nil;
    static dispatch_once_t networkOnceToken;
    dispatch_once(&networkOnceToken, ^{
        networkStateManager = [[self alloc] init];
        [networkStateManager settingNetworkState];
    });
    return networkStateManager;
}

- (void)settingNetworkState {
    _curStatus = [GLobalRealReachability currentReachabilityStatus];
}

- (void)tipView
{
    //@"Sorry! No internet connection means no Adorawe"
//    _windowAlert = [[UIAlertView alloc] initWithTitle:STLLocalizedString_(@"networkError",nil)
//                                              message:STLLocalizedString_(@"networkErrorMsg",nil)
//                                             delegate:nil
//                                    cancelButtonTitle:STLLocalizedString_(@"retry",nil)
//                                    otherButtonTitles:nil];
//    _windowAlert.delegate = self;
//    if (@available(iOS 13.0, *)) {
//        _windowAlert.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
//    }
//
//    [_windowAlert show];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        STLAlertViewController *alertController =  [STLAlertViewController alertControllerWithTitle: STLLocalizedString_(@"networkError",nil) message: STLLocalizedString_(@"networkErrorMsg",nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * doneAction = [UIAlertAction actionWithTitle:STLLocalizedString_(@"retry",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { }];
        [alertController addAction:doneAction];


        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        vc = vc.presentedViewController ?: vc;

        AppDelegate *app =(AppDelegate *)[UIApplication sharedApplication].delegate;
        vc = app.window.rootViewController;

        if (vc) {
            [vc presentViewController:alertController animated:YES completion:nil];
        }
    });

    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    @weakify(self);
    [GLobalRealReachability reachabilityWithBlock:^(ReachabilityStatus status) {
        @strongify(self);
        _curStatus = status;
        switch (status) {
            case RealStatusUnknown:
            case RealStatusNotReachable:
            {
//                [self tipView];
                break;
            }
            case RealStatusViaWWAN:
            case RealStatusViaWiFi:
            {
                self.failNetworkBlock();
                break;
            }
        }
    }];
}

- (void)networkStateCheck:(void (^)())executeBlock exception:(void (^)())exceptionBlock {
    if (!isOpenRealReachability) { // 关闭网络监控
        if (executeBlock) {
            executeBlock();
        }
        return;
    }

    @weakify(self);
    [GLobalRealReachability reachabilityWithBlock:^(ReachabilityStatus status) {
        @strongify(self);
        self.curStatus = status;
        switch (status) {
            case RealStatusUnknown:
            case RealStatusNotReachable:
            {
                //[self tipView];
                self.failNetworkBlock = executeBlock;
                break;
            }
            case RealStatusViaWWAN:
            case RealStatusViaWiFi:
            {
                if (executeBlock) {
                    executeBlock();
                }
                break;
            }
        }
    }];
}

- (void)networkState:(void (^)())executeBlock exception:(void (^)())exceptionBlock {
    if (!isOpenRealReachability) {  // 关闭网络监控
        if (executeBlock) {
            executeBlock();
        }
        return;
    }
    
    if ([STLNetworkStateManager isReachable]) {
        if (executeBlock) {
            executeBlock();
        }
    } else {
        if (exceptionBlock) {
            exceptionBlock();
        }
    }
}

#pragma mark - 网络状态的实时检测；
+ (void)isNetWorkStateReachable:(void (^)())executeBlock exception:(void (^)())exceptionBlock{
    
    AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [afNetworkReachabilityManager startMonitoring];  //开启网络监视器；
    
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(afNetworkStatusChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    [afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:{
                STLLog(@"网络不通");
                if (exceptionBlock) {
                    exceptionBlock();
                }
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                STLLog(@"网络通过WIFI连接");
                if (executeBlock) {
                    executeBlock();
                }
                break;
            }
                
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                STLLog(@"网络通过无线连接");
                if (executeBlock) {
                    executeBlock();
                }
                break;
            }
            default:
                break;
        }
        STLLog(@"网络状态数字返回：%ld", (long)status);
        STLLog(@"网络状态返回: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
}

+(void)initialize
{
    //开始监听网络
    [self startMonitoringSTLReachability];
}

/**
 *  开始监听网络状态
 */
+ (void)startMonitoringSTLReachability {
    AFNetworkReachabilityManager *reachManager = [AFNetworkReachabilityManager sharedManager];
    [reachManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        [STLNetworkStateManager sharedManager].hadGetReachabilityState = YES;
        //1.记住改变网络后的网络状态
        objc_setAssociatedObject([AFNetworkReachabilityManager sharedManager], kRememberReachabilityStatusKey, @(status), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        //2.如果其他地方需要监听网络,可以发通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_NetWorkStatusChange object:nil];
    }];
    [reachManager startMonitoring];
}

/**
 *  监听网络改变回调
 */
+ (void)reachabilityChangeBlock:(void (^)(AFNetworkReachabilityStatus currentStatus, AFNetworkReachabilityStatus beforeStatus))block {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
        id obj = objc_getAssociatedObject(manager, kRememberReachabilityStatusKey);
        if (obj) {
            AFNetworkReachabilityStatus oldStatus = [obj integerValue];
            if (block) {
                block(status,oldStatus);
            }
        } else {
            if (block) {
                block(status,AFNetworkReachabilityStatusUnknown);
            }
        }
        //记住改变网络后的网络状态
        objc_setAssociatedObject(manager, kRememberReachabilityStatusKey, @(status), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
}

/**
 *  网络是否可用
 */
+ (BOOL)isReachable  {
    
    if (![STLNetworkStateManager sharedManager].hadGetReachabilityState) {
        return YES;
    }
    BOOL reachable = [AFNetworkReachabilityManager sharedManager].isReachable;
    return reachable;
}

/**
 *  是否为手机运营商网络
 */
+ (BOOL)isReachableViaWWAN {
    if (![STLNetworkStateManager sharedManager].hadGetReachabilityState) {
        return YES;
    }
    BOOL isWWAN = [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN;
    return isWWAN;
}

/**
 *  是否WIFI网络
 */
+ (BOOL)isReachableViaWiFi {
    if (![STLNetworkStateManager sharedManager].hadGetReachabilityState) {
        return YES;
    }
    BOOL isWiFi = [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
    return isWiFi;
}

@end
