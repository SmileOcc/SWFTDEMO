//
//  OSSVOrdereRevieweWriteAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVOrdereRevieweWriteAip.h"

@implementation OSSVOrdereRevieweWriteAip
{
    NSDictionary *_dict;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        _dict = dict;
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
    return kApi_OrderWriteOrderReview;
}

-(NSString *)domainPath
{
    return masterDomain;
}

- (id)requestParameters {
    return @{
             @"order_id"            : STLToString(_dict[@"order_id"]),
             @"transport_rate"      : STLToString(_dict[@"transport_rate"]),
             @"goods_rate"          : STLToString(_dict[@"goods_rate"]),
             @"pay_rate"            : STLToString(_dict[@"pay_rate"]),
             @"service_rate"        : STLToString(_dict[@"service_rate"]),
             };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
