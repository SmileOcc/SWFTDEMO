//
//  UncaughtExceptionHandler.m
//  UncaughtExceptionHandler
//
//  Created by Guojh on 2017/3/30.
//  Copyright © 2017年 Qihb. All rights reserved.
//

#import "UncaughtExceptionUtil.h"
#import "OSSVConfigDomainsManager.h"
#import "CacheFileManager.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "FBSDKCrashHandler.h"
#import "OSSVAppsCrashsAip.h"

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

static BOOL showAlertView = nil;

void HandleException(NSException *exception);
void SignalHandler(int signal);
NSString* getAppInfo();


@interface UncaughtExceptionUtil()
@property (assign, nonatomic) BOOL dismissed;
@property (assign, nonatomic) BOOL isCountinue;

@end

@implementation UncaughtExceptionUtil


+ (UncaughtExceptionUtil *)sharedManager{
    static UncaughtExceptionUtil *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[UncaughtExceptionUtil alloc]init];
    });
    return sharedManager;
}

+ (void)installUncaughtExceptionHandler:(BOOL)install showAlert:(BOOL)showAlert {
    
    if (install && showAlert) {
        [[self alloc] alertView:showAlert];
    }
    
    NSSetUncaughtExceptionHandler(install ? HandleException : NULL);
    signal(SIGABRT, install ? SignalHandler : SIG_DFL);
    signal(SIGILL, install ? SignalHandler : SIG_DFL);
    signal(SIGSEGV, install ? SignalHandler : SIG_DFL);
    signal(SIGFPE, install ? SignalHandler : SIG_DFL);
    signal(SIGBUS, install ? SignalHandler : SIG_DFL);
    signal(SIGPIPE, install ? SignalHandler : SIG_DFL);
}

- (void)alertView:(BOOL)show {
    
    showAlertView = show;
}

//获取调用堆栈
+ (NSArray *)backtrace {
    
    //指针列表
    void* callstack[128];
    //backtrace用来获取当前线程的调用堆栈，获取的信息存放在这里的callstack中
    //128用来指定当前的buffer中可以保存多少个void*元素
    //返回值是实际获取的指针个数
    int frames = backtrace(callstack, 128);
    //backtrace_symbols将从backtrace函数获取的信息转化为一个字符串数组
    //返回一个指向字符串数组的指针
    //每个字符串包含了一个相对于callstack中对应元素的可打印信息，包括函数名、偏移地址、实际返回地址
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = 0; i < frames; i++) {
        
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

//点击退出
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex {
#pragma clang diagnostic pop
    
    if (anIndex == 0) {
        
        self.dismissed = YES;
    } else {
//        NSSetUncaughtExceptionHandler(NULL);
//        self.dismissed = YES;
        self.isCountinue = YES;
    }
}

//处理报错信息
- (void)validateAndSaveCriticalApplicationData:(NSException *)exception {
    
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"\n--------Log Exception---------\nappInfo             :\n%@\n\nexception name      :%@\nexception reason    :%@\nexception userInfo  :%@\ncallStackSymbols    :%@\n\n--------End Log Exception-----", getAppInfo(),exception.name, exception.reason, exception.userInfo ? : @"no user info", [exception callStackSymbols]];
    
    NSLog(@"%@", exceptionInfo);
    //	[exceptionInfo writeToFile:[NSString stringWithFormat:@"%@/Documents/error.log",NSHomeDirectory()]  atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
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
    NSString *crashInfo = [NSString stringWithFormat:@"%@,%@,%@,%@,%@", getAppInfo(),exception.name, exception.reason, exception.userInfo ? : @"no user info", [exception callStackSymbols]];
    [self reportAppCrashInfo:crashInfo deviceInfo:parJson];

}

#pragma mark ----崩溃时候上报给后台
- (void)reportAppCrashInfo:(NSString *)crashInfo deviceInfo:(NSString *)deviceInfo {
    
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


- (void)handleException:(NSException *)exception {
    
    
    [self validateAndSaveCriticalApplicationData:exception];
    
    //崩溃前清缓存,防止因为缓存数据而导致重复崩溃
    [CacheFileManager clearCache:STL_PATH_CACHE];
    
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease]) {
        return;
    }
    if (!showAlertView) {
        return;
    }
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"\n--------Log Exception---------\nappInfo             :\n%@\n\nexception name      :%@\nexception reason    :%@\nexception userInfo  :%@\ncallStackSymbols    :%@\n\n--------End Log Exception-----", getAppInfo(),exception.name, exception.reason, exception.userInfo ? : @"no user info", [exception callStackSymbols]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:@"出错啦"
     message:[NSString stringWithFormat:@"你可以尝试继续操作，但是应用可能无法正常运行.\n %@",exceptionInfo]
     delegate:self
     cancelButtonTitle:@"退出"
     otherButtonTitles:@"继续", nil];
    [alert show];
#pragma clang diagnostic pop
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
//    if (self.dismissed) {
//        self.isCountinue = NO;
//    }
//    if (self.isCountinue) {
//        return;
//    }
    while (!self.dismissed) {
        
        //点击继续
        for (NSString *mode in (__bridge NSArray *)allModes) {
            //快速切换Mode
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
        
        STLLog(@"-----------------------------cccccccccccc");
    }
    
    //点击退出
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
        
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
        
    } else {
        
        [exception raise];
    }
}
@end



void HandleException(NSException *exception) {
    
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([[FBSDKCrashHandler class] respondsToSelector:@selector(_saveException:)]) {
            ///手动上传crash 到firebase
            [[FBSDKCrashHandler class] performSelector:@selector(_saveException:) withObject:exception];
        }
#pragma clang diagnostic pop

        
    }
    
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    // 如果太多不用处理
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    
    //获取调用堆栈
    NSArray *callStack = [exception callStackSymbols];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    //在主线程中，执行制定的方法, withObject是执行方法传入的参数
    [[[UncaughtExceptionUtil alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException exceptionWithName:[exception name]
                             reason:[exception reason]
                           userInfo:userInfo]
     waitUntilDone:YES];
    
    
 
}

//处理signal报错
void SignalHandler(int signal) {
    
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    // 如果太多不用处理
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    
    NSString* description = nil;
    switch (signal) {
        case SIGABRT:
            description = [NSString stringWithFormat:@"Signal SIGABRT was raised!\n"];
            break;
        case SIGILL:
            description = [NSString stringWithFormat:@"Signal SIGILL was raised!\n"];
            break;
        case SIGSEGV:
            description = [NSString stringWithFormat:@"Signal SIGSEGV was raised!\n"];
            break;
        case SIGFPE:
            description = [NSString stringWithFormat:@"Signal SIGFPE was raised!\n"];
            break;
        case SIGBUS:
            description = [NSString stringWithFormat:@"Signal SIGBUS was raised!\n"];
            break;
        case SIGPIPE:
            description = [NSString stringWithFormat:@"Signal SIGPIPE was raised!\n"];
            break;
        default:
            description = [NSString stringWithFormat:@"Signal %d was raised!",signal];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSArray *callStack = [UncaughtExceptionUtil backtrace];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    [userInfo setObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
    
    //在主线程中，执行指定的方法, withObject是执行方法传入的参数
    [[[UncaughtExceptionUtil alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                             reason: description
                           userInfo: userInfo]
     waitUntilDone:YES];
}

NSString* getAppInfo() {
    
    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@\nOS Version : %@ %@\n",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                         [UIDevice currentDevice].model,
                         [UIDevice currentDevice].systemName,
                         [UIDevice currentDevice].systemVersion];
    return appInfo;
}

