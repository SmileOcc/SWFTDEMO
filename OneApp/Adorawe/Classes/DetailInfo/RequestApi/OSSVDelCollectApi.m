//
//  OSSVDelCollectApi.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDelCollectApi.h"

@implementation OSSVDelCollectApi {
    NSString *_goodsId;
    NSString *_wid;
}

- (instancetype)initWithAddCollectGoodsId:(NSString *)goodsId wid:(NSString *)wid{
    if (self = [super init]) {
        _goodsId = goodsId;
        _wid = wid;
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
    return [OSSVNSStringTool buildRequestPath:kApi_CollectDel];
}

- (id)requestParameters {
    return @{
             @"goods_id" : _goodsId,
             @"wid" : _wid,
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
