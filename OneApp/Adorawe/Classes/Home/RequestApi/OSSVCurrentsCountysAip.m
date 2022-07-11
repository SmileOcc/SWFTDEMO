//
//  STLCurrentCountryApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/10/29.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCurrentsCountysAip.h"

@implementation OSSVCurrentsCountysAip

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
    return [OSSVNSStringTool buildRequestPath:@"country/current-country"];
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
