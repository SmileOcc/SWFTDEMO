//
//  OSSVOrdereAddresseInfoAip.m
// XStarlinkProject
//
//  Created by odd on 2020/9/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVOrdereAddresseInfoAip.h"

@implementation OSSVOrdereAddresseInfoAip

{
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
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_OrderGetOrderAddressinfo];
}

- (id)requestParameters {
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             @"order_id" : STLToString(_orderId),
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
