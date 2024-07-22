//
//  ZFCommunityFollowApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityFollowApi.h"
#import "ZFLocalizationString.h"
#import "Constants.h"

@interface ZFCommunityFollowApi () {
    NSInteger _followStatue;
    NSString *_followedUserId;
}
@end

@implementation ZFCommunityFollowApi
- (instancetype)initWithFollowStatue:(NSInteger)followStatue followedUserId:(NSString *)followedUserId
{
    if (self = [super init]) {
        _followedUserId = followedUserId ?: @"0";
        _followStatue = followStatue;
    }
    return self;
}

- (BOOL)enableCache {
    return YES;
}

- (BOOL)enableAccessory {
    return NO;
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


- (id)requestParameters {
    return @{
             @"type"           : @"2",
             @"app_type"       : @"2",
             @"site"           : @"ZZZZZcommunity",
             @"loginUserId"    : USERID,
             @"flag"           : @(_followStatue),  // 1关注 0取消关注
             @"followedUserId" : _followedUserId,
             @"lang"           : [ZFLocalizationString shareLocalizable].nomarLocalizable
             };
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
