//
//  BoletoApi.m
//  ZZZZZ
//
//  Created by YW on 4/11/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BoletoApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation BoletoApi
{
    NSString *_orderid;
}

-(instancetype)initWithOrderID:(NSString *)orderid {
    if (self = [super init]) {
        _orderid = orderid;
    }
    return self;
}

-(BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return ENCPATH;
}

-(BOOL)encryption {
    return NO;
}

- (id)requestParameters {
    return @{
             @"action"  : @"order/get_boleto_url",
             @"token"   : TOKEN,
             @"order_id" : _orderid,
             @"is_enc"  :  @"0"
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
