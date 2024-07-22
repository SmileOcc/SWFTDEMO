//
//  CheckReviewApi.m
//  ZZZZZ
//
//  Created by DBP on 16/12/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CheckReviewApi.h"
#import "NSStringUtils.h"
#import "Constants.h"

@implementation CheckReviewApi {
    NSString     *_goodsSn;
}


- (instancetype)initWithGoodsSn:(NSString *)goodsSn {
    self = [super init];
    if (self) {
        _goodsSn = goodsSn;
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

-(BOOL)encryption {
    return NO;
}

- (id)requestParameters {
    return @{
             @"token"       : TOKEN,
             @"action"      : @"review/get_user_goods_review",
             @"goods_sn"    : _goodsSn,
             @"timestamp"   : @"",
             @"is_enc"      : @"0",
             };
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
