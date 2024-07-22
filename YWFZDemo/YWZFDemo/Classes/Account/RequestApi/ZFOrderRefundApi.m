
//
//  ZFOrderRefundApi.m
//  ZZZZZ
//
//  Created by YW on 2018/4/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderRefundApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation ZFOrderRefundApi {
    NSString *_orderSn;
}

- (instancetype)initWithOrderSn:(NSString *)orderSn {
    self = [super init];
    if (self) {
        _orderSn = orderSn;
    }
    return self;
}

-(BOOL)encryption {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return ENCPATH;
}

- (id)requestParameters {
    return @{
             @"action"      :  @"order/request_refund",
             @"order_sn"    :  NullFilter(_orderSn),
             @"token"       :  TOKEN,
             @"is_enc"      :  @"0",
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end
