//
//  OSSVCartCouponSelectAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartCouponSelectAip.h"

@implementation OSSVCartCouponSelectAip {
    id _goodsList;
}

- (instancetype)initWithGoodsList:(id)goodsList {
    if (self = [super init]) {
        _goodsList = goodsList;
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
    return [OSSVNSStringTool buildRequestPath:kApi_CouponSelect];
}

- (id)requestParameters {
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             @"goods_list" : _goodsList
             };
}

//{"commparam":"ver=1.6.0&pf=android","user_id":"1444","goods_list":[{"goods_id":1,"wid":"1","goods_number":2}]}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
