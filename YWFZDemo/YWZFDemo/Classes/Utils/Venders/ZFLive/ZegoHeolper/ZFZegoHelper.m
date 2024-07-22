//
//  ZFZegoHelper.m
//  ZZZZZ
//
//  Created by YW on 2019/8/6.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFZegoHelper.h"
#import "Constants.h"
#import "YWLocalHostManager.h"

NSString *kZegoAppTypeKey           = @"apptype";
NSString *kZegoAppIDKey             = @"appid";
NSString *kZegoAppSignKey           = @"appsign";
NSString *kZegoAppBizType           = @"biztype";
NSString *kZegoAppUseI18nDomain     = @"i18n-domain";
NSString *kZegoAppEnvKey            = @"envtype";

NSString *ZegoLiveRoomApiInitCompleteNotification = @"ZegoLiveRoomApiInitCompleteNotification";

static ZegoLiveRoomApi *g_ZegoApi = nil;

//NSData *g_signKey = nil;
//uint32_t g_appID = 0;

BOOL g_useTestEnv = NO;
BOOL g_useAlphaEnv = NO;

// Demo 默认版本为 UDP
ZegoAppType g_appType = ZegoAppTypeUDP;

#if TARGET_OS_SIMULATOR
BOOL g_useHardwareEncode = NO;
BOOL g_useHardwareDecode = NO;
#else
BOOL g_useHardwareEncode = YES;
BOOL g_useHardwareDecode = YES;
#endif

BOOL g_enableVideoRateControl = NO;

BOOL g_useExternalCaptrue = NO;
BOOL g_useExternalRender = NO;

BOOL g_enableReverb = NO;

BOOL g_recordTime = NO;
BOOL g_useInternationDomain = NO;
BOOL g_useExternalFilter = NO;

BOOL g_useHeadSet = NO;

static Byte toByte(NSString* c);
static NSData* ConvertStringToSign(NSString* strSign);

//static __strong id<ZegoVideoCaptureFactory> g_factory = nullptr;
//static __strong id<ZegoVideoFilterFactory> g_filterFactory = nullptr;

@implementation ZFZegoHelper


+ (void)clearUserInfo {
    [ZFZegoSettings sharedInstance].userID = @"";
    [ZFZegoSettings sharedInstance].userName = @"";
    NSString *userID = [ZFZegoSettings sharedInstance].userID;
    NSString *userName = [ZFZegoSettings sharedInstance].userName;
    [ZegoLiveRoomApi setUserID:userID userName:userName];
}

+ (ZegoLiveRoomApi *)api
{
    if (g_ZegoApi == nil) {
        
        if (g_appType == ZegoAppTypeI18N) {
            g_useInternationDomain = YES;
        } else {
            g_useInternationDomain = NO;
        }
        
        //发布版本 或 预发布都用线上
        if ([YWLocalHostManager isDistributionOnlineRelease] || [YWLocalHostManager isPreRelease]) {
            [self setUsingTestEnv:NO];
        } else {
            [self setUsingTestEnv:YES];
        }
        
        [ZegoLiveRoomApi setUseTestEnv:[self usingTestEnv]];
//        [ZegoLiveRoomApi enableExternalRender:[self usingExternalRender]];
        
#ifdef DEBUG
        [ZegoLiveRoomApi setVerbose:YES];
#endif
        
        [self setupVideoCaptureDevice];
        [self setupVideoFilter];
        
        NSString *userID = [ZFZegoSettings sharedInstance].userID;
        NSString *userName = [ZFZegoSettings sharedInstance].userName;
        [ZegoLiveRoomApi setUserID:userID userName:userName];
        
        uint32_t appID = [self appID];
        if (appID > 0) {    // 手动输入为空的情况下容错
            NSData *appSign = [self zegoAppSignFromServer];
            if (appSign) {
                g_ZegoApi = [[ZegoLiveRoomApi alloc] initWithAppID:appID appSignature:appSign completionBlock:^(int errorCode) {
                    YWLog(@"init SDK result:%d", errorCode);//21300403、20000001 报这个错问题 类似网络异常
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NSNotificationCenter.defaultCenter postNotificationName:ZegoLiveRoomApiInitCompleteNotification object:@(errorCode)];
                    });
                }];
            }
        }

        [ZegoLiveRoomApi requireHardwareDecoder:g_useHardwareDecode];
        [ZegoLiveRoomApi requireHardwareEncoder:g_useHardwareEncode];
        
        if (g_appType == ZegoAppTypeUDP || g_appType == ZegoAppTypeI18N) {
            [g_ZegoApi enableTrafficControl:YES properties:ZEGOAPI_TRAFFIC_FPS | ZEGOAPI_TRAFFIC_RESOLUTION];
        }
        
    }
    
    return g_ZegoApi;
}

