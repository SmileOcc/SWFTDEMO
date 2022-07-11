//
//  OSSVDetailCartExitApi.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/28.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailCartExitApi.h"

@interface OSSVDetailCartExitApi ()
@property (strong,nonatomic) NSDictionary *params;
@end

@implementation OSSVDetailCartExitApi

- (instancetype)initWithParms:(NSDictionary *)dic{
    if (self = [super init]) {
        self.params = dic;
    }
    return self;
}

- (BOOL)enableCache {
    return YES;
}

- (BOOL)enableAccessory {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [OSSVNSStringTool buildRequestPath:kApi_GoodsCartExit];
}

- (id)requestParameters {
    return self.params;
}

- (STLRequestMethod)requestMethod {
    return STLRequestMethodPOST;
}

/// 请求的SerializerType
- (STLRequestSerializerType)requestSerializerType {
    return STLRequestSerializerTypeJSON;
}

@end
