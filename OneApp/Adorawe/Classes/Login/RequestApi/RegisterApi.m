//
//  RegisterApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "RegisterApi.h"

@implementation RegisterApi {
    NSString *_email;
    NSString *_password;
    NSString *_sex;
}

- (instancetype)initWithEmail:(NSString *)email
                     password:(NSString *)password
                          sex:(NSString *)sex {
    
    self = [super init];
    if (self) {
        _email = email;
        _password = password;
        _sex = sex;
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
    return [OSSVNSStringTool buildRequestPath:kApi_UserSignup];
}

- (id)requestParameters {
    NSString *source = [[NSUserDefaults standardUserDefaults] objectForKey:kSourceKey];
    NSMutableDictionary *params = [@{
             @"email"     : _email,
             @"password"  : _password,
             @"sex"       : @"1",
             @"channel"   : [OSSVNSStringTool isEmptyString:source]? @"" : source,
             @"share_source"    : @([OSSVAccountsManager stlShareChannelSource]),
             @"uid"         : STLToString([OSSVAccountsManager sharedManager].shareSourceUid),
             @"device_id"       : STLToString([OSSVAccountsManager sharedManager].device_id),
             @"subscribe" : STLToString(_subscribe),
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
