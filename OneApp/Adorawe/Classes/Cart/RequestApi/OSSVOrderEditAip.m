//
//  OSSVOrderEditAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import "OSSVOrderEditAip.h"

@implementation OSSVOrderEditAip {
    NSString *_orderSn;
}

- (instancetype)initWithOrderSn:(NSString *)orderSn {
    if (self = [super init]) {
        _orderSn = orderSn;
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
    return [OSSVNSStringTool buildRequestPath:@"order/edit"];
}

- (id)requestParameters {
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             @"order_sn" : _orderSn,
             @"pid" : [OSSVNSStringTool getPid],
             @"campaign": [OSSVNSStringTool getPush_campaign],
             @"c" : [OSSVNSStringTool getC],
             @"push_id" : [OSSVNSStringTool getPush_id],
             @"push_channel" : [OSSVNSStringTool getPush_Channel],
             @"is_retargeting" : [OSSVNSStringTool getIsRetargeting]
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
