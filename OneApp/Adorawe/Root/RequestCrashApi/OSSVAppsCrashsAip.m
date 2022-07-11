//
//  OSSVAppsCrashsAip.m
// XStarlinkProject
//
//  Created by Kevin on 2021/4/23.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVAppsCrashsAip.h"

@implementation OSSVAppsCrashsAip {
    NSString *_deviceInfo;
    NSString *_crashInfo;
}

- (instancetype)initWithReportAppCrashDeviceInfo:(NSString *)deviceInfo crashInfo:(NSString *)crashInfo {
    self = [super init];
    if (self) {
        _deviceInfo = deviceInfo;
        _crashInfo  = crashInfo;
     }
    return self;

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
    return [OSSVNSStringTool buildRequestPath:kApi_AppCrashReport];
}

- (id)requestParameters {
    return @{@"deviceInfo": _deviceInfo,
             @"crashInfo" : _crashInfo
    };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
