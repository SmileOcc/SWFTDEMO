//
//  STLOrderWarnApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/10/29.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVOrdesrWarnsAip.h"

@implementation OSSVOrdesrWarnsAip

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
    return [OSSVNSStringTool buildRequestPath:@"site/order-warn"];
}

- (id)requestParameters {
    return @{
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
