//
//  OSSVTransporteSpliteAip.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/27.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVTransporteSpliteAip.h"

@implementation OSSVTransporteSpliteAip{
    NSString *_orderNumber;
}

- (instancetype)initWithOrderNumber:(NSString *)orderNumber {
    
    self = [super init];
    if (self) {
        _orderNumber = orderNumber;
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
    return [OSSVNSStringTool buildRequestPath:kApi_OrderOrderSplitList];
}

- (id)requestParameters {
    NSLog(@"userId == %@",[OSSVAccountsManager sharedManager].account.userid);
    return @{
             @"commparam"    : [OSSVNSStringTool buildCommparam],
             @"order_sn"     : STLToString(_orderNumber),
             };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
