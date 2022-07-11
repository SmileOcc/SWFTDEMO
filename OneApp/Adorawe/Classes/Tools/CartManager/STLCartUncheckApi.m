//
//  STLCartClearApi.m
// XStarlinkProject
//
//  Created by odd on 2021/1/20.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLCartUncheckApi.h"

@implementation STLCartUncheckApi{
    NSArray *_cartsIds;
}

- (instancetype)initWithCartsIds:(NSArray *)cartsIds{
    if (self = [super init]) {
        _cartsIds = cartsIds;
    }
    return self;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_CartUncheck];
}

- (id)requestParameters {
    return @{
            @"userid"          : USERID_STRING,
             @"cart_ids" : _cartsIds ? _cartsIds : @[],
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
