//
//  CommunityDetailApi.m
//  Yoshop
//
//  Created by YW on 16/7/14.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "CommunityDetailApi.h"
#import "Constants.h"

@implementation CommunityDetailApi {
    NSString *_reviewId;
}

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
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

-(BOOL)encryption {
    return YES;
}

- (id)requestParameters {
    return @{
             @"type"        : @"9",
             @"directory"   : @"35",
             @"site"        : @"ZZZZZcommunity",
             @"loginUserId" : USERID,
             @"reviewId" : _reviewId,
             @"app_type"    : @"2"
             };
}

- (SYRequestMethod)requestMethod {
    
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

-(BOOL)isCommunityRequest{
    return YES;
}

@end
