//
//  OSSVAccounteMyOrdersAip.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteMyOrdersAip.h"

@implementation OSSVAccounteMyOrdersAip {
    NSInteger _page;
    NSInteger _pageSize;
    NSString *_status;
}

- (instancetype)initWithPage:(NSInteger)page pageSize:(NSInteger)pageSize Status:(NSString *)status {
    if (self = [super init]) {
        _page = page;
        _pageSize = pageSize;
        _status = status;
    }
    return self;
}

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
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_OrderList];
}

- (id)requestParameters {
    if (STLIsEmptyString(_status)) {
        return @{
        @"page" : @(_page),
        @"page_size" : @(_pageSize),
        @"commparam" : [OSSVNSStringTool buildCommparam]
        };
    }
    return @{
             @"page" : @(_page),
             @"page_size" : @(_pageSize),

             @"status" : STLToString(_status),
             @"commparam" : [OSSVNSStringTool buildCommparam]
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
