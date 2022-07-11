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
    if ([STLConfigureDomainManager domainEnvironment] == DomainType_DeveTrunk ||
        [STLConfigureDomainManager domainEnvironment] == DomainType_DeveInput) {
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
    return [NSStringTool buildRequestPath:@"order/status"];
}

- (id)requestParameters {
    return @{
             @"commparam" : [NSStringTool buildCommparam],
             };
}

- (STLRequestMethod)requestMethod {
    
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
