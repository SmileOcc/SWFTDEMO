//
//  OSSVOrdersStatusAip.m
// XStarlinkProject
//
//  Created by odd on 2020/8/11.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVOrdersStatusAip.h"

@implementation OSSVOrdersStatusAip


- (BOOL)isNewENC {
    if ([OSSVConfigDomainsManager domainEnvironment] == DomainType_DeveTrunk ||
        [OSSVConfigDomainsManager domainEnvironment] == DomainType_DeveInput) {
        return NO;
    }
    return YES;
}

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
    return [OSSVNSStringTool buildRequestPath:@"order/status"];
}

- (id)requestParameters {
    return @{
             @"commparam" : [OSSVNSStringTool buildCommparam],
             };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
