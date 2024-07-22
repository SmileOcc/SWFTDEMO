
//
//  ZFCommunityDetailApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityDetailApi.h"
#import "Constants.h"

@interface ZFCommunityDetailApi () {
    NSString *_reviewId;
}

@end

@implementation ZFCommunityDetailApi
- (instancetype)initWithReviewId:(NSString*)reviewId {
    if (self = [super init]) {
        _reviewId = reviewId;
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

-(BOOL)encryption {
    return YES;
}

-(BOOL)isCommunityRequest{
    return YES;
}


- (id)requestParameters {
    return @{
             @"type"        : @"9",
             @"directory"   : @"35",
             @"site"        : @"ZZZZZcommunity",
             @"loginUserId" : USERID ?: @"0",
             @"reviewId"    : _reviewId,
             @"app_type"    : @"2"
             };
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
