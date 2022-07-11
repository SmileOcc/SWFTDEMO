//
//  OSSVSMSVerifysAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSMSVerifysAip.h"

@implementation OSSVSMSVerifysAip {
    NSString *_orderId;
}

- (instancetype)initWithOrderID:(NSString *)orderId {
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
    return [OSSVNSStringTool buildRequestPath:kApi_SmsSendSmsCode];
}

- (id)requestParameters {
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             @"order_id" : STLToString(_orderId)
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}

- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
