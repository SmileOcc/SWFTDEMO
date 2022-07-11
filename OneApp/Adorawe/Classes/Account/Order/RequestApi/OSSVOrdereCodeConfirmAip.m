//
//  OSSVOrdereCodeConfirmAip.m
// XStarlinkProject
//
//  Created by odd on 2020/9/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVOrdereCodeConfirmAip.h"

@implementation OSSVOrdereCodeConfirmAip
{
    NSString *_orderId;
    NSString *_code;
    NSString *_addressId;

}

- (instancetype)initWithOrderId:(NSString *)orderId code:(NSString *)code addressId:(NSString *)addressId {
    if (self = [super init]) {
        _orderId = orderId;
        _code = code;
        _addressId = addressId;
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
    return [OSSVNSStringTool buildRequestPath:kApi_OrderCodSmsConfirm];
}

- (id)requestParameters {
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             @"order_id" : STLToString(_orderId),
             @"code" : STLToString(_code),
             @"address_id" : STLToString(_addressId),

             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
