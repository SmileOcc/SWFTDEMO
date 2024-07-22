//
//  ZFZegoHelper.h
//  ZZZZZ
//
//  Created by YW on 2019/8/6.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZegoLiveRoom/ZegoLiveRoom.h>
#import "ZFZegoSettings.h"

#define kRtmpKey        @"rtmp"
#define kHlsKey         @"Hls"
#define kFirstAnchor    @"first"
#define kMixStreamID    @"mixStreamID"

typedef enum : NSUInteger {
    SinglePublisherRoom = 1,
    MultiPublisherRoom  = 2,
    MixStreamRoom       = 3,
    WerewolfRoom        = 4,
    WerewolfInTurnRoom  = 5,
} ZegoRoomType;


typedef enum : NSUInteger {
    ZegoAppTypeUDP      = 0,    // 国内版
    ZegoAppTypeI18N     = 1,    // 国际版
    //    ZegoAppTypeCustom   = 2,    // 自定义
} ZegoAppType;

extern NSString *ZegoLiveRoomApiInitCompleteNotification;

NS_ASSUME_NONNULL_BEGIN

@interface ZFZegoHelper : NSObject


+ (void)clearUserInfo;

+ (ZegoLiveRoomApi *)api;
+ (void)releaseApi;
+ (NSData *)zegoAppSignFromServer;

+ (void)setCustomAppID:(uint32_t)appid sign:(NSString *)sign;
+ (uint32_t)appID;

+ (void)setUsingTestEnv:(bool)testEnv;
+ (bool)usingTestEnv;

+ (bool)usingAlphaEnv;

+ (void)setUsingExternalCapture:(bool)bUse;
+ (bool)usingExternalCapture;

+ (void)setUsingExternalRender:(bool)bUse;
+ (bool)usingExternalRender;

+ (void)setUsingExternalFilter:(bool)bUse;
+ (bool)usingExternalFilter;

+ (void)setEnableRateControl:(bool)bEnable;
+ (bool)rateControlEnabled;

+ (void)setUsingHardwareEncode:(bool)bUse;
+ (bool)usingHardwareEncode;

+ (void)setUsingHardwareDecode:(bool)bUse;
+ (bool)usingHardwareDecode;

+ (void)setEnableReverb:(bool)bEnable;
+ (bool)reverbEnabled;

+ (void)setRecordTime:(bool)record;
+ (bool)recordTime;

+ (BOOL)useHeadSet;
+ (void)checkHeadSet;

+ (void)setUsingInternationDomain:(bool)bUse;
+ (bool)usingInternationDomain;

+ (void)setAppType:(ZegoAppType)type;
+ (ZegoAppType)appType;

+ (NSString *)customAppSign;

+ (void)setBizTypeForCustomAppID:(int)bizType;

//TODO: occ 暂无
#if TARGET_OS_SIMULATOR
//+ (ZegoVideoCaptureFactory *)getVideoCaptureFactory;
#else
//+ (VideoCaptureFactoryDemo *)getVideoCaptureFactory;
#endif

+ (void)enableExternalVideoCapture:(id<ZegoVideoCaptureFactory>)factory videoRenderer:(id<ZegoLiveApiRenderDelegate>)renderer;

#pragma mark - Biz Helper

+ (NSString *)getMyRoomID:(ZegoRoomType)roomType;
+ (NSString *)getPublishStreamID;
@end


@interface ZFZegoHelper (Alpha)
+ (void)setUsingAlphaEnv:(bool)alphaEnv;
@end

NS_ASSUME_NONNULL_END
