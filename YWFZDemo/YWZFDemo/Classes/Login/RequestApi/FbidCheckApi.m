//
//  FbidCheckApi.m
//  ZZZZZ
//
//  Created by YW on 17/3/24.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "FbidCheckApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation FbidCheckApi
{
    NSMutableDictionary *_dict;
}


- (instancetype)initWithDict:(NSMutableDictionary *)dict {
    self = [super init];
    if (self) {
        _dict = dict;
    }
    return self;
}

- (BOOL)enableCache {
    return YES;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [NSStringUtils buildRequestPath:@""];
}

- (id)requestParameters {
    return @{
             @"action"       : @"user/facebookCheckLogin",
             @"sess_id"      : SESSIONID,
             @"fbuid"        : NullFilter(_dict[@"fbid"]),
             @"access_token" : NullFilter(_dict[@"access_token"])
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}



- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end
