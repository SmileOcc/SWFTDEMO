//
//  OSSVFeedsBacksReason.m
// XStarlinkProject
//
//  Created by Kevin on 2021/4/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVFeedsBacksReason.h"

@implementation OSSVFeedsBacksReason



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
    return [NSStringTool buildRequestPath:kApi_FeedbackReason];
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
