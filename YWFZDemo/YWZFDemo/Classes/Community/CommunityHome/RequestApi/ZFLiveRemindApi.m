//
//  ZFLiveRemindApi.m
//  ZZZZZ
//
//  Created by YW on 2019/12/23.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFLiveRemindApi.h"
#import "Constants.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"

@interface ZFLiveRemindApi () {
    NSString *_liveID;
}

@end

@implementation ZFLiveRemindApi

- (instancetype)initWithLiveID:(NSString *)liveID {
    if (self = [super init]) {
        _liveID = liveID;
    }
    return self;
}

- (BOOL)enableCache {
    return YES;
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
             @"loginUserId"    : USERID ?: @"0",
             @"app_type"       : @"2",
             @"liveid"         : ZFToString(_liveID),
             @"version"        : ZFToString(ZFSYSTEM_VERSION),
             @"token"          : ZFToString(TOKEN),
             @"lang"           : [ZFLocalizationString shareLocalizable].nomarLocalizable,
             @"device"         : ZFToString([AccountManager sharedManager].device_id),
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

- (NSString *)baseURL {
    return [self communityLiveURLAppendPublicArgument:Community_Live_API(@"api/live/subscribe")];
}

@end
