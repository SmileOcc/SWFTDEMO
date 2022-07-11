//
//  OSSVChangesPasswordsAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVChangesPasswordsAip.h"


@implementation OSSVChangesPasswordsAip {
    
    NSString *_nowPassword;
    NSString *_oldPassword;
}

- (instancetype)initWithChangeNewPassword:(NSString *)nowPassword oldPassword:(NSString *)oldPassword {
    
    self = [super init];
    if (self) {
        _nowPassword = nowPassword;
        _oldPassword = oldPassword;
    }
    return self;
}

- (BOOL)isNewENC {
    if ([STLConfigureDomainManager domainEnvironment] == DomainType_DeveTrunk ||
        [STLConfigureDomainManager domainEnvironment] == DomainType_DeveInput) {
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
    // user/change-password
    return [NSStringTool buildRequestPath:kApi_UserChangepassword];
}

- (id)requestParameters {
    return @{
             @"commparam" : [NSStringTool buildCommparam],
             @"new_password"     : _nowPassword,
             @"old_password"     : _oldPassword,
             };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}


@end
