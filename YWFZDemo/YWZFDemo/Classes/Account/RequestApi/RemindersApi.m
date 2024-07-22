//
//  RemindersApi.m
//  ZZZZZ
//
//  Created by DBP on 2017/6/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "RemindersApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation RemindersApi {
    NSDictionary *_dict;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
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
    return ENCPATH;
}

- (id)requestParameters {
    
    return @{
             @"action"      :   @"order/update_order_info",
             @"token"       :   TOKEN,
             @"order_id"    :   _dict[@"order_id"],
             @"pid"         :   _dict[@"pid"],
             @"c"           :   _dict[@"c"],
             @"is_retargeting": _dict[@"is_retargeting"]
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
