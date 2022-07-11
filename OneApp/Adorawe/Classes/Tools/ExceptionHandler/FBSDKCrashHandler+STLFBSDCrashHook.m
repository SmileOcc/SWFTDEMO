//
//  FBSDKCrashHandler+STLFBSDCrashHook.m
// XStarlinkProject
//
//  Created by odd on 2021/6/11.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "FBSDKCrashHandler+STLFBSDCrashHook.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>

#import "NSObjectSafe.h"
#import "OSSVAppsCrashsAip.h"

@implementation FBSDKCrashHandler (STLFBSDCrashHook)

+ (void)load {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL origSel = @selector(_saveException:) ;
    SEL altSel = @selector(_saveExceptionHook:) ;
    [self swizzleClassMethod:origSel withMethod:altSel];
#pragma clang diagnostic pop
    
}
 
+ (void) _saveExceptionHook:(NSException *)exception {

    [self validateAndSaveCriticalApplicationData:exception];

    [self _saveExceptionHook:exception];  
}

//处理报错信息
+ (void)validateAndSaveCriticalApplicationData:(NSException *)exception {
    
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"\n--------Log Exception---------\nappInfo             :\n%@\n\nexception name      :%@\nexception reason    :%@\nexception userInfo  :%@\ncallStackSymbols    :%@\n\n--------End Log Exception-----", getCrashAppInfo(),exception.name, exception.reason, exception.userInfo ? : @"no user info", [exception callStackSymbols]];
    
    NSLog(@"-------------- 崩溃: %@", exceptionInfo);
    //    [exceptionInfo writeToFile:[NSString stringWithFormat:@"%@/Documents/error.log",NSHomeDirectory()]  atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
   //获取deviceInfo信息
    NSDictionary *dic = @{@"device_id"          : STLToString([OSSVAccountsManager sharedManager].device_id),
                          @"udid"               : STLToString([OSSVAccountsManager sharedManager].device_id),
                          @"app_version"        : kAppVersion,
                          @"user_id"            : USERID_STRING,
                          @"os_version"         : STLToString([[STLDeviceInfoManager sharedManager] getDeviceVersion]),
                          @"language"           : STLToString([STLLocalizationString shareLocalizable].nomarLocalizable),
                          @"currency"           : [ExchangeManager localTypeCurrency],
                          @"device_type"        : @"iOS",
                          @"device_model"       : STLToString([[STLDeviceInfoManager sharedManager] getDeviceType]),
                          @"device_version"     : STLToString([[STLDeviceInfoManager sharedManager] getDeviceVersion])
    };

    NSString *parJson = [dic yy_modelToJSONString];
    NSString *crashInfo = [NSString stringWithFormat:@"%@,%@,%@,%@,#callStackSymbolsBegin#%@#callStackSymbolsEnd#", getCrashAppInfo(),exception.name, exception.reason, exception.userInfo ? : @"no user info", [exception callStackSymbols]];
    [self reportAppCrashInfo:crashInfo deviceInfo:parJson];

}

#pragma mark ----崩溃时候上报给后台
+ (void)reportAppCrashInfo:(NSString *)crashInfo deviceInfo:(NSString *)deviceInfo {
    
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease]) {
        
        [[STLNetworkStateManager sharedManager] networkState:^{
            OSSVAppsCrashsAip *api = [[OSSVAppsCrashsAip alloc] initWithReportAppCrashDeviceInfo:deviceInfo crashInfo:crashInfo];
            [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
                if ([requestJSON isKindOfClass:[NSDictionary class]]) {
                    if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
                            
                    }
                }

            } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            
            }];
            
        } exception:^{
            
        }];
    }
}

NSString* getCrashAppInfo() {
    
    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@\nOS Version : %@ %@\n",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                         [UIDevice currentDevice].model,
                         [UIDevice currentDevice].systemName,
                         [UIDevice currentDevice].systemVersion];
    return appInfo;
}
 

@end
