//
//  OSSVAccounteCanceleMyOrdersAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteCanceleMyOrdersAip.h"

@implementation OSSVAccounteCanceleMyOrdersAip {
    NSString *_orderId;
}

- (instancetype)initWithOrderId:(NSString *)orderId {
    if (self = [super init]) {
        _orderId = orderId;
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
    return [OSSVNSStringTool buildRequestPath:kApi_OrderCancel];
}

- (id)requestParameters {
    return @{
             @"order_id" : _orderId,
             @"commparam" : [OSSVNSStringTool buildCommparam]
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