+ (void)checkHeadSet
{
#if TARGET_IPHONE_SIMULATOR
    g_useHeadSet = NO;
#else
    AVAudioSessionRouteDescription *route = [AVAudioSession sharedInstance].currentRoute;
    for (AVAudioSessionPortDescription *desc in route.outputs)
        {
        if ([desc.portType isEqualToString:AVAudioSessionPortHeadphones] ||
            [desc.portType isEqualToString:AVAudioSessionPortBluetoothA2DP] ||
            [desc.portType isEqualToString:AVAudioSessionPortBluetoothHFP])
            {
            g_useHeadSet = YES;
            return;
            }
        }
    
    g_useHeadSet = NO;
#endif
}

+ (void)releaseApi
{
    g_ZegoApi = nil;
}

#pragma mark - private

+ (void)setupVideoCaptureDevice
{
    
#if TARGET_OS_SIMULATOR
    g_useExternalCaptrue = YES;
    
//    if (g_factory == nullptr) {
//        g_factory = [[ZegoVideoCaptureFactory alloc] init];
//        [ZegoLiveRoomApi setVideoCaptureFactory:g_factory];
//    }
#else
    
    // try VideoCaptureFactoryDemo for camera
    //     static __strong id<ZegoVideoCaptureFactory> g_factory = nullptr;
    
    /*
     g_useExternalCaptrue = YES;
     
     if (g_factory == nullptr)
     {
     g_factory = [[VideoCaptureFactoryDemo alloc] init];
     [ZegoLiveRoomApi setVideoCaptureFactory:g_factory];
     }
     */
#endif
}

+ (void)setupVideoFilter
{
//    if (!g_useExternalFilter)
//        return;
//
//    if (g_filterFactory == nullptr)
//        g_filterFactory = [[ZegoVideoFilterFactoryDemo alloc] init];
//
//    [ZegoLiveRoomApi setVideoFilterFactory:g_filterFactory];
}


+ (uint32_t)appID {
    
    if ([YWLocalHostManager isDistributionOnlineRelease] || [YWLocalHostManager isPreRelease]) {
        
        switch ([self appType]) {
            case ZegoAppTypeUDP:
                return 197128466;  // UDP版
                break;
            case ZegoAppTypeI18N:
                return 197128466;  // 国际版
                break;
        }
    } else {
        switch ([self appType]) {
            case ZegoAppTypeUDP:
                return 2075067312;  // UDP版
                break;
            case ZegoAppTypeI18N:
                return 2075067312;  // 国际版
                break;
        }
    }
}

