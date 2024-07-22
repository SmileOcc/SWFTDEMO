

//
//  ZFCommunityTopicDetailApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicDetailApi.h"
#import "Constants.h"

@interface ZFCommunityTopicDetailApi () {
    NSInteger _curPage;
    NSString *_pageSize;
    NSString *_topicId;
    NSString *_sort;
}

@end

@implementation ZFCommunityTopicDetailApi
- (instancetype)initWithcurPage:(NSInteger)curPage pageSize:(NSString*)pageSize topicId:(NSString *)topicId sort:(NSString *)sort {
    if (self = [super init]) {
        _curPage = curPage;
        _pageSize = pageSize;
        _topicId = topicId;
        _sort = sort;
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
             @"site"        :   @"ZZZZZcommunity",
             @"type"        :   @"9",
             @"directory"   :   @"47",
             @"topic_id"    :   _topicId,
             @"curPage"     :   @(_curPage),
             @"pageSize"    :   _pageSize,
             @"userId"      :   USERID ?: @"0",
             @"sort"        :   _sort,
             @"app_type"    :   @"2"
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end
