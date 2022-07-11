//
//  OSSVOrderCreateAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVOrderCreateAip.h"

@implementation OSSVOrderCreateAip {
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
    return [OSSVNSStringTool buildRequestPath:kApi_OrderCreate];
}

- (id)requestParameters {
    NSString *source = [[NSUserDefaults standardUserDefaults] objectForKey:kSourceKey];
    
    NSString *adv_utm_source = [OSSVAdvsEventsManager adv_utm_source];
    NSString *adv_utm_medium = [OSSVAdvsEventsManager adv_utm_medium];
    NSString *adv_utm_campaign = [OSSVAdvsEventsManager adv_utm_campaign];
    NSInteger adv_utm_date = [[OSSVAdvsEventsManager adv_utm_date] integerValue];

    NSMutableDictionary *params = [@{
                                @"commparam" : [OSSVNSStringTool buildCommparam],
                                @"tax_id" : _dict[@"tax_id"],
                                @"select_goods" : _dict[@"select_goods"],
                                @"wid" : _dict[@"wid"],
//                                @"goods_number" : _dict[@"goods_number"],
//                                @"buy_now" : _dict[@"buy_now"],
                                @"address_id" : _dict[@"address_id"],
                                @"shipping_id" : _dict[@"shipping_id"],
//                                @"pay_id" : _dict[@"pay_id"],
                                @"currency" : _dict[@"currency"] ? _dict[@"currency"] : [ExchangeManager localTypeCurrency],
                                @"api_currency" :_dict[@"currency"] ? _dict[@"currency"] : [ExchangeManager localTypeCurrency],
                                @"invoice" : _dict[@"invoice"],
                                @"tracking" : _dict[@"tracking"],
                                @"is_shipping_insurance" : _dict[@"is_shipping_insurance"],
                                @"remark" : _dict[@"remark"],
                                @"coupon_code" :  [OSSVNSStringTool isEmptyString:_dict[@"coupon_code"]] ? @"" : _dict[@"coupon_code"],
                                @"use_point" : [OSSVNSStringTool isEmptyString:_dict[@"use_point"]] ? @"" : _dict[@"use_point"],
                                @"channel"   : [OSSVNSStringTool isEmptyString:source]? @"" : source,
                                @"media_source" : [OSSVNSStringTool getMediaSource],
                                @"campaign": [OSSVNSStringTool getPush_campaign],
                                @"link_id" : [OSSVNSStringTool getLkid],
                                @"pid" : [OSSVNSStringTool getPid],
                                @"c" : [OSSVNSStringTool getC],
                                @"is_retargeting" : [OSSVNSStringTool getIsRetargeting],
                                @"payToken" : STLToString(_dict[@"payToken"]),
                                @"isPaypalFast" : STLToString(_dict[@"isPaypalFast"]),
                                @"PayerID" : STLToString(_dict[@"PayerID"]),
                                @"source" : @"app",
                                @"code" : STLToString(_dict[@"code"]),
                                @"pay_code" : STLToString(_dict[@"pay_code"]),
                                @"push_id" : [OSSVNSStringTool getPush_id],
                                @"push_channel" : [OSSVNSStringTool getPush_Channel],
                                @"id_card"      : _dict[@"IdCard"],
                                @"pay_discount_id" : STLToString(_dict[@"pay_discount_id"]),  //创建订单新增以下两个入参
                                @"pay_discount" : STLToString(_dict[@"pay_discount"]),
                                @"is_use_coin"  : @"0",//STLToString(_dict[@"is_use_coin"]),
                                @"starlink_utm_source" : adv_utm_source,
                                @"starlink_utm_medium" : adv_utm_medium,
                                @"starlink_utm_campaign" : adv_utm_campaign,
                                @"starlink_utm_date" : @(adv_utm_date),
                                

                            } mutableCopy];
    NSString *shareUserId = [[NSUserDefaults standardUserDefaults] objectForKey:ONELINK_SHAREUSERID];
    if (![OSSVNSStringTool isEmptyString:shareUserId]) {
        NSInteger time = [[NSUserDefaults standardUserDefaults] integerForKey:SAVE_ONELINK_PARMATERS_TIME];
        NSString *shareTime = [NSString stringWithFormat:@"%li",(long)time];
        
        [params setObject:shareUserId forKey:@"invite_uid"];
        [params setObject:shareTime forKey:@"invite_timestamp"];
    }
    
    return [params copy];
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
