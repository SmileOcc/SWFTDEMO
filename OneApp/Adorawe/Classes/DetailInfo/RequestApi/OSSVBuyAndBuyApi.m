//
//  OSSVBuyAndBuyApi.m
// XStarlinkProject
//
//  Created by fan wang on 2021/6/11.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVBuyAndBuyApi.h"

@interface OSSVBuyAndBuyApi ()
@property (nonatomic,strong) NSDictionary *params;
@end

@implementation OSSVBuyAndBuyApi

-(instancetype)initWithParams:(NSDictionary *)params{
    if (self = [super init]) {
        _params = params;
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
    return [OSSVNSStringTool buildRequestPath:kApi_ItemUserBuyAndBuy];
}

- (id)requestParameters {
    
    return _params;
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}

/// 请求的SerializerType
- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}
@end
