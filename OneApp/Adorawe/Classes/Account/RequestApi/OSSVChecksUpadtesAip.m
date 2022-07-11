//
//  OSSVChecksUpadtesAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/15.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVChecksUpadtesAip.h"

@implementation OSSVChecksUpadtesAip

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
    return [OSSVNSStringTool buildRequestPath:kApi_SystemUpdate];
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
