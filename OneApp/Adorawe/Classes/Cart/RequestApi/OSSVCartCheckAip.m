//
//  OSSVCartCheckAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartCheckAip.h"
#import "RateModel.h"

@implementation OSSVCartCheckAip {
    NSDictionary *_dict;
}

- (instancetype)initWithDict:(NSDictionary *)dict{
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
    return [OSSVNSStringTool buildRequestPath:kApi_OrderCheck];
}


- (id)requestParameters {
    
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             @"wid" :  STLToString(_dict[@"wid"]),
             @"address_id" : STLToString(_dict[@"address_id"]),
             @"coupon_code" : STLToString(_dict[@"coupon_code"]),
             @"use_point" : STLToString(_dict[@"use_point"]),
             @"payToken" : STLToString(_dict[@"payToken"]),
             @"isPaypalFast" : STLToString(_dict[@"isPaypalFast"]),
             @"pay_code"     : STLToString(_dict[@"pay_code"]),           //选择支付方式时候，新增该参数
             @"is_use_coin"  : @"0",//STLToString(_dict[@"is_use_coin"]),   //是否使用金币
             @"is_shipping_insurance" : STLToString(_dict[@"is_shipping_insurance"]), //运费险
             @"shipping_id" : STLToString(_dict[@"shipping_id"]), //运送方式
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
