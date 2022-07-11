//
//  ApiloginApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "ApiloginApi.h"

@implementation ApiloginApi {
    NSDictionary *_dict;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    
    self = [super init];
    if (self) {
        _dict = dict;
    }
    return self;
}

- (BOOL)isNewENC {
    if ([OSSVConfigDomainsManager domainEnvironment] == DomainType_DeveTrunk ||
        [OSSVConfigDomainsManager domainEnvironment] == DomainType_DeveInput) {
        return NO;
    }
    return YES;
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

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_UserApilogin];
}

- (id)requestParameters {
    NSString *source = [[NSUserDefaults standardUserDefaults] objectForKey:kSourceKey];
    
    
    NSMutableDictionary *params = [@{
             @"commparam"   : [OSSVNSStringTool buildCommparam],
             @"email"       : STLToString(_dict[@"email"]),
             @"type"        : STLToString(_dict[@"type"]),
             @"fb_id"       : STLToString(_dict[@"fb_id"]),
             @"ios_id"      : STLToString(_dict[@"ios_id"]),
             @"sex"         : STLToString(_dict[@"sex"]),
             @"avatar"      : STLToString(_dict[@"avatar"]),
             @"thirdtoken"  : STLToString(_dict[@"thirdtoken"]),
             @"nickname"    : STLToString(_dict[@"nickname"]),
             @"channel"     : STLToString(source),
             ////分享拉新
             @"share_source"    : @([OSSVAccountsManager stlShareChannelSource]),
             @"uid"         : STLToString([OSSVAccountsManager sharedManager].shareSourceUid),
             @"device_id"       : STLToString([OSSVAccountsManager sharedManager].device_id),

             } mutableCopy];
    
    NSString *shareUserId = [[NSUserDefaults standardUserDefaults] objectForKey:ONELINK_SHAREUSERID];
    if (![OSSVNSStringTool isEmptyString:shareUserId]) {
        NSInteger time = [[NSUserDefaults standardUserDefaults] integerForKey:SAVE_ONELINK_PARMATERS_TIME];
        NSString *shareTime = [NSString stringWithFormat:@"%li",(long)time];
        
        [params setObject:shareUserId forKey:@"invite_uid"];
        [params setObject:shareTime forKey:@"invite_timestamp"];
    }
    
    return [params copy];
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
