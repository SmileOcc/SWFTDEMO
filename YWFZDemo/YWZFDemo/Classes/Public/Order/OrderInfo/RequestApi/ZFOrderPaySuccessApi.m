//
//  ZFOrderPaySuccessApi.m
//  ZZZZZ
//
//  Created by YW on 2018/4/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderPaySuccessApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation ZFOrderPaySuccessApi
- (instancetype)init {
    self = [super init];
    return self;
}

- (BOOL)enableCache {
    return YES;
}

-(BOOL)encryption {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return ENCPATH;
}

- (id)requestParameters {
    
    return @{
             @"action"     :  @"cart/payok",
             @"token"      :  TOKEN,
             @"is_enc"   :  @"0"
             };
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}
@end
