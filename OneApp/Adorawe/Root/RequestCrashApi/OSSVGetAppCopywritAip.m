//
//  OSSVGetAppCopywritAip.m
// XStarlinkProject
//
//  Created by Kevin on 2021/5/7.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVGetAppCopywritAip.h"

@implementation OSSVGetAppCopywritAip

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
    return [OSSVNSStringTool buildRequestPath:kApi_GetAPPCopywriting];
}

- (id)requestParameters {
    return @{};
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
