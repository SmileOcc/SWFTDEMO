//
//  LoginApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "LoginApi.h"

@implementation LoginApi {
    NSString *_email;
    NSString *_password;
}

- (instancetype)initWithEmail:(NSString *)email password:(NSString *)password {
    
    self = [super init];
    if (self) {
        _email = email;
        _password = password;
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
    return [OSSVNSStringTool buildRequestPath:kApi_UserLogin];
}

- (id)requestParameters {
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             @"email"     :_email,
             @"password"  :_password
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}

- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
