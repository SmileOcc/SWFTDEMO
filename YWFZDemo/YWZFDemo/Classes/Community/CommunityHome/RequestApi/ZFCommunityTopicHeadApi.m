

//
//  ZFCommunityTopicHeadApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityTopicHeadApi.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"

@interface ZFCommunityTopicHeadApi () {
    NSString *_topicId;
    NSString *_reviewId;
}

@end

@implementation ZFCommunityTopicHeadApi

- (instancetype)initWithTopicId:(NSString *)topicId reviewId:(NSString *)reviewId{
    if (self = [super init]) {
        _topicId = topicId;
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
             @"site"        :   @"ZZZZZcommunity",
             @"type"        :   @"9",
             @"directory"   :   @"46",
             @"topic_id"    :   ZFToString(_topicId),
             @"app_type"    :   @"2",
             @"loginUserId" :   USERID ?: @"0",
             @"reviewId"    :   ZFToString(_reviewId),
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end
