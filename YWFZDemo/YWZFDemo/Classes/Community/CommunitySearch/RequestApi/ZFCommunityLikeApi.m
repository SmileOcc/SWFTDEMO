//
//  ZFCommunityLikeApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityLikeApi.h"
#import "Constants.h"

@interface ZFCommunityLikeApi (){
    NSInteger _flag;
    NSString *_reviewId;
}

@end

@implementation ZFCommunityLikeApi

- (instancetype)initWithReviewId:(NSString *)reviewId flag:(NSInteger)flag {
    if (self = [super init]) {
        _reviewId = reviewId;
        _flag = flag;
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
             @"type"      : @"4",
             @"site"      : @"ZZZZZcommunity",
             @"userId"    : USERID,
             @"reviewId"  : _reviewId,
             @"flag"      : @(_flag),  // 0为点赞;1为取消点赞
             @"app_type"  : @"2"
             };
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end
