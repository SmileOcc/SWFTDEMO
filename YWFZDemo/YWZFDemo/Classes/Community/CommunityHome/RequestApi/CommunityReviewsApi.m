//
//  CommunityReviewsApi.m
//  Yoshop
//
//  Created by YW on 16/7/15.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "CommunityReviewsApi.h"
#import "Constants.h"

@implementation CommunityReviewsApi {
    NSInteger _curPage;
    NSString *_pageSize;
    NSString *_reviewId;
}

- (instancetype)initWithcurPage:(NSInteger)curPage pageSize:(NSString*)pageSize reviewId:(NSString *)reviewId {
    if (self = [super init]) {
        _curPage = curPage;
        _pageSize = pageSize;
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

-(BOOL)isCommunityRequest{
    return YES;
}

- (id)requestParameters {
    return @{
             @"type"        : @"9",
             @"directory"   : @"38",
             @"site"        : @"ZZZZZcommunity",
             @"loginUserId"    : USERID,
             @"pageSize" : _pageSize,
             @"curPage" : @(_curPage),
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
