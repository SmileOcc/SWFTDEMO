//
//  OSSVMysCouponssListAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMysCouponssListAip.h"

@implementation OSSVMysCouponssListAip {
    NSString *_flag;
}

- (instancetype)initWithFlag:(NSString *)flag {
    if (self = [super init]) {
        _flag = flag;
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
    return [OSSVNSStringTool buildRequestPath:kApi_UserCoupon];
}

- (id)requestParameters {
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             @"flag" : _flag
             };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
