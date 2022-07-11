//
//  OSSVAccountePayeMyOrdersAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccountePayeMyOrdersAip.h"

@implementation OSSVAccountePayeMyOrdersAip {
    NSString *_orderId;
}

- (instancetype)initWithOrderId:(NSString *)orderId {
    if (self = [super init]) {
        _orderId = orderId;
    }
    return self;
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
    return [OSSVNSStringTool buildRequestPath:kApi_PaySubmit];
}

- (id)requestParameters {
    return @{
             @"order_id" : _orderId,
             @"commparam" : [OSSVNSStringTool buildCommparam]
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}

/// 请求的SerializerType
- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
