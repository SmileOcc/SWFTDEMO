
//
//  ZFCommunityLabelDetailApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityLabelDetailApi.h"
#import "Constants.h"

@interface ZFCommunityLabelDetailApi () {
    NSInteger _curPage;
    NSString *_pageSize;
    NSString *_topicLabel;
}
@end

@implementation ZFCommunityLabelDetailApi

- (instancetype)initWithcurPage:(NSInteger)curPage pageSize:(NSString*)pageSize topicLabel:(NSString *)topicLabel{
    if (self = [super init]) {
        _curPage = curPage;
        _pageSize = pageSize;
        _topicLabel = topicLabel;
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
             @"type"        :   @"9",
             @"site"        :   @"ZZZZZcommunity",
             @"directory"   :   @"48",
             @"topic_label" :   _topicLabel,  //话题标签得带上#
             @"curPage"     :   @(_curPage),
             @"pageSize"    :   _pageSize,
             @"userId"      :   USERID ?: @"0",
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
