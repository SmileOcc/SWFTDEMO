//
//  AppDelegate.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
@import Firebase;
@import GoogleSignIn;



@interface AppDelegate : UIResponder
<
UIApplicationDelegate,UNUserNotificationCenterDelegate,
GIDSignInDelegate
>

@property (strong, nonatomic) UIWindow              *window;
@property (nonatomic, strong) OSSVTabBarVC   *tabBarVC;
@property (nonatomic,strong) UIView                 *notificationTipView;

@property (nonatomic, strong) STLNetworkStateManager   *stateManager;
@property (nonatomic, strong) UIView                   *networkBackgroundView;
@property (nonatomic, assign) BOOL                     isDeepLinkEventing;


- (void)onlineAddressInfo:(void (^)())execute;
- (void)localDeeplinkAction;
@end

