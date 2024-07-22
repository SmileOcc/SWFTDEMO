//
//  HelpApi.m
//  ZZZZZ
//
//  Created by YW on 18/9/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "HelpApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation HelpApi

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
    return ENCPATH;
}

- (id)requestParameters {
    return @{
             @"action"  :   @"article/index"
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
