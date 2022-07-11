//
//  OSSVFeedbacksReplayListAip.m
// XStarlinkProject
//
//  Created by odd on 2021/4/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVFeedbacksReplayListAip.h"

@implementation OSSVFeedbacksReplayListAip

- (BOOL)isNewENC {
    if ([STLConfigureDomainManager domainEnvironment] == DomainType_DeveTrunk ||
        [STLConfigureDomainManager domainEnvironment] == DomainType_DeveInput) {
        return NO;
    }
    return NO;
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
    return [NSStringTool buildRequestPath:kApi_FeedbackReplyList];
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
