//
//  OSSVAccountsMysWishListsAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccountsMysWishListsAip.h"

@implementation OSSVAccountsMysWishListsAip

- (BOOL)isNewENC {
    if ([STLConfigureDomainManager domainEnvironment] == DomainType_DeveTrunk ||
        [STLConfigureDomainManager domainEnvironment] == DomainType_DeveInput) {
        return NO;
    }
    return YES;
}

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
    return [NSStringTool buildRequestPath:kApi_CollectList];
}

- (id)requestParameters {
    return @{
             @"commparam" : [NSStringTool buildCommparam]
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}

/// 请求的SerializerType
- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
