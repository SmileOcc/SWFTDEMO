

//
//  ZFCommunityReviewsApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityReviewsApi.h"
#import "Constants.h"

@interface ZFCommunityReviewsApi () {
    NSInteger _curPage;
    NSString *_pageSize;
    NSString *_reviewId;
}
@end

@implementation ZFCommunityReviewsApi
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
             @"directory"   : @"38",
             @"site"        : @"ZZZZZcommunity",
             @"loginUserId"    : USERID ?: @"0",
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
