//
//  searchAnalyticsApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import "OSSVSearchsAnalytAip.h"

@implementation OSSVSearchsAnalytAip
{
    NSString *_trendsId;
}

- (instancetype)initWithTrendsId:(NSString *)trendsId {
    if (self = [super init]) {
        _trendsId = trendsId;
    }
    return self;
}

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
    return [OSSVNSStringTool buildRequestPath:kApi_SearchSaveTrends];
}

- (id)requestParameters {
    return @{
             @"commparam"      : [OSSVNSStringTool buildCommparam],
             @"TrendsId"       : _trendsId
             };
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}


- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
