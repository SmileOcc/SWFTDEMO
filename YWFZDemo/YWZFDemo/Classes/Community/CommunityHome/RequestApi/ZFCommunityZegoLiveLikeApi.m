//
//  ZFCommunityZegoLiveLikeApi.m
//  ZZZZZ
//
//  Created by YW on 2019/8/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityZegoLiveLikeApi.h"
#import "Constants.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"

@interface ZFCommunityZegoLiveLikeApi () {
    NSString *_liveID;
    NSString *_isLive;
    NSString *_nickname;
    NSString *_phase;
}

@end

@implementation ZFCommunityZegoLiveLikeApi

//0: 直播外（包含直播前、录播）
//1: 直播中（使用的接口： 2，5）
- (instancetype)initWithLiveID:(NSString *)liveID isLive:(NSString *)isLive nickname:(NSString *)nickname phase:(NSString *)phase{
    self = [super init];
    if (self) {
        _liveID = liveID;
        _isLive = isLive;
        _nickname = nickname;
        _phase = phase;

    }
    return self;
}

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

-(BOOL)encryption {
    return YES;
}

-(BOOL)isCommunityRequest{
    return YES;
}

- (BOOL)isCommunityLiveRequest {
    return YES;
}


- (id)requestParameters {
    
    return @{
             @"site"           : @"ZZZZZ" ,
//             @"type"           : @"9",
//             @"directory"      : @"82",
             @"loginUserId"    : USERID ?: @"0",
             @"app_type"       : @"2",
             @"nickname"       : ZFToString(_nickname),
             @"phase"          : ZFToString(_phase),
             @"id"             : ZFToString(_liveID),
             @"version"        : ZFToString(ZFSYSTEM_VERSION),
             @"token"          : ZFToString(TOKEN),
             @"lang"           : [ZFLocalizationString shareLocalizable].nomarLocalizable,
             @"device"         : ZFToString([AccountManager sharedManager].device_id),
             @"zego"           : ZFToString(_isLive),
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

- (NSString *)baseURL {
    return [self communityLiveURLAppendPublicArgument:Community_Live_API(@"api/live/video-like")];
}

@end
