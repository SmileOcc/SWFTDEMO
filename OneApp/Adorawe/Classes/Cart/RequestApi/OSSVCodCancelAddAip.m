//
//  OSSVCodCancelAddAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCodCancelAddAip.h"

@implementation OSSVCodCancelAddAip{
    NSDictionary *_dict;
}

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        _dict = dict;
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
    return [OSSVNSStringTool buildRequestPath:kApi_CodCancelCancelCodOrder];
}

- (id)requestParameters {
    return @{
             @"cancel_type": STLToString(_dict[@"cancel_type"]),
             @"address"    : STLToString(_dict[@"address"]),
             @"phone"      : STLToString(_dict[@"phone"]),
             @"receiver"   : STLToString(_dict[@"receiver"]),
             @"amount"     : _dict[@"amount"] ? _dict[@"amount"] : @(0),
             @"currency"   : STLToString(_dict[@"currency"]),
             @"api_currency" :STLToString(_dict[@"currency"]),
             @"order_id"   : STLToString(_dict[@"order_id"])
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
