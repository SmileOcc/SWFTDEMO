//
//  ExchangeApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "ExchangeApi.h"

@implementation ExchangeApi

- (BOOL)enableCache {
    return NO;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_ExchangeIndex];
}

- (id)requestParameters {
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam]
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
