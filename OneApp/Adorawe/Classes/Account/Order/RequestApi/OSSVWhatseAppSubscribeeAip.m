//
//  OSSVWhatseAppSubscribeeAip.m
// XStarlinkProject
//
//  Created by Kevin on 2021/9/9.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVWhatseAppSubscribeeAip.h"

@implementation OSSVWhatseAppSubscribeeAip {
    NSString *_status;
    NSString *_phoneHead;
    NSString *_phone;
    
}

- (instancetype)initWithStatus:(NSString *)status phoneHead:(NSString *)phoneHead phone:(NSString *)phone {
    if (self = [super init]) {
        _status    = status;
        _phoneHead = phoneHead;
        _phone     = phone;
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
    return [OSSVNSStringTool buildRequestPath:kApi_WhatsAppSubscribe];
}

- (id)requestParameters {
    return @{
             @"status"     : STLToString(_status),
             @"phone_head" : STLToString(_phoneHead),
             @"phone"      : STLToString(_phone)
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}

/// 请求的SerializerType
- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
