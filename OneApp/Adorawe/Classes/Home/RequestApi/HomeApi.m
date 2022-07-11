//
//  HomeApi.m
//  Yoshop
//
//  Created by zhaowei on 16/5/30.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "HomeApi.h"

@implementation HomeApi
- (BOOL)enableCache {
    return YES;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return @"/api/random/data/Android/20";
}

- (id)requestArgument {
    return @{
             @"commparam" : [NSString stringWithFormat:@"ver=%@&pf=ios",kAppVersion]
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
