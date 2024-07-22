//
//  OrdersCancelApi.m
//  Yoshop
//
//  Created by YW on 16/6/16.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "OrdersCancelApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation OrdersCancelApi {
    NSString *_orderId;
}

- (instancetype)initWithOrderId:(NSString *)orderId {
    if (self = [super init]) {
        _orderId = orderId;
    }
    return self;
}

- (BOOL)enableCache {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return ENCPATH;
}

- (id)requestParameters {
    
    return @{
             @"action"      :   @"order/cancel",
             @"token"       :   TOKEN,
             @"order_id"    :   _orderId
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}

/// 请求的SerializerType
- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
