//
//  STLCheckPushApi.m
// XStarlinkProject
//
//  Created by odd on 2020/12/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVChecksPushsAip.h"

@implementation OSSVChecksPushsAip

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_SystemInit];
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
