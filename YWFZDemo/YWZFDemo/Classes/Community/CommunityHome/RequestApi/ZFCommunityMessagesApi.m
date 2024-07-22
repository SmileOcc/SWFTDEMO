
//
//  ZFCommunityMessagesApi.m
//  ZZZZZ
//
//  Created by YW on 2017/7/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityMessagesApi.h"
#import "Constants.h"

@interface ZFCommunityMessagesApi (){
    NSInteger _curPage;
    NSString *_pageSize;
}

@end

@implementation ZFCommunityMessagesApi
- (instancetype)initWithcurPage:(NSInteger)curPage pageSize:(NSString *)pageSize{
    if (self = [super init]) {
        _curPage = curPage;
        _pageSize = pageSize;
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
             @"directory"   :   @"58",
             @"page"        :   @(_curPage),
             @"pageSize"    :   _pageSize,
             @"app_type"    : @"2",
             @"user_id"     :   USERID ?: @"0",
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}

- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
