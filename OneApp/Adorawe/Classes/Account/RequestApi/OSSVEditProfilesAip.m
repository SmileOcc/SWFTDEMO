//
//  OSSVEditProfilesAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVEditProfilesAip.h"

@implementation OSSVEditProfilesAip {
    
    NSString *_sex;
    NSString *_nickName;
    NSString *_birthday;
    NSString *_avatar;
}

- (instancetype)initWithNickName:(NSString *)nickName sex:(NSString *)sex birthday:(NSString *)birthday avatar:(NSString *)avatar {
    
    self = [super init];
    if (self) {
        _nickName = nickName;
        _sex = sex;
        _birthday = birthday;
        _avatar = avatar;
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
    //user/editprofile
    return [OSSVNSStringTool buildRequestPath:kApi_UserEditprofile];
}

- (id)requestParameters {
    return @{
             @"commparam"        : [OSSVNSStringTool buildCommparam],
             @"nick_name"        : STLToString(_nickName),
             @"sex"              : STLToString(_sex),
             @"birthday"         : STLToString(_birthday),
             @"avatar"           : STLToString(_avatar),

             };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
