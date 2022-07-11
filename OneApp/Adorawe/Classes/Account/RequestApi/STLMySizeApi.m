//
//  OSSVMysSizesAip.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/9.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVMysSizesAip.h"

@implementation OSSVMysSizesAip

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
    return [NSStringTool buildRequestPath:kApi_GetSizeOption];
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
