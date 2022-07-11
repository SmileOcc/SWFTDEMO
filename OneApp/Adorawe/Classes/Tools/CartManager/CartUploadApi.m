//
//  CartUploadApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "CartUploadApi.h"

@implementation CartUploadApi {
    id _goodsList;
}

- (instancetype)initWithGoodsList:(id)goodsList{
    if (self = [super init]) {
        _goodsList = goodsList;
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
    return [OSSVNSStringTool buildRequestPath:kApi_CartUpload];
}

- (id)requestParameters {
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             @"goods_list" : _goodsList ? _goodsList : @[],
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