+ (NSData *)zegoAppSignFromServer {
    //!! Demo 暂时把 signKey 硬编码到代码中，该用法不规范
    //!! 规范用法：signKey 需要从 server 下发到 App，避免在 App 中存储，防止盗用
    
    ZegoAppType type = [self appType];
    
    if (type == ZegoAppTypeUDP) {
        if ([YWLocalHostManager isDistributionOnlineRelease] || [YWLocalHostManager isPreRelease]) {
             Byte signkey[] = {0xf8,0x93,0xf5,0x9c,0x13,0x57,0x01,0x73,0xd6,0x35,0x6c,0x74,0x10,0x0d,0xa4,0x36,0xdb,0x0c,0xdf,0xd3,0x0c,0xf7,0xf5,0x99,0x55,0x33,0x4c,0x11,0xc3,0x3b,0xd2,0xab};
            return [NSData dataWithBytes:signkey length:32];
        }
        
        Byte signkey[] = {0x3f,0xd6,0xf0,0x3b,0x1a,0xf0,0x87,0x82,0x7d,0x95,0x1e,0xb9,0x92,0xd5,0x25,0xaa,0x5b,0x7e,0x5f,0xdb,0x33,0x80,0xd3,0x8e,0xbb,0xd4,0xde,0x69,0x3f,0x93,0x1b,0xb7};
        return [NSData dataWithBytes:signkey length:32];
        
    } else {
        if ([YWLocalHostManager isDistributionOnlineRelease] || [YWLocalHostManager isPreRelease]) {
            Byte signkey[] = {0xf8,0x93,0xf5,0x9c,0x13,0x57,0x01,0x73,0xd6,0x35,0x6c,0x74,0x10,0x0d,0xa4,0x36,0xdb,0x0c,0xdf,0xd3,0x0c,0xf7,0xf5,0x99,0x55,0x33,0x4c,0x11,0xc3,0x3b,0xd2,0xab};
            return [NSData dataWithBytes:signkey length:32];
        }
        Byte signkey[] = {0x3f,0xd6,0xf0,0x3b,0x1a,0xf0,0x87,0x82,0x7d,0x95,0x1e,0xb9,0x92,0xd5,0x25,0xaa,0x5b,0x7e,0x5f,0xdb,0x33,0x80,0xd3,0x8e,0xbb,0xd4,0xde,0x69,0x3f,0x93,0x1b,0xb7};
        return [NSData dataWithBytes:signkey length:32];
    }
}


+ (void)setAppType:(ZegoAppType)type {
    if (g_appType == type)
        return;
    
    // 本地持久化
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:type forKey:kZegoAppTypeKey];
    
    g_appType = type;
    
    [self releaseApi];
    
    // 临时兼容 SDK 的 Bug，立即初始化 api 对象
    if ([self api] == nil) {
        [self api];
    }
}

+ (ZegoAppType)appType {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSUInteger type = [ud integerForKey:kZegoAppTypeKey];
    g_appType = (ZegoAppType)type;
    return (ZegoAppType)type;
}

+ (void)setUsingTestEnv:(bool)testEnv
{
    if (g_useTestEnv != testEnv)
        {
        [self releaseApi];
        }
    
    g_useTestEnv = testEnv;
    [ZegoLiveRoomApi setUseTestEnv:testEnv];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@(testEnv) forKey:kZegoAppEnvKey];
}

+ (bool)usingTestEnv
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    id useTestEnv = [ud objectForKey:kZegoAppEnvKey];
    return useTestEnv ? [useTestEnv boolValue]:g_useTestEnv;
}


+ (bool)usingExternalCapture
{
    return g_useExternalCaptrue;
}

+ (void)setUsingExternalRender:(bool)bUse
{
    if (g_useExternalRender != bUse)
        {
        [self releaseApi];
        }
    
    g_useExternalRender = bUse;
//    [ZegoLiveRoomApi enableExternalRender:bUse];
}

+ (bool)usingExternalRender
{
    return g_useExternalRender;
}



#pragma mark - 视频

+ (void)enableExternalVideoCapture:(id<ZegoVideoCaptureFactory>)factory videoRenderer:(id<ZegoLiveApiRenderDelegate>)renderer {
    if (g_ZegoApi) {
        [self releaseApi];
    }
    
    [ZegoExternalVideoCapture setVideoCaptureFactory:factory channelIndex:ZEGOAPI_CHN_MAIN];
    
    //TODO: occ测试数据  直播
//    if (renderer) {
//        [ZegoLiveRoomApi enableExternalRender:YES];
//        [[self api] setRenderDelegate:renderer];
//    } else {
//        [ZegoLiveRoomApi enableExternalRender:NO];
//    }
}
@end
