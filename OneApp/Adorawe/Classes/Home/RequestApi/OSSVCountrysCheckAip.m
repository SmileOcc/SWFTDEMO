//
//  STLCountryCheckApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/16.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCountrysCheckAip.h"

@implementation OSSVCountrysCheckAip

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
    return [OSSVNSStringTool buildRequestPath:kApi_CountryCheck];
}

// 国家码，方便客户端测试开发参数，AU ， BE ， BG ...
- (id)requestParameters {
    return @{
#if DEBUG
             @"code" : @""
#else
#endif
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
